#!/bin/bash
declare -r CHALLENGE_GCP_PATH=$(pwd)
# FUNCIONES
function change_dir (){
  cd $CHALLENGE_GCP_PATH/$1
}

echo "Destruir recursos creados con Terraform y archivos descargados"
change_dir terraform/task2 && terraform destroy -auto-approve
rm -rf .terraform/ terraform.tf* .terraform.lock.hcl
echo "Eliminar inventario"
change_dir && rm inventory