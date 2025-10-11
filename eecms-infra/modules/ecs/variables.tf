variable "eecms_repo_url" {
  type = string
}

variable "region" {
  type = string
}

variable "container_port" {
  default = 8080
}

variable "db_username" {
  default = "db_admin"
}

variable "db_password" {
  default = "db_password"
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_1_id" {
  type = string
}

variable "private_subnet_2_id" {
  type = string
}

variable "alb_sg_id" {
  type = string
}

variable "lb_target_group_arn" {
  type = string
}

variable "lb_listener" {
  type = string
}
