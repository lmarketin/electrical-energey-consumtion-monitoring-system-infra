variable "region" {
  default = "eu-central-1"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnet_1" {
  default = "10.0.16.0/20"
}

variable "public_subnet_2" {
  default = "10.0.32.0/20"
}

variable "private_subnet_1" {
  default = "10.0.80.0/20"
}

variable "private_subnet_2" {
  default = "10.0.112.0/20"
}

variable "availibilty_zone_1" {
  default = "eu-central-1a"
}

variable "availibilty_zone_2" {
  default = "eu-central-1b"
}

variable "container_port" {
  default = 8080
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

variable "db_username" {}
variable "db_password" {}

