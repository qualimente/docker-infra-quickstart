# Overview #

The docker-infra-quickstart repo is a collection of tools that simplify bootstrapping a Docker-centric infrastructure.

The quickstart uses:

* [packer](https://www.packer.io/) for building Amazon Machine Images (CentOS 7 base)
* [terraform](https://www.terraform.io/) for provisioning infrastructure
* [Amazon Web Services](https://aws.amazon.com/) as an infrastructure provider

The quickstart will provision a docker swarm:

* in a Virtual Private Cloud in a single AWS region
* using a segmented, and further segmentable network
* across 3 availability zones
* with management/control planes separated from worker/data planes
* with 'principle of least privilege' applied 

# Getting Started #

Install a [terraform release](https://www.terraform.io/downloads.html).

Export your AWS credentials as environment variables:

```
export AWS_ACCESS_KEY_ID='id-xyz'
export AWS_SECRET_ACCESS_KEY='super-secret access key - do not put in source control'
```

Change into the terraform directory:

```
cd terraform
```

Set-up modules needed by terraform plan:

```
terraform get
```

Inspect what terraform plans to do (a lot on first run!):

```
terraform plan
```

Apply the plan (this will cost some money, though should be less than $100 if just playing around for a day):

```
terraform apply
```

# Customizing #

By default, the quickstart will deploy the cluster into the us-west-2 region (Oregon) using a VPC network of `10.42.0.0/16`.  
If you would like to change these or how many availability zones are used, please update terraform/main.tf


# Roadmap #

- [x] define VPC with production-like segmented network using terraform
- [ ] provide Dockerfile and wrapper scripts to facilitate use of quickstart tooling
- [ ] define packer.json for CentOS 7 w/ Docker +1.12
- [ ] deploy Swarm using Docker +1.12 swarm mode
