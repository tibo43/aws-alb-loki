#!/usr/bin/env python3
# coding=utf8
#from __future__ import print_function
from datetime import *
from dateutil import tz
from pygrok import Grok
import json, gzip, requests, pandas as pd, os, boto3, botocore, logging, time, sys

logFormatter = logging.Formatter("[%(levelname)s] - message: \"%(message)s\"")
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def get_logs_on_s3():
	list_ts = []
	data_loki={}
	aws_s3_bucket=os.environ["AWS_S3_BUCKET"]
	aws_s3_prefix=os.environ["ENVIRONMENT"]
	logger.info("Starting get object on bucket {} for environment {}".format(aws_s3_bucket,aws_s3_prefix))
	i=0
	local_folder="/tmp/logs"
	s3 = boto3.resource('s3')
	bucket = s3.Bucket(aws_s3_bucket)
	if not os.path.exists(local_folder):
		os.makedirs(local_folder)
	marker_value = get_marker_value()
	for file in bucket.objects.filter(Prefix = aws_s3_prefix, Marker=marker_value):
		i=i+1
		file_path=local_folder+'/'+aws_s3_prefix+'_'+str(i)+'.log.gz'
		bucket.download_file(file.key,file_path)
		logger.info("Downloading file {} to {}".format(file.key,file_path))
		marker_value=file.key
		list_ts, data_loki=parse_alb_log_file(file_path,list_ts,data_loki)
	push_marker_value(marker_value)
	if i==0:
		logger.warning('No file found')
	for key in sorted(data_loki):
	 	push_to_loki(key,data_loki[key])

def get_marker_value():
	aws_s3_bucket=os.environ["AWS_S3_BUCKET"]
	marker_filename=os.environ["MARKER_FILENAME"]
	s3 = boto3.resource('s3')
	try:
		s3.Bucket(aws_s3_bucket).download_file(marker_filename,"/tmp/{}".format(marker_filename))
	except botocore.exceptions.ClientError as ex:
		if ex.response['Error']['Code'] == "404":
			marker_value = ""
		else:
			logger.error("Exception raise when get marker value: {}".format(ex))
	else:
		marker_file = open("/tmp/{}".format(marker_filename),'r')
		marker_value = marker_file.read()
		marker_file.close()
	return marker_value
	
def push_marker_value(marker_value):
	aws_s3_bucket=os.environ["AWS_S3_BUCKET"]
	marker_filename=os.environ["MARKER_FILENAME"]
	try: 
		s3 = boto3.resource('s3')
		marker_file = open("/tmp/{}".format(marker_filename),'w+')
		marker_file.write(marker_value)
		marker_file.close()
		s3.Bucket(aws_s3_bucket).upload_file("/tmp/{}".format(marker_filename),marker_filename)
	except Exception as ex:
		logger.error("Exception raise when push marker value: {}".format(ex))

def parse_alb_log_file(file_path,list_ts,data_loki):
	logger.info("Parsing logs on {}".format(file_path))
	fields_loki = [
		"timestamp",
		"type",
		"client_ip",
		"target_ip",
		"request_processing_time",
		"target_processing_time",
		"response_processing_time",
		"alb_status_code",
		"target_status_code",
		"received_bytes",
		"sent_bytes",
		"request_verb",
		"request_url",
		"request_proto",
		"user_agent",		
		"trace_id",
		"request_creation_time",
	]
	from_zone = tz.tzutc()
	to_zone = tz.gettz('Europe/Paris')
	try:
		with gzip.open(file_path, 'rt') as file:
			data_file = file.readlines()
			for line in data_file:
				item = {}
				log_grok = grok(line)
				if not (log_grok is None):
					for field in fields_loki:
						if field in log_grok:
							if not (log_grok[field] is None):	
								if (field == "timestamp"):
									milli_ts=int((pd.to_datetime(log_grok[field],format='%Y-%m-%dT%H:%M:%S.%fZ',utc=True)-pd.to_datetime("1970-1-1",format='%Y-%m-%d',utc=True)).total_seconds()*1000000)
									ts=str(milli_ts)+str(f"{list_ts.count(milli_ts):03}")
									list_ts.append(milli_ts)
									item[field]=(((datetime.strptime(log_grok[field],'%Y-%m-%dT%H:%M:%S.%fZ')).replace(tzinfo=from_zone)).astimezone(to_zone)).strftime("%Y-%m-%dT%H:%M:%S.%fZ")
								elif (field == "request_creation_time"):
									item[field]=(((datetime.strptime(log_grok[field],'%Y-%m-%dT%H:%M:%S.%fZ')).replace(tzinfo=from_zone)).astimezone(to_zone)).strftime("%Y-%m-%dT%H:%M:%S.%fZ")
								else:
									item[field]=log_grok[field]
						else:
							item[field]=None
				data_loki[ts]=item
	except Exception as ex:
		logger.error("Exception raise when try to open file: {}".format(ex))
	return list_ts,data_loki

def grok(line):
	patterns_spec=[
		'%{ALB}',
	]
	for pattern in patterns_spec:
		if not (Grok(pattern,custom_patterns_dir='patterns').match(line) is None):
			return Grok(pattern,custom_patterns_dir='patterns').match(line)

def push_to_loki(ts,data):
	loki_url=os.environ["LOKI_URL"]
	logger.debug('Pushing logs on Loki {}'.format(loki_url))
	loki_request_headers = { 'Content-type': 'application/json' }
	loki_request_payload = {
		"streams": [
			{
				"stream": {"service":"load-balancer","environment":os.environ["ENVIRONMENT"]},
				"values": [[ts,data]]
			}
		]
	}
	try:
		post=requests.post(loki_url, data=json.dumps(loki_request_payload), headers=loki_request_headers)
		if not post.ok:
			logger.warning('Status code: {}, Response error: {}'.format(post.status_code, post.reason))
			logger.info('Data sent: {}'.format(loki_request_payload))
	except Exception as ex:
		logger.error("Exception raise when request Loki: {}".format(ex))

def main(event, context):
	logger.info("Starting parse Load-Balancer logs and push on Loki")
	get_logs_on_s3()
	logger.info("End parse Load-Balancer logs and push on Loki")

if __name__ == '__main__':
	main()
