# A Linode data volume and instance.
# Ref: https://www.terraform.io/docs/providers/linode/r/instance.html


# A Linode volume for Docker data.
# Note that the boot volume is declared with the instance resource below.
resource "linode_volume" "docker_data" {
  label  = "${var.instance_name}-data"
  size   = var.instance_datadisk_size
  region = var.instance_region
}

# A Linode instance.
resource "linode_instance" "docker" {
  label = var.instance_name
  #group      = "lab"
  #tags = [ "whatever" ]
  region     = var.instance_region
  type       = var.instance_type
  private_ip = true


  disk {
    label = "boot"
    size  = var.instance_bootdisk_size
    image = "linode/ubuntu18.04"
    # Note that if the StackScript is updated and you wish to REPLACE this instance,
    # taint the resource in Terraform then run `terraform apply`.
    # terraform taint linode_instance.docker && terraform apply
    stackscript_id = linode_stackscript.docker.id

    # Any of authorized_keys, authorized_users, and root_pass
    # can be used for provisioning.
    #authorized_keys = [ "ssh-rsa ...." ]
    authorized_users = [data.linode_profile.me.username]
    #root_pass = "abc123lol"
  }

  config {
    label  = "boot_config"
    kernel = "linode/latest-64bit"
    devices {
      sda {
        disk_label = "boot"
      }
      sdc {
        volume_id = linode_volume.docker_data.id
      }
    }
    root_device = "/dev/sda"
  }

  boot_config_label = "boot_config"
}

# Output useful information after a Terraform apply.
output "public_ip" {
  value = linode_instance.docker.ip_address
}
output "instance_type_provided_disk" {
  value = linode_instance.docker.specs.0.disk
}

output "instance_type_provided_memory" {
  value = linode_instance.docker.specs.0.memory
}


