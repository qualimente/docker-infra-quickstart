FROM centos:7.2.1511

MAINTAINER skuenzli@qualimente.com

ENV PACKAGE_DEPS="jq \
                  make \
                  netcat \
                  unzip \
                  vim \
                  wget \
                  "
RUN yum -y update \
  && yum -y upgrade \
  && yum -y install $PACKAGE_DEPS \
  && yum clean all

ENV PACKER_VERSION 0.12.1
ENV TERRAFORM_VERSION 0.8.2

RUN wget -q -O /tmp/packer.zip "https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip" \
  && unzip /tmp/packer.zip -d /usr/local/bin

RUN wget -q -O /tmp/terraform.zip "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" \
  &&  unzip /tmp/terraform.zip -d /usr/local/bin

ADD packer /work/packer
ADD terraform /work/terraform

VOLUME /src
WORKDIR /work

ADD Dockerfile /Dockerfile
