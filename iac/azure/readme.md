https://aka.ms/installazurecliwindows

notes for azure deployment

deploying locally using azure cli https://learn.microsoft.com/en-gb/cli/azure/

az login

az group create --location uksouth --resource-group trac-dosevision-dev

az deployment sub create --location uksouth --template-file dosevision.bicep

az deployment sub create --location uksouth --template-file dosevision.bicep --parameters environment=uat

az deployment sub create --location uksouth --template-file dosevision.bicep --parameters environment=prd

//// give the managed id access to the DB.

<identity-name> = user managed identity name e.g. id-dosevision-dev
CREATE USER [<identity-name>] FROM EXTERNAL PROVIDER;
ALTER ROLE db_datareader ADD MEMBER [<identity-name>];
ALTER ROLE db_datawriter ADD MEMBER [<identity-name>];
ALTER ROLE db_ddladmin ADD MEMBER [<identity-name>];
GO
EXEC sp_addrolemember N'db_owner', N'<identity-name>'