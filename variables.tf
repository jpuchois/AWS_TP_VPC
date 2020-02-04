variable "key" {
  type    = "string"
  default = "PuchKey"
}

variable "cidr_block" {
  type = "string"
  default = "10.0.0.0/16"
}

variable "availability_zones" {
  type = "list"
  default = ["eu-west-3a", "eu-west-3b", "eu-west-3c"]
}


