variable "sub_ids" {
}

variable "storage" {
  default = 20
}
variable "db_name" {
  default = "srinidb"
}

variable "username" {
  default = "vasuit"
}
variable "password" {
  default = "vasuit1234"
}

variable "vpc_id" {
}
variable "rds_ingress_rules" {
  type = map(object({
    port            = number
    protocol        = string
    cidr_blocks     = list(string)
    description     = string
    security_groups = list(string)
  }))
}
