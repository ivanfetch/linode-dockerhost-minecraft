# Declare Terraform variables.
# Ref: https://www.terraform.io/docs/configuration/variables.html

variable "instance_region" {
  description = "The region of the Linode instance and data volume."
}

variable "instance_name" {
  description = "The name (label) of the Linode instance, also used for the OS hostname. This value should not contain spaces, which are unsupported by Linode labels."
}

variable "instance_type" {
  description = "The type of the Linode instance, representing CPU, memory, and disk. For example: g6-standard-1 or g6-nanode-1"
}
variable "instance_bootdisk_size" {
  description = "The size, in Mb, of the instance boot disk. Both the boot disk and data disk sizes must not exceed the storage allocated to the instance type."
}

variable "instance_datadisk_size" {
  description = "The size, in Gb, of the instance data disk. Both the boot disk and data disk sizes must not exceed the storage allocated to the instance type."
}


