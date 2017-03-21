#!/usr/bin/env bash
set -e

SCRIPT_DIR=`dirname $0`

# test the repo's default terraform plan
DEFAULT_PLAN_DIR="${SCRIPT_DIR}/../"
terraform get "${DEFAULT_PLAN_DIR}"
terraform validate "${DEFAULT_PLAN_DIR}"
terraform plan -no-color -out=tf-test-plan.out "${DEFAULT_PLAN_DIR}"
