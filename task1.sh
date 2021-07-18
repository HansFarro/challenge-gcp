#!/bin/bash
# CONSTANTES (OPCIONAL)
declare -r ZONE="us-central1-c"
declare -r REGION="us-central1"
declare -r CLUSTER_NAME="my-cluster"
declare -r SERVICE_NAME="my-service"
declare -r HOSTNAME_GCP="gcr.io"
declare -r IMAGE="python-app"

# CONSTANTES
declare -r PROJECT_ID=$(jq -r '.project_id' $CREDENTIAL_PATH)
declare -r ACCOUNT_ID=$(gcloud alpha billing accounts list --filter=open=true --format=json | jq -r '.[] | .name' | cut -f2 -d"/")
declare -r CHALLENGE_GCP_PATH=$(pwd)

# FUNCIONES
function change_dir (){
  cd $CHALLENGE_GCP_PATH/$1
}

# REVISAR PARAMETROS: CREATE, DESTROY Y OUTPUT
case $1 in
  CREATE|create)
    echo "Configurar proyecto GCP"
    gcloud config set project $PROJECT_ID
    echo "Instalar componente alpha"
    gcloud components install alpha -q
    echo "Hablitar APIs"
    gcloud services enable container.googleapis.com containerregistry.googleapis.com compute.googleapis.com cloudresourcemanager.googleapis.com run.googleapis.com
    echo "Enlace de billing account con proyecto"
    gcloud alpha billing accounts projects link $PROJECT_ID --billing-account=$ACCOUNT_ID
    echo "Inicializar terraform"
    change_dir terraform/task1 && echo -e "credential_path = "\"$CREDENTIAL_PATH""\""\n""project_id = "\"$PROJECT_ID""\""\n""zone = "\"$ZONE""\""\n""region = \""$REGION\""\n""cluster_name = "\"$CLUSTER_NAME\""" > terraform.tfvars
    terraform init
    terraform fmt
    echo "Crear plan de ejecucion y aplicar"
    terraform plan
    terraform apply -auto-approve
    echo "Obtener credenciales de autenticacion"
    change_dir k8s && gcloud container clusters get-credentials --region $REGION $CLUSTER_NAME
    echo "Instalar Ingress controller de NGINX"
    kubectl apply -f 01-hello-deployment.yml -f 02-service.yml
    helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx && helm repo update
    helm install nginx-ingress ingress-nginx/ingress-nginx --wait
    NGINX_INGRESS_IP=$(kubectl get service nginx-ingress-ingress-nginx-controller -o json | jq -r '.status.loadBalancer.ingress[]?.ip')
    sed -i '10s/$/'$NGINX_INGRESS_IP'.nip.io/' 03-ingress-resource.yml
    kubectl apply -f 03-ingress-resource.yml
    echo "Configurar Docker para autenticarse con Container registry"
    gcloud auth configure-docker -q
    echo "Crear imagen"
    change_dir api-flask && sed -i '7s/$/"Hello world from '$HOSTNAME'"/' app.py
    docker build -t $IMAGE:latest .
    echo "Subir imagen al Container Registry"
    docker tag $IMAGE $HOSTNAME_GCP/$PROJECT_ID/$IMAGE
    docker push $HOSTNAME_GCP/$PROJECT_ID/$IMAGE
    echo "Desplegar una imagen de contenedor"
    gcloud run deploy $SERVICE_NAME --image $HOSTNAME_GCP/$PROJECT_ID/$IMAGE --allow-unauthenticated --region $REGION
    ;;
  DESTROY|destroy)  
    echo "Eliminar imagen del Container Registry"
    gcloud container images delete $HOSTNAME_GCP/$PROJECT_ID/$IMAGE --force-delete-tags -q
    echo "Eliminar servicio"
    gcloud alpha run services delete $SERVICE_NAME --region $REGION -q
    echo "Eliminar manifiestos y NGINX ingress"
    NGINX_INGRESS_IP=$(kubectl get service nginx-ingress-ingress-nginx-controller -o json | jq -r '.status.loadBalancer.ingress[]?.ip')
    change_dir k8s && kubectl delete -f .
    sed -i '10s/'$NGINX_INGRESS_IP'.*//' 03-ingress-resource.yml
    helm del nginx-ingress ingress-nginx/ingress-nginx
    echo "Eliminar imagen de contenedor"
    change_dir api-flask && sed -i '7s/"Hello.*//' app.py
    docker image rm -f $HOSTNAME_GCP/$PROJECT_ID/$IMAGE $IMAGE python:3.6
    echo "Destruir recursos creados con Terraform y archivos descargados"
    change_dir terraform/task1 && terraform destroy -auto-approve
    rm -rf .terraform/ terraform.tf* .terraform.lock.hcl
    ;;
  OUTPUT|output)
    echo "1. Terraform output :"
    change_dir terraform/task1 && terraform output
    echo "2. hello-app NGINX Ingress Controller :"
    echo "http://$(kubectl get ingress ingress-resource -o json | jq -r '.spec.rules[].host')/hello"
    echo "3. URL imagen $IMAGE :"
    echo "$(gcloud alpha run services list --format json | jq -r '.[].status.url')/greetings"
    echo "$(gcloud alpha run services list --format json | jq -r '.[].status.url')/square/10"
    ;;
  *)
    echo "Debes ingresar algun parametro (CREATE, DESTROY O OUTPUT)"
    ;;
esac