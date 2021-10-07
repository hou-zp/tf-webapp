variable "region" {
  description = "alicloud region"
  default     = "cn-hangzhou"
  type        = string
}

variable "key_name" {
  default     = "ansible"
  description = "Desired name prefix for the AWS key pair"
}

variable "az" {
  default     = "cn-beijing-b"
  description = "avaibility zone"
}
