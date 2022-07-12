FROM python:3.10.5-slim
WORKDIR /srv
COPY requirements.txt .
RUN /usr/local/bin/python3 -m pip install --upgrade pip && pip3 install -r requirements.txt && pip3 install awslambdaric==2.0.1
COPY patterns patterns
COPY log_to_loki.py .
ENTRYPOINT [ "/usr/local/bin/python3", "-m", "awslambdaric" ]
CMD [ "log_to_loki.main" ]
