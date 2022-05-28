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