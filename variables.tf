variable "CUSTOMER_NAME" {
  description = "The name of the bank to be used in naming resources"
}

variable "VPC_CIDR" {
    type       = string 
    description = "CIDR of VPC generated"
}

variable "subnet_bits" {
    description = "Number of additional bits to use for subnetting"
    type        = number 
    default     = 1     # creates 2 split subnets
}

variable "availability_zone" {
  description = "The Availability Zone to deploy the subnet in"
  type        = string
}

variable "region" {
  description = "Region"
  type        = string
}

variable "aws_profile" {
  description = "AWS profile to use for authentication"
  type        = string
  default     = "apj_poc"
}

variable "authenticated_networks" {
  description = "List of CIDR blocks for authenticated networks (APJ office, Wireguard, etc.)"
  type        = list(string)
  default     = ["117.54.101.0/24", "103.78.81.146/32", "117.54.101.34/32", "108.136.251.67/32", "43.218.78.208/32"]
}

variable "instances" {
  description = "Map of instance configurations"
  type = map(object({
    create          = bool
    instance_name   = string
    ami             = string
    instance_type   = string
    private_ip      = string
    security_group  = string
    volume_size     = number
  }))
  default = null
}
