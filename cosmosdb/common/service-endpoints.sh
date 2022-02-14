#!/bin/bash
# Passed validation in Cloud Shell on 2/14/2022

# Service endpoint operations for an Azure Cosmos account
#
# Create an Azure Cosmos Account with a service endpoint connected to a backend subnet

# Resource group and Cosmos account variables
let "randomIdentifier=$RANDOM*$RANDOM"
location="East US"
resourceGroup="msdocs-cosmosdb-rg-$randomIdentifier"
tags="service-endpoints-cosmosdb"
account="msdocs-account-cosmos-$randomIdentifier" #needs to be lower case
vNet='msdocs-vnet-cosmosdb'
frontEnd='msdocs-front-end-cosmosdb'
backEnd='msdocs-back-end-cosmosdb'

# Create a resource group
echo "Creating $resourceGroup in $location..."
az group create --name $resourceGroup --location "$location" --tag $tag

# Create a virtual network with a front-end subnet
echo "Creating $vnet"
az network vnet create --name $vNet --resource-group $resourceGroup --address-prefix 10.0.0.0/16 --subnet-name $frontEnd --subnet-prefix 10.0.1.0/24

# Create a back-end subnet
echo "Creating $backend in $vNet"
az network vnet subnet create --name $backEnd --resource-group $resourceGroup --address-prefix 10.0.2.0/24 --vnet-name $vNet --service-endpoints Microsoft.AzureCosmosDB

# Retrieve the value of the service endpoint
svcEndpoint=$(az network vnet subnet show --resource-group $resourceGroup --name $backEnd --vnet-name $vNet --query 'id' -o tsv)

# Create a Cosmos DB account with default values and service endpoints
# Use appropriate values for --kind or --capabilities for other APIs
echo "Creating $account for CosmosDB"
az cosmosdb create --name $account --resource-group $resourceGroup --enable-virtual-network true --virtual-network-rules $svcEndpoint

# echo "Deleting all resources"
# az group delete --name $resourceGroup -y
