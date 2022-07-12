variable "name" {
    type = string
}
variable "retention_in_days" {
    type = number
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