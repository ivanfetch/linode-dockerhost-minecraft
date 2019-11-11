# A Linode StackScript for configuring the OS of this instance.
# This script is run at first boot.
# Ref: https://www.terraform.io/docs/providers/linode/r/stackscript.html

# Note that if the StackScript is updated and you wish to REPLACE the Linode instance,
# taint the instance resource in Terraform then run `terraform apply`.
# terraform taint linode_instance.docker && terraform apply

resource "linode_stackscript" "docker" {
  # For an example of how to pass parameters to stack scripts,
  # See https://www.terraform.io/docs/providers/linode/r/stackscript.html
  label       = "${var.instance_name}script"
  description = "configures the OS"
  images      = ["linode/ubuntu18.04"]
  script      = <<EOF
#!/bin/bash

# Output info from this script
function info {
echo "StackScript: $@"
}

# Linode StackScripts do not seem to log anywhere.
exec >/root/stackscript.log 2>&1


export DEBIAN_FRONTEND=noninteractive
info Upgrading packages. . .
apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" update
apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade
apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" dist-upgrade


info Formatting and mounting the data disk. . .
mkfs.ext4 -L docker -j /dev/sdc
echo '/dev/sdc       /var/lib/docker               ext4    errors=remount-ro 0       2' >>/etc/fstab
mkdir -p /var/lib/docker
mount /var/lib/docker


info Setting hostname...
hostnamectl set-hostname ${replace(lower(var.instance_name), "/_/", "-")}


info Installing Docker CE
apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu  $(lsb_release -cs)  stable"
apt-get install -y docker-ce

info Installing docker-compose. . .
curl -L   "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)"   -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose


info Rebooting, if required by any kernel updates. . .
test -r /var/run/reboot-required && echo Reboot is required, doing that now... && shutdown -r now
EOF
}
