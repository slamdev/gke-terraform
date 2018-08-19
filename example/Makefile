TERRAFORM_ADMIN_PROJECT = terraform-admin
REGION = australia-southeast1
GKE_PROJECT = gke-example
DNS_NAME = example.com.
K8S_USERNAME = admin
K8S_PASSWORD = qwertyasdfghzxcvb

init:
	@./init.sh \
	  $(TERRAFORM_ADMIN_PROJECT) \
	  $(REGION) \
	  $(GKE_PROJECT) \
	  $(DNS_NAME) \
	  $(K8S_USERNAME) \
	  $(K8S_PASSWORD)

clean:
	terraform destroy
	@./clean.sh $(TERRAFORM_ADMIN_PROJECT)

run:
	terraform init -backend-config=backend.tfvars
	terraform plan -out=tfplan
	terraform apply tfplan
