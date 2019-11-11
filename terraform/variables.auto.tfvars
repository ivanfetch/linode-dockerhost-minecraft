# Values for Terraform variables that will be auto-loaded by Terraform.
#
# Values are specified in this file, to avoid requiring them to be set on the command-line.
# Ref: https://www.terraform.io/docs/configuration/variables.html#assigning-values-to-root-module-variables

# These variables are declared in other `*.tf` files.
instance_region        = "us-west"
instance_name          = "test-docker"
instance_type          = "g6-standard-2"
instance_bootdisk_size = "20000"
instance_datadisk_size = "60"

