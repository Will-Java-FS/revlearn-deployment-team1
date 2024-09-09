variable "sg_name_prefix" {
  description = "Prefix for the security group name"
  type        = string
  default     = "rds-"
}

variable "vpc_id" {
  description = "VPC ID for the RDS instance"
  type        = string
}

variable "cidr_blocks" {
  description = "List of CIDR blocks for security group ingress"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "tags" {
  description = "Tags to apply to the resources"
  type        = map(string)
  default     = {
    Name     = "revlearn_rds"
    Owner    = "Trey-Crossley"
  }
}

variable "db_subnet_group_name" {
  description = "Name for the DB subnet group"
  type        = string
  default     = "revlearn-db-subnet-group"
}

variable "subnet_ids" {
  description = "List of subnet IDs for the DB subnet group"
  type        = list(string)
}

variable "allocated_storage" {
  description = "The size of the database (Gb)"
  type        = number
  default     = 10
}

variable "db_name" {
  description = "The name of the database"
  type        = string
  default     = "revlearn"

}

variable "storage_type" {
  description = "The storage type"
  type        = string
  default     = "gp2"
}

variable "engine" {
  description = "The database engine"
  type        = string
  default     = "postgres"
}

variable "engine_version" {
  description = "The database engine version"
  type        = string
  default     = "16.4"
}

variable "instance_class" {
  description = "The instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_identifier" {
  description = "The DB instance identifier"
  type        = string
  default     = "revlearn-db"
}

variable "username" {
  description = "The username for the master DB user"
  type        = string
  default     = "adminuser"
}

variable "password" {
  description = "The password for the master DB user"
  type        = string
  sensitive   = true
  default     = "Password123!"
}

variable "skip_final_snapshot" {
  description = "Whether to skip a final snapshot before deleting the instance"
  type        = bool
  default     = true
}
