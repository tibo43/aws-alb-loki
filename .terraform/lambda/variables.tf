variable "region" {
    type = string
    default = "eu-west-3"
    description = "Region to deploy infrastructure"
}
variable "functions" {
    type        = map(any)
    description = "Map of function names to configuration"
}
variable "retention_in_days" {
    type = number
    default = 3
    description = "Retention of cloudwatch logs"
}
variable "maximum_event_age_in_seconds" {
    type = number
    default = 60
    description = "aximum age of a request that Lambda sends to a function for processing in seconds"
}
variable "maximum_retry_attempts" {
    type = number
    default = 0
    description = "Maximum number of times to retry when the function returns an error."
}
variable "reserved_concurrent_executions" {
    type = number
    default = -1
    description = "Amount of reserved concurrent executions for this lambda function."  
}
variable "image_uri" {
    type = string
    description = "URI of the image"
}
variable "source_code_hash" {
    type = string
    description = "Hash of docker image"
    default = "latest"
}