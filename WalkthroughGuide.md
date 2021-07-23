# Purview Accelerator Usage Guide

**[Home](/README.md)** 

## :memo: Table of Contents

- [Prerequisites](#hammer-prerequisites)
- [Local Script Execution](#local-machine-script-execution)
- [Cloud Shell Script Execution](#cloud-shell-script-execution)
- [What's Next](#whats-next)
- [Limitations](#limitations)
- [Troubleshooting](#troubleshooting)

## :hammer: Prerequisites

* An [Azure account](https://azure.microsoft.com/en-us/free/) with an active subscription.
* Your must have permissions to create resources in your Azure subscription.
* Your subscription must have the following [resource providers](https://docs.microsoft.com/en-us/azure/purview/create-catalog-portal#configure-your-subscription) registered: **Microsoft.Purview**, **Microsoft.Storage**, and **Microsoft.EventHub**.
* If you wish to execute the scripts on your local machine, you'll need Windows PowerShell installed.
    * You'll need to open this as an administrator for this to work.

## :mega: Introduction 

*{Insert intro about this project and why it came about.}*

## :dart: Objectives

* Execute the PowerShell script to deploy the Modern Data Warehousing along with Purview and some data.

## :muscle: Accelerator Outline

- Deploy Azure Services:
    - ADLS Gen 2 & Blob Storage
        - Upload sample customer and credit card data files to blob
    - Synapse Analytics Workspace & Dedicated SQL Pool
        - Give user owner access to Synapse Studio
    - Key Vault 
        - Store SQL user password 
    - Azure Purview 
        - Connected Data Factory to capture lineage from pipeline
    - Azure Data Factory
        - Create datasets and linked services for: ADLS, Blob, Synapse & Key Vault
        - Create and trigger pipeline to copy data from Blob, to ADLS and data flow to SQL Pool
- Assigned relevant roles to make the above possible

<div align="right"><a href="#purview-accelerator-usage-guide">↥ Back to top</a></div>

https://github.com/markdown-templates/markdown-emojis

## :computer: Local Machine Script Execution

1. Clone this repository to a directory of your choice on your local machine. 
    * `git clone https://github.com/JWStarkie/PurviewAccelerator.git`
2. Open your PowerShell Terminal and navigate to the folder.
3. Go one level deeper to the `\PurviewStarter` folder.
4. In your terminal run the command `.\RunStarterKit.ps1` to execute the script file.
5. A pop-up window to log into your AzureAD account will become visible. Log in.
6. Another pop-up window to log in to your AzAccount will become visible. Log in.
7. You will need to provide the necessary inputs **in the terminal** when requested:

    | Parameter  | Default Value | Note |
    | --- | --- | --- |
    | Subscription for deployment | The first available subscription will be printed in the console and selected if you press enter or choose `Yes` | ![Subscription Choice Screenshot](Images\SubscriptionChoice.png) |
    | Deployment Location Choice | `Brazil South`  Please choose another available location by entering the corresponding number| ![Location Choice Screenshot](Images\LocationChoice.png) |
8. Wait 5-10 minutes while your deployment is in progress. Once complete, your resource group name and SQL credentials will be printed to the console.
    ![Go to resource](Images/DeploymentDetails.png)
9. Go to the [Azure Portal](https://portal.azure.com/#home) to access the resources.

<div align="right"><a href="#purview-accelerator-usage-guide">↥ Back to top</a></div>

## :cloud: Cloud Shell Script Execution

1. Navigate to your Azure Purview account and select **Access Control (IAM)** from the left navigation menu.

    ![Access Control](../images/module01/01.08-purview-access.png)

2. Click **Add role assignments**.

    ![Add Role Assignment](../images/module01/01.09-access-add.png)

3. Populate the role assignment prompt as per the table below, select the targeted Azure AD identities, click **Save**.

    | Property  | Value |
    | --- | --- |
    | Role | `Purview Data Curator` |
    | Assign access to | `User, group, or service principal` |
    | Select | `<Azure AD Identities>` |

    ![Purview Data Curator](../images/module01/01.10-role-assignment.png)

    > :bulb: **Did you know?**
    >
    > Azure Purview has a set of predefined Data Plane roles that can be used to control who can access what.

    | Role  | Catalog | Sources/Scans | Description | 
    | --- | --- | --- | --- |
    | Purview Data Reader | `Read` |  | Access to Purview Studio (read only). |
    | Purview Data Curator | `Read/Write` |  | Access to Purview Studio (read & write). |
    | Purview Data Source Administrator |  | `Read/Write` | No access to Purview Studio. Manage data sources and data scans. |

4. Navigate to the **Role assignments** tab and confirm the **Purview Data Curator** role been has been assigned. Tip: Filter **Scope** to `This resource` to limit the results.

    ![Role Assignments](../images/module01/01.11-access-confirm.png)

5. Repeat the previous steps by adding a second role to the same set of Azure AD identities, this time with the **Purview Data Source Administrator** role.

    ![Purview Data Source Administrator](../images/module01/01.12-role-assignment2.png)

<div align="right"><a href="#purview-accelerator-usage-guide">↥ Back to top</a></div>

## :thought_balloon: What's Next

1. To open the out of the box user experience, navigate to the Azure Purview account instance and click **Open Purview Studio**.

<div align="right"><a href="#purview-accelerator-usage-guide">↥ Back to top</a></div>

## :construction: Limitations

1. To open the out of the box user experience, navigate to the Azure Purview account instance and click **Open Purview Studio**.

<div align="right"><a href="#purview-accelerator-usage-guide">↥ Back to top</a></div>

## :triangular_flag_on_post: Troubleshooting

1. To open the out of the box user experience, navigate to the Azure Purview account instance and click **Open Purview Studio**.

    ![Open Purview Studio](../images/module01/01.07-open-studio.png)

<div align="right"><a href="#purview-accelerator-usage-guide">↥ Back to top</a></div>

## :rocket: Summary

This module provided an overview of how to create an Azure Purview account instance.

<div align="right"><a href="#purview-accelerator-usage-guide">↥ Back to top</a></div>