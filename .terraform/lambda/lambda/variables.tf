variable "name" {
    type = string
}
variable "image_uri" {
    type = string
}
variable "role" {
}
variable "timeout" {
    type = number
}
variable "memory_size" {
    type = number
}
variable "maximum_event_age_in_seconds" {
    type = number
}
variable "maximum_retry_attempts" {
    type = number
}
variable "variables" {
    type = map(any)
}
variable "schedule" {
    type = string
}
variable "is_enabled" {
    type = bool
}
variable "reserved_concurrent_executions" {
  
}
variable "source_code_hash" {
    type = string
}
variable "team" {
    description = "Define team name for identification"
}
variable "product" {
    description = "Define product name for identification"
}
variable "environment" {
    description = "Define environment type for identification"
}
variable "department" {
    description = "Define department name for identification"
}