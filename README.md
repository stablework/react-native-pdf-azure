# Cooker PDF Swift App

## Description

This project integrates with Azure and uses specific constants to configure the API connection. To update the API constants, follow the instructions below.

## 🚀 How to Update the API Constants

### 1. Navigate to the File
To update the Azure constants, go to the following path:

DocSign/Constant/AppConstants


### 2. Update the Constants
You will need to update the following fields:

- **tenantID**: Your Azure Tenant ID
- **clientID**: Your Azure Client ID
- **clientSecret**: Your Azure Client Secret
- **storageAccountName**: Your Azure Storage Account Name

#### Example:
```javascript
let tenantID = "e5ae3765-2175-4ca5-8c46-4d901c5b77b3"
let clientID = "2a1c2ff5-d96c-489f-8a16-f89a3b8ea713"
let clientSecret = "lPA8Q~Wi7292aKJ8mZcNJnE7im3qsV32TFGxSaPL"

let storageAccountName = "cookerpdfus2"//"pdfstoreaccount"
