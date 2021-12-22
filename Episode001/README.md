## Scenario
A new Web Application is being deployed. The deployment completes without and errors. But when browsing the Web Appllication we get an error message `:( Application Error` with HTTP Status code 503.

## Steps to setup this lab

1. Git Clone
   
   `git clone https://github.com/vijayshinva/DebugAngel`
2. Change directory to Episode001

    `cd Episode001`
3. Login to Azure if needed
   
   `az login`
4. Create a Resource Group. You can change the name and location as needed.
   
   `az group create --name Episode001 --location eastus`
5. Deploy the bicep template.

   `az deployment group create --resource-group Episode001 --template-file episode001.bicep`
6. Check the resources created. Resource names are random strings generated based on the Resource Group name to avoid any conflicts.
   * Virtual Network
   * Network Security Group
   * Web App plan
   * Web Site

7. At this point you should be able to follow the corresponding Video and complete the lab. Follow the steps below to properly clean up resources. 

8. Remove VNET integration before deleting the Web App. Replace the web app name and resource-group names as needed.

   `az webapp vnet-integration remove --resource-group Episode001 --name app-q247ouguhstis`
9. Remove the subnet delegation from the vnet. Replace the vnet-name and resource-group names as needed.

   `az network vnet subnet update --resource-group Episode001 --vnet-name vnet-q247ouguhstis --name snet-apps --remove delegations`
10. You can delete all the resources created by this template by deleting the Resource Group
   
   `az group delete --name Episode001`
