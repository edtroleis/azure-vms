# Create Azure stack
- virtual machine
- sql server database
- storage account

# Set environment

## Create container in storage account to put tfstate files
```
az storage container create -n tfstate --account-name <YourAzureStorageAccountName> --account-key <YourAzureStorageAccountKey>
```

## Configure environment variables
```
https://www.terraform.io/docs/providers/azurerm/guides/service_principal_client_secret.html

# Terraform
export ARM_CLIENT_ID="client_id"
export ARM_CLIENT_SECRET="client_secret_value"
export ARM_SUBSCRIPTION_ID="subscription_id"
export ARM_TENANT_ID="tenant_id"

# Test service principal login
$ az login --service-principal -u CLIENT_ID -p CLIENT_SECRET_VALUE --tenant TENANT_ID
$ az vm list-sizes --location westus
```

# Execute terraform
```
terraform init

or

terraform init -backend-config="storage_account_name=<YourAzureStorageAccountName>" -backend-config="container_name=tfstate" -backend-config="access_key=<YourStorageAccountAccessKey>" -backend-config="key=codelab.microsoft.tfstate"

terraform plan -out out.plan

terraform apply out.plan
*** There will be an error, then from Azure control painel delete resource group "azure-k8stest" and execute "terraform apply out.plan" again.
```
