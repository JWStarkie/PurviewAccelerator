# Purview Accelerator Usage Guide

**[Home](/README.md)** 

## Table of Contents

1. [Local Script Execution](#local-machine-script-execution)
2. [Cloud Shell Script Execution](#cloud-shell-script-execution)
3. [What's Next](#whats-next)
2. [Limitations](#limitations)
3. [Troubleshooting](#troubleshooting)

## :hammer: Prerequisites

* An [Azure account](https://azure.microsoft.com/en-us/free/) with an active subscription.
* Your must have permissions to create resources in your Azure subscription.
* Your subscription must have the following [resource providers](https://docs.microsoft.com/en-us/azure/purview/create-catalog-portal#configure-your-subscription) registered: **Microsoft.Purview**, **Microsoft.Storage**, and **Microsoft.EventHub**.
* If you wish to execute the scripts on your local machine, you'll need Windows PowerShell installed.
    * You'll need to open this as an administrator for this to work.

## :mega: Introduction 

{Insert intro about this project and why it came about.}

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

## Local Machine Script Execution

1. Sign in to the [Azure portal](https://portal.azure.com) with your Azure account and from the **Home** screen, click **Create a resource**.

    ![Create a Resource](../images/module01/01.01-create-resource.png)  

2. Search the Marketplace for "Azure Purview" and click **Create**.

    ![Create Purview Resource](../images/module01/01.02-create-purview.png)

3. Provide the necessary inputs on the **Basics** tab.  

    > Note: The table below provides example values for illustrative purposes only, ensure to specify values that make sense for your deployment.

    | Parameter  | Example Value |
    | --- | --- |
    | Subscription | `Azure Internal Access` |
    | Resource group | `purviewlab` |
    | Purview account name | `purview-69426` |
    | Location | `Brazil South` |

    ![Purview Account Basics](../images/module01/01.03-create-basic.png)

4. Provide the necessary inputs on the **Configuration** tab.

    | Parameter  | Example Value | Note |
    | --- | --- | --- |
    | Platform size | `4 capacity units` | Sufficient for non-production scenarios. |

    > :bulb: **Did you know?**
    >
    > **Capacity Units** determine the size of the platform and is a **provisioned** (fixed) set of resources that is needed to keep the Azure Purview platform up and running. 1 Capacity Unit is able to support approximately 1 API call per second. Capacity Units are required regardless of whether you plan to invoke the Azure Purview API endpoints directly (i.e. ISV scenario) or indirectly via Purview Studio (GUI).
    > 
    > **vCore Hours** on the other hand is the unit used to measure **serverless** compute that is needed to run a scan. You only pay per vCore Hour of scanning that you consume (rounded up to the nearest minute).
    >
    > For more information, check out the [Azure Purview Pricing](https://azure.microsoft.com/en-us/pricing/details/azure-purview/) page.

    ![Configure Purview Account](../images/module01/01.04-create-configuration.png)

5. On the **Review + Create** tab, once the message in the ribbon returns "Validation passed", verify your selections and click **Create**.

    ![Create Purview Account](../images/module01/01.05-create-create.png)

6. Wait several minutes while your deployment is in progress. Once complete, click **Go to resource**.

    ![Go to resource](../images/module01/01.06-goto-resource.png)

<div align="right"><a href="#purview-accelerator-usage-guide">↥ Back to top</a></div>

## Cloud Shell Script Execution

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

## What's Next

1. To open the out of the box user experience, navigate to the Azure Purview account instance and click **Open Purview Studio**.

<div align="right"><a href="#purview-accelerator-usage-guide">↥ Back to top</a></div>

## Limitations

1. To open the out of the box user experience, navigate to the Azure Purview account instance and click **Open Purview Studio**.

<div align="right"><a href="#purview-accelerator-usage-guide">↥ Back to top</a></div>

## Troubleshooting

1. To open the out of the box user experience, navigate to the Azure Purview account instance and click **Open Purview Studio**.

    ![Open Purview Studio](../images/module01/01.07-open-studio.png)

<div align="right"><a href="#purview-accelerator-usage-guide">↥ Back to top</a></div>

## :mortar_board: Knowledge Check

1. Which of the following Azure Purview pricing meters is fluid, with consumption varying based on usage?

    A ) Capacity Units  
    B ) vCore Hours  
    C ) Neither

2. Which of the following Azure Purview pricing meters is fixed, with consumption based on quantity provisioned?

    A ) Capacity Units  
    B ) vCore Hours  
    C ) Neither

3. Which Azure Purview module provides the base functionality (i.e. source registration, automated scanning and classification, data discovery)?

    A ) C0  
    B ) C1  
    C ) D0

4. Which predefined Azure Purview role provides access to manage data sources?

    A ) Purview Data Reader  
    B ) Purview Data Curator  
    C ) Purview Data Source Administrator

<div align="right"><a href="#purview-accelerator-usage-guide">↥ Back to top</a></div>

## :tada: Summary

This module provided an overview of how to create an Azure Purview account instance.
