#!/bin/bash
# CONSTANTES (OPCIONAL)
declare -r REGION="us-central1"
declare -r ZONE="us-central1-c"
declare -r INVENTORY_FILE="inventory"

# CONSTANTES
declare -r PROJECT_ID=$(jq -r '.project_id' $CREDENTIAL_PATH)
declare -r ACCOUNT_ID=$(gcloud alpha billing accounts list --filter=open=true --format=json | jq -r '.[] | .name' | cut -f2 -d"/")
declare -r CHALLENGE_GCP_PATH=$(pwd)

# FUNCIONES
function change_dir (){
  cd $CHALLENGE_GCP_PATH/$1
}

echo "Configurar proyecto GCP"
gcloud config set project $PROJECT_ID
echo "Instalar componente alpha"
gcloud components install alpha -q
echo "Hablitar APIs"
gcloud services enable compute.googleapis.com cloudresourcemanager.googleapis.com
echo "Enlace de billing account con proyecto"
gcloud alpha billing accounts projects link $PROJECT_ID --billing-account=$ACCOUNT_ID
echo "Inicializar terraform"
change_dir terraform/task2 && echo -e "credential_path = "\"$CREDENTIAL_PATH""\""\n""project_id = "\"$PROJECT_ID""\""\n""zone = "\"$ZONE""\""\n""region = \""$REGION""\""\n""gce_ssh_user = \""$SSH_USER""\""\n""gce_ssh_pub_key_file = \""$SSH_PUB_KEY\""" > terraform.tfvars
terraform init
terraform fmt
echo "Crear plan de ejecucion y aplicar"
terraform plan
terraform apply -auto-approve
ip=$(terraform output -json ip | jq -r)
change_dir && echo $ip > $INVENTORY_FILE
echo "Ejecutar playbook"
ansible-playbook -i $INVENTORY_FILE centos-jenkins.yml
