#!/bin/bash
# CONSTANTES (OPCIONAL)
declare -r REGION="us-central1"
declare -r ZONE="us-central1-c"

# CONSTANTES
declare -r PROJECT_ID=$(jq -r '.project_id' $CREDENTIAL_PATH)
declare -r CHALLENGE_GCP_PATH=$(pwd)

# FUNCIONES
function change_dir (){
  cd $CHALLENGE_GCP_PATH/$1
}

echo "Inicializar terraform"
change_dir terraform/vm && echo -e "credential_path = "\"$CREDENTIAL_PATH""\""\n""project_id = "\"$PROJECT_ID""\""\n""zone = "\"$ZONE""\""\n""region = \""$REGION""\""\n""gce_ssh_user = \""$SSH_USER""\""\n""gce_ssh_pub_key_file = \""$SSH_PUB_KEY\""" > terraform.tfvars
terraform init
terraform fmt
echo "Crear plan de ejecucion y aplicar"
terraform plan
terraform apply -auto-approve
ip=$(terraform output -json ip | jq -r)
echo "Conectar por SSH con el comando : ssh $SSH_USER:$ip"