#!/bin/bash
# Passed validation in Cloud Shell on 2/14/2022

# Service endpoint operations for an Azure Cosmos account
#
# Create an Azure Cosmos Account with a service endpoint connected to a backend subnet
# that is not yet enabled for service endpoints.

# This sample demonstrates how to configure service endpoints for existing Cosmos account where
# the connected subnet is not yet configured for service endpoints.
# This sample will then configure the subnet for service endpoints.

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

# Create a back-end subnet but without specifying --service-endpoints Microsoft.AzureCosmosDB
echo "Creating $backend in $vNet"
az network vnet subnet create --name $backEnd --resource-group $resourceGroup --address-prefix 10.0.2.0/24 --vnet-name $vNet

# Retrieve the value of the service endpoint
svcEndpoint=$(az network vnet subnet show --resource-group $resourceGroup --name $backEnd --vnet-name $vNet --query 'id' -o tsv)

# Create a Cosmos DB account with default values
# Use appropriate values for --kind or --capabilities for other APIs
echo "Creating $account for CosmosDB"
az cosmosdb create --name $account --resource-group $resourceGroup --enable-virtual-network

# Add the virtual network rule but ignore the missing service endpoint on the subnet
az cosmosdb network-rule add --name $account --resource-group $resourceGroup --virtual-network $vNet --subnet $svcEndpoint --ignore-missing-vnet-service-endpoint true

# Update vNet update
az network vnet subnet update --name $backEnd --resource-group $resourceGroup --vnet-name $vNet --service-endpoints Microsoft.AzureCosmosDB

# echo "Deleting all resources"
# az group delete --name $resourceGroup -y
