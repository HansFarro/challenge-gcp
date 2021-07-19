# Challenge GCP

## Descripción  🚀

Este proyecto consiste principalmente en poder ejecutar dos script bash que automatizan el procedimiento de creación y despliegue de recursos en GCP.

## Pre-requisitos 📋

Para ejecutar los scripts [task1.sh](https://github.com/HansFarro/challenge-gcp/blob/main/task1.sh) y [task2.sh](https://github.com/HansFarro/challenge-gcp/blob/main/task2.sh) debe ejecutar el rol [ansible-role-prerequisites](https://github.com/HansFarro/challenge-gcp/tree/main/ansible-role-prerequisites) para instalar los paquetes necesarios  (se recomienda S.O. Ubuntu 20.04 LTS)  , por otro lado si desea probarlo en una maquina virtual ejecute [prueba-vm.sh](https://github.com/HansFarro/challenge-gcp/blob/main/prueba-vm.sh) que creara una VM en su cuenta  de Google Cloud, pero debe exportar las siguientes variables:

```bash
export CREDENTIAL_PATH=<ruta_credencial>.json
export SSH_USER="<nombre_de_usuario>"
export SSH_PUB_KEY=<ruta_ssh_publica>.pub
```

Una vez instalado debes tener una cuenta de GCP, luego en la consola de GCP crear un Service Account y descargar las credenciales en JSON, por ultimo ejecutar los siguientes comandos como super usuario para autenticarte.

```bash
gcloud init
gcloud auth application-default login
```

## Ejecución ⚙️

Para ejecutar [task1.sh](https://github.com/HansFarro/challenge-gcp/blob/main/task1.sh), solo debes exportar la variable CREDENTIAL_PATH, si lo hiciste omite este paso.

```bash
export CREDENTIAL_PATH=<ruta_credencial>.json
```

Luego debes pasarle un argumento al ejecutar [task1.sh](https://github.com/HansFarro/challenge-gcp/blob/main/task1.sh). Pueden ser CREATE, DESTROY y OUTPUT. **Nota: también puedes escribir los argumentos en minúscula**

```bash
bash task1.sh CREATE | DESTROY | OUTPUT
```

Para ejecutar [task2.sh](https://github.com/HansFarro/challenge-gcp/blob/main/task2.sh), debes exportar las siguientes variables:

```bash
export CREDENTIAL_PATH=<ruta_credencial>.json
export SSH_USER="<nombre_de_usuario>"
export SSH_PUB_KEY=<ruta_ssh_publica>.pub
```

Luego solo ejecuta el script.

```bash
bash task2.sh
```

Para eliminar todo lo creado por el task2.sh (tener un efecto parecido al DESTROY de task1.sh) ejecuta el script [clean-up-task2.sh](https://github.com/HansFarro/challenge-gcp/blob/main/clean-up-task2.sh)

## Construido con 🛠️

- [Google Cloud SDK](https://cloud.google.com/sdk) Interfaz de línea de comandos para productos y servicios de Google Cloud Platform.
- [Terraform](https://www.terraform.io/) Infraestructura como código desarrollado por Hashi Corp.
- [Ansible](https://www.ansible.com/) Herramienta de orquestación (configuración y administración de ordenadores).
- [Helm](https://helm.sh/) Gestor de paquetes para Kubernetes.
- [Bash](https://www.gnu.org/software/bash/) lenguaje de comandos y shell de Unix.
- [Docker](https://www.docker.com/) proyecto de código abierto para automatizar la implementación de aplicaciones como contenedores portátiles y autosuficientes.
- [Kubectl](https://kubernetes.io/docs/reference/kubectl/kubectl/) interfaz de línea de comandos para ejecutar comandos sobre despliegues clusterizados de **Kubernetes**.
- [Flask](https://flask.palletsprojects.com/en/2.0.x/) framework minimalista escrito en Python.

## Licencia  📄

Este proyecto está bajo la Licencia MIT - ver [LICENSE](https://github.com/HansFarro/challenge-gcp/blob/main/LICENSE) para detalles