variable "private_subnet_1" {
  default = "10.0.80.0/20"
}

variable "private_subnet_2" {
  default = "10.0.112.0/20"
}

variable "settings" {
  type = map(any)
  default = {
    "database" = {
      allocated_storage   = 5
      engine              = "postgres"
      engine_version      = "15.7"
      instance_class      = "db.t4g.micro"
      db_name             = "pgsql"
      skip_final_snapshot = true
      identifier          = "pgsql"
    }
  }
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

variable "ecs_sg_id" {
  type = string
}

variable "exporter_lambda_sg_id" {
  type = string
}
