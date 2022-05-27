#First we will pull an image
docker pull cloudnloud/azurek8s

#We can then look at which images we have locally
docker images

#Then we will run our container
docker run cloudnloud/azurek8s cowsay boo
