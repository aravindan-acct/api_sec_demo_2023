# Petstore API Server

API Security Demo Setup 


### Deployment

This repo contains an ARM template for deploying the code on a Ubuntu server in Microsoft Azure.
To launch the template from azure cli:

`az deployment group create --name <name> --resource-group <rg-name> --template-file azuredeploy.json`

- Listening port for the server is 8080

#### API access

Access the API documentation / swagger page by accessing:

`http://<ip>:8080/api/petstore/1.0.0/ui/#`