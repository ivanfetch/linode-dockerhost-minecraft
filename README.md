# Terraform-managed Linode-based Docker Host + Minecraft

This repository provides an example Ubuntu 18.04 host that runs [Docker](http://www.docker.io), on the [Linode cloud](http://www.linode.com). You will be charged for Linode resources until you use Terraform to destroy them.

[Terraform](http://www.terraform.io) is used to provision [infrastructure as code](https://www.hashicorp.com/resources/what-is-infrastructure-as-code).

This repository also includes a [Docker Compose](https://docs.docker.com/compose/) file to ease managing Minecraft servers using the [itzg/minecraft-server Docker image](https://hub.docker.com/r/itzg/minecraft-server/). Note that these containers will be accessible from the Internet and anyone can connect and play on your Linode instance.

## One-time Setup

Use of this repository requires tools to be installed and environment variables to be set.

### Install Prerequisites

* Use git to clone this repository to your workstation. `git clone https://github.com/ivanfetch/linode-dockerhost-minecraft`
* Install [Terraform](https://www.terraform.io). If using the `tfenv` script mentioned below, install the correct version of Terraform by running `tfenv install` **from within your cloned copy of this repository**. If you are not using the `tfenv` script, see the [.terraform-version file](./.terraform-version) at the root of this repository for the exact version of Terraform that you should install.
	* I recommend using [tf-env](https://github.com/Zordrak/tfenv) to install Terraform, and more easily switch between multiple versions of Terraform. The `tfenv` script requires that `curl` and `unzip` be installed. Tfenv uses the `.terraform-version` file at the root of this repository to determine which version of Terraform to install.

### Obtain an API Token and Set an Environment Variable

Obtain a Linode API token and export the `LINODE_TOKEN` environment variable so Terraform can access the Linode API.

You may want to use a tool like [direnv](https://direnv.net/) to set the `LINODE_TOKEN` environment variable only when you are working in your copy of this repository. The `.gitignore` file in this repository ignores the `.envrc` file, to avoid committing your Linode API token into your copy of this repository.

* Go to the [Linode Cloud Manager](https://cloud.linode.com/).
* Click your username at the top, then click `My Profile`.
* Select the `API Tokens` tab.
* Click on `Add a Personal Access Token` and choose the access rights (for this example, the token will need to be able to create a Linode, volume, boot config, and StackScript).
* Take note of the token, as it will only be displayed once.
* Set the `LINODE_TOKEN` environment variable to your token.

### Add an SSH Key to Your Linode Profile

By default the Terraform code populates the Linode instance with the SSH key from your Linode profile. If you do not want to use an SSH key via your Linode profile, you can modify [terraform/instance.tf](./terraform/instance.tf) and either specify an SSH public key in the Terraform code, or specify a root password. Note that specifying a root password in Terraform code is unsafe, especially if you do not manually change the root password in your instance!

To add an SSH key to your Linode user profile:

* Go to the [Linode Cloud Manager](https://cloud.linode.com/).
* Click your username at the top, then click `My Profile`.
* Select the `SSH Keys` tab.
* Click the `Add SSH Key` button, and paste a **public key**.

## Using Terraform to Create and Manage Infrastructure

Change to the `terraform` sub-directory of this repository, before running Terraform commands.

Terraform will create the following resources in Linode:

* A [StackScript](https://www.linode.com/products/stackscripts/), which configures the operating system by updating packages, setting the hostname, formatting and mounting a second data disk, installing Docker from docker.io, and installing Docker Compose.
* A volume; disk used to house Docker data, mounted under `/var/lib/docker` by the above StackScript.
* An instance running Ubuntu 18.04, that uses the above StackScript and data disk resources..

### Terraform State

Terraform [tracks the state of resources it provisions](https://www.terraform.io/docs/state/index.html) in a state file. Ideally a [Terraform remote backend](https://www.terraform.io/docs/backends/index.html) is used to store the state file somewhere central like Amazon Web Services or Google Cloud storage. A Terraform state file will be created in the `terraform` sub-directory of your copy of this repository. Please make sure to keep this state file (`terraform.tfstate*) safe, as it is required to use Terraform to update or destroy the resources it manages.

### Customizing Terraform Inputs

This Terraform code uses some variables to allow customizing the name, boot disk size, data disk size, and Linode region of the instance. Edit the [terraform/variables.auto.tfvars](./terraform/variables.auto.tfvars) file to change any of these values.

If you did not elect to add an SSH public key to your Linode user profile, remember to edit [terraform/instance.tf](./terraform/instance.tf) to comment out `authorized_users` and uncomment and set `authorized_keys` to your own SSH public key.

### Create Linode Resources Using Terraform

Run the following commands from the `terraform` sub-directory to provision resources in your Linode account.

* `terraform init`
> Downloads required Terraform modules and providers, and verifies that terraform can communicate with its state storage. You will need to run this the first time you run terraform, or if you update any of the references to modules. This repository currently does not use any modules

* `terraform plan`
> This command shows the differences between the current infrastructure and the state described by terraform code. It shows what resources will be created, modified, or destroyed.

* `terraform apply`
> This command actually makes changes to your infrastructure! Similar to a `plan`, it shows what resources will be created, modified, and destroyed - asking for confirmation before making changes.

### Terraform Outputs

When `terraform apply` or `terraform output` is run, Terraform displays useful information in the form of "outputs."

* `instance_type_provided_disk` - the amount of disk space provided by the type of Linode instance, useful to verify whether you are using all of the provided space.
* `instance_type_provided_memory` - The amount of memory provided by the type of Linode instance.
* `public_ip` - The public IP of the instance.

## Minecraft Docker Containers

This repository contains a Docker Compose file that deploys two Minecraft server containers. NOTE that the Minecraft servers will be accessible from the Internet, and anyone can connect and play!

Docker Compose is used to ease running these containers, vs. running a lengthy `docker` command to recreate the containers each time a change is made to their environment.

You can copy the Docker Compose file to your  Linode instance and use it to start two Minecraft server containers:

* Copy the [minecraft sub-directory](./minecraft) from your copy of this repository, to your Linode instance.
* SSH to the Linode instance, change to the `minecraft` sub-directory, and run `docker-compose up -d` to create the Minecraft containers:

```
# From within the terraform sub-directory. . .
scp -r ../minecraft root@$(terraform output public_ip):.
ssh root@$(terraform output public_ip)
cd minecraft
docker-compose up -d
```

You should now be able to connect to both of the two Minecraft containers on TCP ports 25565 and 25566 of your Linode instance public IP address.

### Managing The Minecraft Instances

From your Linode instance shell, you can connect to the Minecraft console of one of the containers using: `docker exec -it mc1 rcon-cli` (where mc1 is the name of one of the containers)
Disconnect from the Minecraft CLI by typing CTRL-d.
Disconnect from a `docker exec` (leaving the exec process running) by pressing `CTRL-p` then `CTRL-q`.

The `/data` directory inside each Minecraft container is mounted to the `/mc1/data` or `/mc2/data` filesystem path of your Linode instance. This allows modifying the configuration of the containers, and separating the data from the container.
See the [itzg/minecraft-server Docker image page](https://hub.docker.com/r/itzg/minecraft-server/) for more information about how to manage settings, mods, Etc. in your Minecraft containers.

### Stopping The Minecraft Instances

SSH to your Linode instance, change to the `minecraft` directory, and run `docker-compose down` to remove the containers. The host paths used for the `/data` container volumes will remain on your instance, the next time new containers are created with `docker up -d`.

## Destroying The Infrastructure

When you are done with your Linode instance, run `terraform destroy` from the `terraform` sub-directory of your copy of this repository. Terraform will destroy the Linode StackScript, instance, and data volume.
