# Petstore API Server

API Security Demo Setup With Barracuda WAAS


### Deployment

This repo contains ARM templates for deploying frontend and backend code on Ubuntu servers in Microsoft Azure.

#### Backend API Server

To launch the template for the API server from azure cli:

`az deployment group create --name <name> --resource-group <rg-name> --template-file backend_deploy.json`

    - Listening port for the server is 8080
    - Access the API documentation / swagger page by accessing: 
`http://<ip>:8080/api/petstore/1.0.0/ui/#`

To launch the template for the frontend UI Web Application from azure cli:

`az deployment group create --name <name> --resource-group <rg-name> --template-file frontend_deploy.json`

    - Listening port for the server is 443 - (The deployment uses an NGINX installation to proxy the traffic to the web app)
    - To complete the initial setup:
        - Access the url - `https://<public-ip>/settings/starturl` , provide the inputs for the various fields and hit submit.
        - Completing the initial setup is important to ensure that right parameters are set for the web application
    - To access the application - `https://<public-ip>/admin`

#### General notes:
1. The template uses some good defaults but can be overridden if needed to supply different values as parameter inputs.

        


