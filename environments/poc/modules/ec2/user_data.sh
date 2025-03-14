#!/bin/bash
# Install required packages for Amazon Linux 2023
dnf update -y
dnf install -y python3 python3-pip git

# Install AWS CLI and Boto3
pip3 install --upgrade awscli boto3

# Install numpy for the specific models test
pip3 install numpy

# Install LangChain and langchain_aws for easier Bedrock integration
pip3 install langchain langchain_core langchain_aws
