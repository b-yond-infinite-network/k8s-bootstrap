# Kubernetes Bootstrap

The purpose of this tool is to facilitate the creation of Kubernetes Clusters in different Cloud Providers.

## Requirements

### Using Docker
With Docker installed you just need to build the image locally

```
docker build -t docker-k8s-bootstrap .
```

All the commands described in sections below can be run from inside the container with:

```
docker run -it --rm -v ${PWD}:/work -w /work --entrypoint /bin/bash docker-k8s-bootstrap
```

### Without using Docker

The only requirement to run the bootstrap is `Terraform`, please check [install terraform cli](https://learn.hashicorp.com/tutorials/terraform/install-cli#install-terraform)

```
# Linux Example

curl -o /tmp/terraform.zip -LO https://releases.hashicorp.com/terraform/0.13.6/terraform_0.13.6_linux_amd64.zip

unzip /tmp/terraform.zip
chmod +x terraform && mv terraform /usr/local/bin/
```

Depending on the supported cloud provided a specific CLI will be needed:

- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)

## Azure Preparation

### Login to Azure
```
#login and follow prompts
az login
```

### View and select your subscription account (column SubscriptionId)

From the obtained list, select the Subscription Id to be used.

```
az account list -o table
SUBSCRIPTION_ID=<id>

# Run this if different from actual.
az account set --subscription $SUBSCRIPTION_ID
```

### Obtain Tenant Id

```
TENANT_ID=$(az account show --subscription $SUBSCRIPTION_ID | jq -r '.tenantId')
echo $TENANT_ID
```

### Create Service Principal

The bootstrap (Terraform) needs [Service Principal Credentials](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_client_secret). Create one if needed.

```
SERVICE_PRINCIPAL_JSON=$(az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/SUBSCRIPTION_ID")

echo $SERVICE_PRINCIPAL_JSON

CLIENT_ID=$(echo $SERVICE_PRINCIPAL_JSON | jq -r '.appId')
CLIENT_SECRET=$(echo $SERVICE_PRINCIPAL_JSON | jq -r '.password')

```

- Login to test credentials:

```
az login --service-principal -u $CLIENT_ID -p $CLIENT_SECRET --tenant $TENANT_ID

az account list-locations -o table

az logout
```

### Create Storage (Optional)
It is recommended to store the Terraform state files in a remote storage on the cloud, we can create one if needed using the following commands (adjust the names accordingly):

- Login using your user and not the principal created above.
```
az login
```
```
#!/bin/bash

RESOURCE_GROUP_NAME=k8s-bootstrap
STORAGE_ACCOUNT_NAME=k8sbootstrap$RANDOM
CONTAINER_NAME=k8s-bootstrap

# Create resource group
az group create --name $RESOURCE_GROUP_NAME --location eastus

# Create storage account
az storage account create --resource-group $RESOURCE_GROUP_NAME --name $STORAGE_ACCOUNT_NAME --sku Standard_LRS --encryption-services blob

# Get storage account key
ACCOUNT_KEY=$(az storage account keys list --resource-group $RESOURCE_GROUP_NAME --account-name $STORAGE_ACCOUNT_NAME --query '[0].value' -o tsv)

# Create blob container
az storage container create --name $CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME --account-key $ACCOUNT_KEY

echo "storage_account_name: $STORAGE_ACCOUNT_NAME"
echo "container_name: $CONTAINER_NAME"
echo "access_key: $ACCOUNT_KEY"
```

- These values can be used in the values file (infra.yaml)

Reference: [store-state-in-azure-storage](https://docs.microsoft.com/en-us/azure/developer/terraform/store-state-in-azure-storage)

### Prepare your values file

Duplicate/edit `infra.yaml` file to configure these properties (Azure example):

| Property Name       | Description                                                                           |
|---------------------|---------------------------------------------------------------------------------------|
| cloud_provider      | The only valid value for now is `azure`.                                              |
| subscription_id     | Your account subscription id, e.g. $SUBSCRIPTION_ID obtained above.                   |
| tenant_id           | Your account tenant id, e.g. $TENANT_ID obtained above.                               |
| client_id           | Service Principal Id, e.g. $CLIENT_ID obtained above.                                 |
| client_secret       | Service Principal Secret, e.g. $CLIENT_SECRET obtained above.                         |
| location            | Azure Location, a list can be obtained with `az account list-locations -o table`      |
| backend.container_name         |  The name of the blob container. When not defined, tfstate files will be stored locally in the `./output` directory  |
| backend.resource_group_name        |  The name of the resource group where the Azure Storage account is located.                                                |
| backend.storage_account_name         | The name of the Azure Storage account.  |
| backend.access_key         | The storage access key. When not defined an `az login` will be required prior to the bootstrap execution.  |
| aks.cluster_name        | Name of the AKS cluster to be created.                                                |
| aks.k8s_version         | Kubernetes version to be installed. One of: `az aks get-versions -l eastus -o table`  |


For other properties, check the comments in the properties file and put the appropriate ones in each case.

## Create infrastructure

- Change directory to where `k8s-bootstrap` file is located
- To check what will be created
```
chmod +x k8s-bootstrap
./k8s-bootstrap apply --dry-run
```
- To apply the changes, run and answer the questions.
```
./k8s-bootstrap apply
```
- To test the cluster, once the process is completed, run:
```
export KUBECONFIG=${PWD}/output/kube_config

kubectl get nodes -o wide
```

- To access the underlying VMs run
```
eval `ssh-agent -s`
ssh-add ./output/id_rsa
ssh -i ./output/id_rsa -J ubuntu@<bastion_public_ip> ubuntu@<private_vm_ip>
```

> :warning: **Make sure to securely save the tfstate files**
> It will be needed for updates or to delete the cluster.

## Clean up infrastructure

> :warning: **Make sure to remove the assosiation between the Ambassador service and pulic IP**

```
kubectl delete svc -n ambassador ambassador
```

- Recommended Cleanup
```
./k8s-bootstrap destroy
```

- Or this one will delete all the resources directly (not recommended):
```
az group delete -n <resource-group>
```

- In case you want to delete a created Service Principal
```
az ad sp delete --id $CLIENT_ID
```