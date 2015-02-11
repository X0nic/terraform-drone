variable "access_key" {}
variable "secret_key" {}
variable "region" {
    default = "us-east-1"
}

variable "key_name" {
    description = "SSH key name in your AWS account for AWS instances."
}

variable "key_path" {
    description = "Path to the private key specified by key_name."
}
