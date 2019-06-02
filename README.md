# Infrastrucure as Code Demo

## Introduction

This project is a demonstration on using various tools to provision and deploy [`jenkins`](https://jenkins.io/) on [Google Cloud Platform](https://cloud.google.com/), with one `jenkins` job to build a [`docker`](https://www.docker.com/) container of a [sample web application](https://github.com/danielpoonwj/go-http-sample). This is by no means production ready, but the aim is to provide a brief run-through of the approach and various tools that can be used to accomplish this.

*Note*: This has only been tested for *nix systems (Mac OS/Linux). The tools may be supported on Windows but I've not personally tried.

## Machine Image Provisioning

### Overview

[`packer`](https://packer.io/) is a tool which specializes in the creation of various types of machine images. This allows the exact same provision steps for different targets (eg. Google Compute Engine Images, AWS AMIs, Vagrant Boxes). In this example, the core provisioning steps are performed with [`ansible`](https://www.ansible.com/), leveraging on open source Ansible Galaxy roles for the installation and configuration of `jenkins` and `docker`. However, there are [other automation tools](https://packer.io/docs/provisioners/index.html) supported as `packer` provisoners, such as `chef`, `puppet` and `salt`.

One of the goals of this demo is to be able to develop locally for a faster feedback cycle, particularly for this provisioning stage. For this, we are using [`vagrant`](https://www.vagrantup.com/). Paired with `packer`'s [`vagrant` builder](https://packer.io/docs/builders/vagrant.html), the exact same provisioning steps can be performed locally.

One of the advantages of `ansible` is the included `ansible-vault` tool, which encrypts sensitive data. For this demo, the `jenkins` username and password are encrypted in `ansible/vars/vault.yml`. You can interact with the vault using the following commands. Note that checking in the password file to version control is only for demonstration purposes and should **NOT** be done under any other circumstances as it defeats the purpose of encrypting sensitive data.

```bash
# view the decrypted contents of the file
ansible-vault view --vault-password-file .ansible-vault-pass ansible/vars/vault.yml

# decrypt and edit the file if necessary
ansible-vault decrypt --vault-password-file .ansible-vault-pass ansible/vars/vault.yml

# encrypt the file after editing the contents
ansible-vault encrypt --vault-password-file .ansible-vault-pass ansible/vars/vault.yml
```

### Requirements

- [`packer`](https://packer.io/) >= 1.4.0
- [`vagrant`](https://www.vagrantup.com/) >= 2.2.0 (for development)
- [`gcloud SDK`](https://cloud.google.com/sdk/) (for google cloud)
- [`ansible`](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) (for editing/viewing the encrypted credentials)

### Setup

There is a convenience wrapper script provided in `packer/build.sh`. This mainly wraps the `packer` command and does a bit of plumbing specifically for use with `vagrant`.

**Note**: For simplicity, the following sections will be assuming you are in the `packer` directory.

```bash
cd packer
```

#### Vagrant (Local Development)

This command downloads and starts the base Ubuntu box on which the provisioning steps will be run. The output of the `packer` command is a Box that will then be added as `jenkins` on your system. Note that this step may take a while if the `ubuntu/xenial64` box had not yet been downloaded to your system.

```bash
bash build.sh vagrant jenkins
```

To start the vagrant VM locally, run the following steps. You can change the system resources allocated to the VM in the `Vagrantfile` provided.

```bash
cd vagrant/jenkins
vagrant up
```

#### Google Cloud

To be able to provision Google Compute Engine Images, `packer` will essentially be making authenticated API calls to start and stop instances. Access can be granted via the `gcloud` SDK.

```bash
# login to your account (https://cloud.google.com/sdk/gcloud/reference/init)
gcloud init

# set the application default credentials (https://cloud.google.com/sdk/gcloud/reference/auth/application-default/login)
gcloud auth application-default login
```

This command handles the lifecycle on GCP in which an instance will be started on which the provisioning steps will be run, then it'll be stopped and the provisioned image subsequently saved.

**Note**: For this to work on your account, you would have to change the `project` value in `packer/vars/googlecompute.vars` to your GCP project id.

```bash
bash build.sh googlecompute jenkins
```

## Infrastructure Management and Deployment

### Overview

Once the machine image is built, the natural next concern is to set up the surrounding infrastructure as well as deploy the image as an instance. [`terraform`](https://www.terraform.io/) is used to declare and create cloud infrastracture, including deploying the image built in the previous section.

### Requirements

- [terraform](https://www.terraform.io/) >= 0.11 (this has only been tested to work on 0.11.x, but it should be compatible with 0.12)

A core concept in how `terraform` functions is that of [state](https://www.terraform.io/docs/state/purpose.html). This state can be stored as files in a remote file store, such as Google Cloud Storage, which is what this demo has chosen to do. While GCS buckets can be created and managed by `terraform`, this is a one-time procedure and honestly is easier to manually create the bucket via the UI, particularly since there is the limitation that the bucket names have to be globally unique.

Do create the bucket for the state to be stored, then change the values in the `state.tf` files and `terraform/jenkins/main.tf` from `gcp-demo-terraform-state-bucket` to the name of your newly created bucket.

Also do change the `project` values in the `terraform.tfvars` files to your Google Cloud project.

### Setup

This terraform project structure generally follows the concept that `modules` are reusable components across environments. the `dev` directory contains the main entrypoints for the development environment, and should mainly be referencing modules defined in `modules`, and passing in environment specific values. For example to save resources, the dev environment may be the exact same structure as production, but use smaller instance types.

```
├── dev
│   ├── jenkins
│   └── network
└── modules
    ├── backend_service
    ├── jenkins
    └── network
        ├── nat
        ├── subnet
        └── vpc
```

**Note**: For simplicity, the following sections will be assuming you are in the `terraform` directory.

```bash
cd terraform
```

#### Network

This section creates an entirely new VPC, public and private subnets, as well as a [`Cloud NAT`](https://cloud.google.com/nat/docs/overview) resource for the instances in the private subnet to connect to the internet.

```bash
cd dev/network

# compute and review resources that will the changed
terraform plan -out tf.plan

# apply the changes
terraform apply "tf.plan"
```

#### Jenkins

This section creates the resources specific to `jenkins`, including a [HTTP(s) load balancer](https://cloud.google.com/load-balancing/docs/https/) and a [backend service](https://cloud.google.com/load-balancing/docs/backend-service) pointing to a [managed instance group](https://cloud.google.com/compute/docs/instance-groups/creating-groups-of-managed-instances) with an [instance template](https://cloud.google.com/compute/docs/instance-templates/) referencing the `jenkins` image previously created.

```bash
cd dev/jenkins

# compute and review resources that will the changed
terraform plan -out tf.plan

# apply the changes
terraform apply "tf.plan"
```

### Cleaning up

`terraform` can destroy the created resources with the command `terraform destroy` within each of the directories (`terraform/dev/jenkins` and `terraform/dev/network`). Its advised to destroy them in that order as the jenkins resources are dependent on those managed in network.
