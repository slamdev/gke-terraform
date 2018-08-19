#!/bin/sh

set -euxo pipefail

TERRAFORM_ADMIN_PROJECT=${1}
REGION=${2}
GKE_PROJECT=${3}
DNS_NAME=${4}
K8S_USERNAME=${5}
K8S_PASSWORD=${6}

GENERATED_CREDENTIALS="credentials.json"

ORGANIZATION_ID=`gcloud organizations list --format="get(name)" | grep -oE "[^/]+$"`
BILLING_ACCOUNT_ID=`gcloud beta billing accounts list --format="get(name)" | grep -oE "[^/]+$"`
RANDOM_ID=`openssl rand -hex 3`
TERRAFORM_ADMIN_PROJECT_ID="${TERRAFORM_ADMIN_PROJECT}-`openssl rand -hex 4`"

##
## Setup Google Cloud Project
##

# Create admin project
gcloud projects create ${TERRAFORM_ADMIN_PROJECT_ID} --set-as-default \
  --name=${TERRAFORM_ADMIN_PROJECT} --organization=${ORGANIZATION_ID}
# Enable project billing
gcloud beta billing projects link ${TERRAFORM_ADMIN_PROJECT_ID} --billing-account ${BILLING_ACCOUNT_ID}
# Create service account for terraform
gcloud iam service-accounts create terraform --display-name "Terraform admin account"
# Generate json key for service account
gcloud iam service-accounts keys create ${GENERATED_CREDENTIALS} \
  --iam-account terraform@${TERRAFORM_ADMIN_PROJECT_ID}.iam.gserviceaccount.com
# Allow service account to view project
gcloud projects add-iam-policy-binding ${TERRAFORM_ADMIN_PROJECT_ID} \
  --member serviceAccount:terraform@${TERRAFORM_ADMIN_PROJECT_ID}.iam.gserviceaccount.com \
  --role roles/viewer
# Allow service account to manage Google Storage
gcloud projects add-iam-policy-binding ${TERRAFORM_ADMIN_PROJECT_ID} \
  --member serviceAccount:terraform@${TERRAFORM_ADMIN_PROJECT_ID}.iam.gserviceaccount.com \
  --role roles/storage.admin
# Enable required services
gcloud services enable cloudresourcemanager.googleapis.com \
  && gcloud services enable cloudbilling.googleapis.com \
  && gcloud services enable iam.googleapis.com \
  && gcloud services enable compute.googleapis.com \
  && gcloud services enable sqladmin.googleapis.com \
  && gcloud services enable container.googleapis.com
# Allow service account to create projects
gcloud organizations add-iam-policy-binding ${ORGANIZATION_ID} \
  --member serviceAccount:terraform@${TERRAFORM_ADMIN_PROJECT_ID}.iam.gserviceaccount.com \
  --role roles/resourcemanager.projectCreator
# Allow service account to enable billing for projects
gcloud organizations add-iam-policy-binding ${ORGANIZATION_ID} \
  --member serviceAccount:terraform@${TERRAFORM_ADMIN_PROJECT_ID}.iam.gserviceaccount.com \
  --role roles/billing.user
# Create Google Storage bucket to save terraform state
gsutil mb -p ${TERRAFORM_ADMIN_PROJECT_ID} -l ${REGION} gs://${TERRAFORM_ADMIN_PROJECT_ID}
# Enable versioning for Google Storage bucket
gsutil versioning set on gs://${TERRAFORM_ADMIN_PROJECT_ID}

##
## Generate Terraform variables
##

# backend.tfvars
cat > backend.tfvars <<EOF
credentials = "${GENERATED_CREDENTIALS}"
bucket = "${TERRAFORM_ADMIN_PROJECT_ID}"
prefix = "${GKE_PROJECT}"
EOF

# terraform.tfvars
cat > terraform.tfvars <<EOF
gce_credentials = "${GENERATED_CREDENTIALS}"
project_name = "${GKE_PROJECT}"
region = "${REGION}"
billing_account = "${BILLING_ACCOUNT_ID}"
organization_id = "${ORGANIZATION_ID}"
dns_name = "${DNS_NAME}"
k8s_username = "${K8S_USERNAME}"
k8s_password = "${K8S_PASSWORD}"
EOF
