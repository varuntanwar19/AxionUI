variable "tenant_id" {
  type        = string
  description = "The Azure Active Directory Tenant ID"
}

variable "postgres_db" {
  type        = string
  description = "The name of the PostgreSQL database"
}

variable "postgres_user" {
  type        = string
  description = "The PostgreSQL administrator username"
}

variable "postgres_password" {
  type        = string
  description = "The PostgreSQL administrator password"
  sensitive   = true
}

variable "pgadmin_email" {
  type        = string
  description = "The default pgAdmin user email"
}

variable "pgadmin_password" {
  type        = string
  description = "The default pgAdmin user password"
  sensitive   = true
}

variable "database_url" {
  type        = string
  description = "The database-url for ingestion"
  sensitive   = true
}

variable "telemetry_db_url" {
  type        = string
  description = "The database-url for telemetry"
  sensitive   = true
}

variable "app_vnet_resource_group" {
  type        = string
  description = "The Resource Group name for the Application VNet"
}

variable "app_vnet_name" {
  type        = string
  description = "The Application Virtual Network name"
}