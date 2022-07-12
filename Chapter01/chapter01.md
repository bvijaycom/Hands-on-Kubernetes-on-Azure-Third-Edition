# AZURE Kubernetes Automation

# Before start this excercise,you must have running Rocky linux 8 machine.

# Architecture

[![Watch the image](/architecture.png)]



# AZURE VM
 - Create 1 Rocky Linux 8.5 machine in the AZURE Cloud Portal
 - Note that this will work only in 'Pay-As-You-Go' Subscription and not on Free Tier
 - Make sure you open RDP,http,8080 ports for this new linux AZURE VM or you can also open any port by using port*any
 - Have Mobaxterm/ Putty installed. ** Note: We can use the PowerShell also, but in realtime production environment, Mobaxterm is the best option when we try to work on a junk server and push to the PROD.



# Steps

- Step 1:  Install AZURE CLI in Rocky Linux Virtual Machine
- Step 2:  First install docker in the local linux machine
- Step 3:  Download a sample application
- Step 4:  Test the sample application
- Step 5:  Deploy and use Azure Container Registry
- Step 6:  Install kubectl command 
- Step 7:  Deploy an Azure Kubernetes Service (AKS) cluster
- Step 8:  Run applications in Azure Kubernetes Service (AKS)
- Step 9:  Scale application in Azure Kubernetes Service (AKS)
- Step 10: Update the application in Azure Kubernetes Service (AKS)


#

# Step 1: Install AZURE CLI

- Add the azure CLI Repository keys
```
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
```
- Configure the azure CLI Repository

```
sudo sh -c 'echo -e "[azure-cli]
name=Azure CLI
baseurl=https://packages.microsoft.com/yumrepos/azure-cli
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/azure-cli.repo'
```
- Install Azure CLI

```
sudo yum install azure-cli -y
```

- Login and sync your Azure CLI (Linux machine) to your portal.azure.com account

```
az login
```

- Now your linux machine has been fully authenticated with AZURE login.  

# Step 2 - first install docker in the local linux machine

```
 yum install epel-release -y
 yum repolist
```

## Step 2.1 - Install the required dependencies:

```
yum install yum-utils device-mapper-persistent-data lvm2  bash-completion -y
```

```
source /etc/profile.d/bash_completion.sh
```


## Step 2.2 - Add the stable Docker repository by typing:

```
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
```

## Step 2.3 - Now that we have Docker repository enabled, we can install the latest version of Docker CE (Community Edition) using yum by typing:

```
yum install docker-ce --allowerasing -y

```

## Step 2.4 - Install Docker Compose and Test the Docker-Compose Version:


- Run the below command to download the current stable release of Docker compose.

```
curl -L "https://github.com/docker/compose/releases/download/1.26.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/bin/docker-compose
```

- Apply the executable permission for the binary file which we have downloaded.

```
chmod +x /usr/bin/docker-compose
```

- If the docker compose is installed on a different location For example: /usr/local/bin/ , You can copy the executable to /usr/bin directory.

- You can check the version of docker-compose using the below command.

```
docker-compose --version
```


## Step 2.5 - Once the Docker package is installed, we start the Docker daemon with:

```
systemctl start docker;systemctl status docker;systemctl enable docker
```

## Step 2.6 - At the time of the writing of this article, the current stable version of Docker is 20.10.15, we can check our Docker version by typing:

```
docker -v
```


# Step 3: Download sample application

```
yum install git tree -y

```
- Download the sample azure application

```
git clone https://github.com/cloudnloud/azure-voting-app-redis.git
```

```
cd azure-voting-app-redis
```
- Build the docker image using docker compose

```
docker-compose up -d
```
- list the docker images

```
docker images
```

- list the running docker container

```
docker ps -a
```

# Step 4: Test sample application

- Test application locally

- To see the running application, enter curl -k http://localhost:8080 in a local linux machine command prompt

- open 8080 port in the VM --> networking.Then only the below will work

- To see the running application, enter http://<your VM Public IP>:8080 in a local web browser


# Step 5: Docker image General Commands

- To start a new container, you need an image. An image contains all the software
you need to run within your container. Container images can be stored locally on
your machine, as well as in a container registry. There are public registries, such
as the public Docker Hub (https://hub.docker.com/), or private registries, such as
ACR. When you, as a user, don't have an image locally on your PC, you can pull an
image from a registry using the docker pull command.
In the following example, we will pull an image from the public Docker Hub
repository and run the actual container. You can run this example in Docker Labs, 

- In the previous example, you learned that it is possible to run a container without
building an image first. It is, however, very common that you will want to build
your own images. To do this, you use a Dockerfile. A Dockerfile contains steps
that Docker will follow to start from a base image and build your image. These
instructions can range from adding files to installing software or setting up
networking. 

```
docker pull cloudnloud/azurek8s
```

- ## First we will pull an image
```
docker pull cloudnloud/azurek8s
```

- # We can then look at which images we have locally

```
docker images
```

- # Then we will run our container

```
docker run cloudnloud/azurek8s cowsay boo
```

# Step 6: Build custom docker image

- In the next example, you will build a custom Docker image. This custom image will
display inspirational quotes in the whale output. The following Dockerfile will be
used to generate this custom image. You will create it in your Docker playground:

```
vi Dockerfile
```

```
FROM cloudnloud/azurek8s:latest
RUN apt-get -y -qq update
RUN apt-get install -qq -y fortunes
CMD /usr/games/fortune -a | cowsay
```

Save and exit

```
docker build .
```

[or]

if you want to convert to your custom image along with specific repo name then use the below command

assume your docker repo name is cloudnloud/azurek8s 

then 
```
docker build -t cloudnloud/azurek8s .
```
```
docker run cloudnloud/azurek8s:latest
```
 
# Step 5: Deploy and use Azure Container Registry

- Create AZURE resource Group

```
az group create --name  cloudnloudrg --location eastus
```

- Create AZURE Container Registry Under the above Created Resource Group.


```
az acr create --resource-group cloudnloudrg --name cnlacr1 --sku Basic
```

- Login to the Azure Container registry


```
az acr login --name cnlacr1
```

- List the Docker Images


```
docker images
```

- List the no of ACR in your portal.azure.com


```
az acr list --resource-group cloudnloudrg --query "[].{acrLoginServer:loginServer}" --output table
```

- you will get the below output.So your AZURE Container Registry Name is below ...


```
cnlacr1.azurecr.io
```


- you need to change the docker image name towards to match your ACR repo name.Or else while you push the image will end up with error.


```
docker tag cloudnloud/azure-vote-front:v1 cnlacr1.azurecr.io/azure-vote-front:v1
```
- List the docker images

- Make sure you are seeing the docker image name with match to your ACR repository.

```
docker images
```
- Push your prepared custom image to your newly created ACR.

```
docker push cnlacr1.azurecr.io/azure-vote-front:v1
```

- list the ACR repository revisions

```
az acr repository list --name cnlacr1 --output table
```
- List your repository in ACR.

```
az acr repository show-tags --name cnlacr1 --repository azure-vote-front --output table
```


# Step 6: install kubectl command 

- Configure Kubernetes Software package repo.

```
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
```

- Install Kubectl

```
yum install -y kubectl
```

- To ensure all are ok the following command should work without any error

```
kubectl version --client
```

# Step 7: Deploy an Azure Kubernetes Service (AKS) cluster

- Create kubernetes Cluster with 1 worker Node

- In your learning setup,if you have project portal.azure.com test account then increase node count from 1 to 3.


```
az aks create \
    --resource-group cloudnloudrg \
    --name myAKSCluster \
    --node-count 1 \
    --generate-ssh-keys \
    --attach-acr cnlacr1
	
```
- Install AZURE AKS CLI

```
az aks install-cli
```
- Reterive the AKS cluster credentials.This will help kubectl command to run without any issues.

```
az aks get-credentials --resource-group cloudnloudrg --name myAKSCluster
```
- List all the nodes in Kubernetes cluster.

```
kubectl get nodes
```


# Step 8: Run applications in Azure Kubernetes Service (AKS)

- List the ACR 

```
az acr list --resource-group cloudnloudrg --query "[].{acrLoginServer:loginServer}" --output table
```
- Change your front end to your recently deployed own image repo.

```
vi azure-vote-all-in-one-redis.yaml
```


```
containers:
- name: azure-vote-front
  image: cnlacr1.azurecr.io/azure-vote-front:v1
```
- Create namespace in AKS k8s cluster.

```
kubectl create ns dev
```
- Apply the changes into AKS k8s cluster.

```
kubectl apply -f azure-vote-all-in-one-redis.yaml -n dev
```
- Monitor the change progress.

```
kubectl get service azure-vote-front --watch -n dev
```


- from the above command output get the EXTERNAL-IP and access it from browser


# Step 9: Scale applications in Azure Kubernetes Service (AKS)

- in another mobaxtreme window run the following command

```
watch -n 1 kubectl get all -o wide -n dev
```


- in another mobaxtreme window run the below commands

```
kubectl get pods -n dev
```
- in another mobaxtreme window run the below commands

```
kubectl scale --replicas=2 deployment/azure-vote-front -n dev
```

```
kubectl scale --replicas=4 deployment/azure-vote-front -n dev
```


# Step 10: Update an application in Azure Kubernetes Service (AKS)

- Now we need to make some change in application

```
vi azure-vote/azure-vote/config_file.cfg
```

```
## UI Configurations
TITLE = 'Save Cancer Children - Cloudnloud'
VOTE1VALUE = 'Learn'
VOTE2VALUE = 'Grow'
SHOWHOST = 'false'

```
- Build the Docker image with v2.
```
docker-compose up --build -d
```


- you need to change the docker image name towards to match your ACR repo name.Or else while you push the image will end up with error.


```
docker tag cloudnloud/azure-vote-front:v1 cnlacr1.azurecr.io/azure-vote-front:v2
```

- Push your prepared custom image to your newly created ACR.

```
docker push cnlacr1.azurecr.io/azure-vote-front:v2
```

- Scale your pods to 4 replicas
```
watch -n 1 kubectl get all -o wide -n dev
```
```
kubectl scale --replicas=4 deployment/azure-vote-front -n dev
```
- Set and prepare your deployment to new version 2
```
kubectl set image deployment azure-vote-front azure-vote-front=cnlacr1.azurecr.io/azure-vote-front:v2 -n dev
```

- Run below command
```
kubectl get service azure-vote-front -n dev
```
	

# Demo Application Deployment
	
```
kubectl create ns k8sapp
kubectl apply -f https://raw.githubusercontent.com/bvijaycom/Hands-on-Kubernetes-on-Azure-Third-Edition/main/Chapter02/azure-vote.yaml -n k8sapp
kubectl get all -n k8sapp -o wide

```

# Class 3

# Deploying the Redis master

	```
kubectl create ns k8sdb
kubectl apply -f https://raw.githubusercontent.com/bvijaycom/Hands-on-Kubernetes-on-Azure-Third-Edition/main/Chapter03/redis-master-deployment.yaml -ns k8sdb
	
watch -n 1 kubectl get all -o wide -n k8sdb
```

	
- Now You have now launched a Redis master with the default configuration. Typically, you would launch an application with an environment-specific configuration.
In the next section, you will get acquainted with a new concept called ConfigMaps and then recreate the Redis master. So, before proceeding, clean up the current
version, which you can do by running the following command:

```
kubectl delete deployment/redis-master -n k8sdb
```

# Redis master with a ConfigMap

**What is config Map** ** What is the use of it**



A ConfigMap is a portable way of configuring containers without having specialized images for each environment. It has a key-value pair for data that needs to be set on a container. A ConfigMap is used for non-sensitive configuration. Kubernetes has a separate object called a Secret. A Secret is used for configurations that
contain critical data such as passwords.

- now create your ConfigMap via the following command
```
kubectl apply -f https://raw.githubusercontent.com/bvijaycom/Hands-on-Kubernetes-on-Azure-Third-Edition/main/Chapter03/example-redis-config.yaml -n k8sdb
	
kubectl describe configmap/example-redis-config -n k8sdb
```

	
kubectl apply -f https://raw.githubusercontent.com/bvijaycom/Hands-on-Kubernetes-on-Azure-Third-Edition/main/Chapter03/redis-master-deployment_Modified.yaml -n k8sdb 
	
watch -n 1 kubectl get all -n k8sdb -o wide

- from above command output get the pod name 
- Then exec into the pod and verify that the settings were applied:
	
kubectl exec -it redis-master-766c5cf5c8-wzq9t -n k8sdb -- redis-cli
	
This open a redis-cli session with the running pod. Now you can get the
maxmemory configuration:

CONFIG GET maxmemory
	
And then you can get the maxmemory-policy configuration:
CONFIG GET maxmemory-policy

To summarize, you have just performed an important part of configuring cloudnative applications, namely providing dynamic configuration data to an application.
You will have also noticed that the apps have to be configured to read config dynamically. After you set up your app with configuration
	
# Exposing the Redis master service

kubectl apply -f https://raw.githubusercontent.com/bvijaycom/Hands-on-Kubernetes-on-Azure-Third-Edition/main/Chapter03/redis-master-service.yaml -n k8sdb
	
- now login inside redis pod and test the DNS name with pinging


kubectl exec -it redis-master-766c5cf5c8-wzq9t bash -n k8sdb

ping redis-master

press ctrl + C

# Deploying the Redis replicas

Running a single back end on the cloud is not recommended. You can configure Redis in a leader-follower (master-slave) setup. This means that you can have
a master that will serve write traffic and multiple replicas that can handle read traffic. It is useful for handling increased read traffic and high availability.
Let's set this up:

- 1. Create the deployment by running the following command:
```
kubectl apply -f https://raw.githubusercontent.com/bvijaycom/Hands-on-Kubernetes-on-Azure-Third-Edition/main/Chapter03/redis-replica-deployment.yaml -n k8sdb
```

- Like the master service, you need to expose the replica service by running the following:
```
kubectl apply -f https://raw.githubusercontent.com/bvijaycom/Hands-on-Kubernetes-on-Azure-Third-Edition/main/Chapter03/redis-replica-service.yaml -n k8sdb
```
- The only difference between this service and the redis-master service is that this service proxies traffic to pods that have the role:replica label.

  - now if you login to the redis master pod and try to ping **redis-replica** 
```
  kubectl exec -it redis-master-766c5cf5c8-wzq9t bash -n k8sdb
  
  ping redis-replica
```
  
# Deploying and exposing the front end
- Up to now, you have focused on the Redis back end. Now you are ready to deploy the front end. This will add a graphical web page to your application that you'll be
able to interact with.

```
kubectl apply -f https://raw.githubusercontent.com/bvijaycom/Hands-on-Kubernetes-on-Azure-Third-Edition/main/Chapter03/frontend-deployment.yaml -n k8sdb

```

# Exposing the front-end service

kubectl apply -f https://raw.githubusercontent.com/bvijaycom/Hands-on-Kubernetes-on-Azure-Third-Edition/main/Chapter03/frontend-service.yaml -n k8sdb

watch -n 1 kubectl get all -n k8sdb -o wide
  
- take the frontend service public IP and access it from any browser in internet

- **Congratulations – you have completed your first fully deployed, multi-tier,cloud-native Kubernetes application**
  
