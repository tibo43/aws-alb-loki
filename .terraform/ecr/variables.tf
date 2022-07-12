variable "region" {
    type = string
    default = "eu-west-3"
    description = "Region to deploy infrastructure"
}
variable "name" {
    type = string
    description = "Name of repository"
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