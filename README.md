# Kubernetes Bootstrap

The purpose of this tool is to facilitate the creation of Kubernetes Clusters in different Cloud Providers.

## Requirements

The only requirement to run the bootstrap is `Terraform`, please check [install terraform cli](https://learn.hashicorp.com/tutorials/terraform/install-cli#install-terraform)

```
# Linux Example

curl -o /tmp/terraform.zip -LO https://releases.hashicorp.com/terraform/0.12.28/terraform_0.12.28_linux_amd64.zip

unzip /tmp/terraform.zip
chmod +x terraform && mv terraform /usr/local/bin/
```

Depending on the supported cloud provided a specific CLI will be needed:

- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)


## Azure Preparation

- Login to Azure
```
#login and follow prompts
az login
```

- View and select your subscription account (column SubscriptionId)

From the obtained list, select the Subscription Id to be used.

```
az account list -o table
SUBSCRIPTION_ID=<id>

# Run this if different from actual.
az account set --subscription $SUBSCRIPTION_ID
```

- Obtain Tenant Id

```
TENANT_ID=$(az account show --subscription $SUBSCRIPTION_ID | jq -r '.tenantId')
echo $TENANT_ID
```

- Create Service Principal

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

- Prepare your properties file

Duplicate/edit `cluster.properties` file to configure these mandatory properties (Azure example):

| Property Name       | Description                                                                           |
|---------------------|---------------------------------------------------------------------------------------|
| cloud_provider      | The only valid value for now is `azure`.                                              |
| subscription_id     | Your account subscription id, e.g. $SUBSCRIPTION_ID obtained above.                   |
| tenant_id           | Your account tenant id, e.g. $TENANT_ID obtained above.                               |
| client_id           | Service Principal Id, e.g. $CLIENT_ID obtained above.                                 |
| client_secret       | Service Principal Secret, e.g. $CLIENT_SECRET obtained above.                         |
| cluster_name        | Name of the AKS cluster to be created.                                                |
| location            | Azure Location, a list can be obtained with `az account list-locations -o table`      |
| resource_group_name | Name of the resource group that will be created.                                      |
| k8s_version         | Kubernetes version to be installed. One of: `az aks get-versions -l eastus -o table`  |


For other properties, check the comments in the properties file and put the appropriate ones in each case.

## Create infrastructure

- Change directory to where `k8s-bootstrap` file is located
- To check what will be created
```
chmod +x k8s-bootstrap
./k8s-bootstrap --dry-run
```
- To apply the changes, run and answer the questions.
```
./k8s-bootstrap
```
- To test the cluster, once the process is completed, run:
```
KUBECONFIG=$(pwd)/kube_config

kubectl get nodes -o wide
```

> :warning: **Make sure to securely save the tfstate file**
> It will be needed for updates or to delete the cluster.

## Clean up infrastructure

- Recommended
```
./k8s-bootstrap --destroy
```

- Or this one will delete all the resources directly (not recommended):
```
az group delete -n <resource-group>
```

- In case you want to delete a created Service Principal
```
az ad sp delete --id $CLIENT_ID
```