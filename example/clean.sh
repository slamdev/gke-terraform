#!/bin/sh

set -euxo pipefail

TERRAFORM_ADMIN_PROJECT=${1}

GENERATED_CREDENTIALS="credentials.json"

ORGANIZATION_ID=`gcloud organizations list --format="get(name)" | grep -oE "[^/]+$"`
TERRAFORM_ADMIN_PROJECT_ID=`gcloud projects list --filter="name=${TERRAFORM_ADMIN_PROJECT}" --format="get(project_id)"`

rm -rf .terraform/
rm -f terraform.tfvars
rm -f backend.tfvars
rm -f tfplan
rm -f ${GENERATED_CREDENTIALS}

gcloud organizations remove-iam-policy-binding ${ORGANIZATION_ID} \
  --member serviceAccount:terraform@${TERRAFORM_ADMIN_PROJECT_ID}.iam.gserviceaccount.com \
  --role roles/billing.user

gcloud organizations remove-iam-policy-binding ${ORGANIZATION_ID} \
  --member serviceAccount:terraform@${TERRAFORM_ADMIN_PROJECT_ID}.iam.gserviceaccount.com \
  --role roles/resourcemanager.projectCreator

gcloud -q iam service-accounts delete terraform@${TERRAFORM_ADMIN_PROJECT_ID}.iam.gserviceaccount.com

gcloud -q projects delete ${TERRAFORM_ADMIN_PROJECT_ID}
