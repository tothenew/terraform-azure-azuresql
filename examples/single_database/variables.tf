variable "client_name" {
  description = "Client name/account used in naming"
  type        = string
}

variable "environment" {
  description = "Project environment"
  type        = string
}

variable "stack" {
  description = "Project stack name"
  type        = string
}

variable "location" {
  description = "Azure region to use."
  type        = string
}

variable "extra_tags" {
  description = "Additional tags to associate."
  type        = map(string)
  default     = {}
}