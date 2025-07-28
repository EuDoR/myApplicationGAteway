# variables.tf
variable "subnet_ag_prefix" {
  default = "10.0.1.0/24"
}
variable "subnet_docker_prefix" {
  default = "10.0.2.0/24"
}
variable "subnet_otrasApps_prefix" {
  default = "10.0.3.0/24"
}