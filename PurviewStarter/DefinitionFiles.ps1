$storageLinkedServiceDefinition = @"
{
    "name": "<<name>>",
    "properties": {
        "type": "AzureBlobStorage",
        "typeProperties": {
            "connectionString": {
                "value": "<<account_key>>",
                "type": "SecureString"
            }
        }
    }
}
"@

$storageGen2LinkedServiceDefinition = @"
{
    "name": "<<name>>",
    "properties": {
        "type": "AzureBlobFS",
        "typeProperties": {
            "url": "https://<<accountName>>.dfs.core.windows.net",
            "accountKey": {
                "value": "<<account_key>>",
                "type": "SecureString"
            }
        }
    }
}
"@
###SynapseLinkedServiceinADFDef
$synapseLinkedServiceDefinitions = @"
{
    "name": "<<lsname>>",
    "properties": {
        "annotations": [],
        "type": "AzureSqlDW",
        "typeProperties": {
            "connectionString": "Integrated Security=False;Encrypt=True;Connection Timeout=30;Data Source=<<name>>.sql.azuresynapse.net;Initial Catalog=<<poolname>>;User ID=<<userid>>",
            "password": {
                "type": "AzureKeyVaultSecret",
                "store": {
                    "referenceName": "<<keyvaultlinkedservicename>>",
                    "type": "LinkedServiceReference"
                },
                "secretName": "<<secretname>>"
            }
        }
    }
}
"@

##KeyVaultLinkedServiceinADFDef
$keyVaultLinkedServiceDefinitions = @"
{
    "name": "<<keyvaultlinkedservicename>>",
    "properties": {
        "annotations": [],
        "type": "AzureKeyVault",
        "typeProperties": {
            "baseUrl": "https://<<keyvaultname>>.vault.azure.net/"
        }
    }
}
"@

$azureStorageBlobDataSet = @"
{
    "name": "<<datasetName>>",
    "properties": {
        "linkedServiceName": {
            "referenceName": "<<linkedServiceName>>",
            "type": "LinkedServiceReference"
        },
        "annotations": [],
        "type": "DelimitedText",
        "typeProperties": {
            "location": {
                "type": "AzureBlobStorageLocation",
                "container": "<<filesystemname>>"
            },
            "columnDelimiter": ",",
            "escapeChar": "\\",
            "firstRowAsHeader": true,
            "quoteChar": "\""
        },
        "schema": [
            {
                "name": "ip_address",
                "type": "String"
            },
            {
                "name": "IBAN",
                "type": "String"
            },
            {
                "name": "id",
                "type": "String"
            },
            {
                "name": "first_name",
                "type": "String"
            }
        ]
    }
}
"@

$azureStorageGen2DataSet = @"
{
    "name": "<<datasetName>>",
    "properties": {
        "linkedServiceName": {
            "referenceName": "<<linkedServiceName>>",
            "type": "LinkedServiceReference"
        },
        "annotations": [],
        "type": "DelimitedText",
        "typeProperties": {
            "location": {
                "type": "AzureBlobFSLocation",
                "fileSystem": "<<filesystemname>>"
            },
            "columnDelimiter": ",",
            "escapeChar": "\\",
            "firstRowAsHeader": true,
            "quoteChar": "\""
        },
        "schema": [
            {
                "name": "ip_address",
                "type": "String"
            },
            {
                "name": "IBAN",
                "type": "String"
            },
            {
                "name": "id",
                "type": "String"
            },
            {
                "name": "first_name",
                "type": "String"
            }
        ]
    }
}
"@

$ADLSCSVCustomerData = @"
{
    "name": "<<datasetname>>",
    "properties": {
        "linkedServiceName": {
            "referenceName": "<<linkedServiceName>>",
            "type": "LinkedServiceReference"
        },
        "annotations": [],
        "type": "DelimitedText",
        "typeProperties": {
            "location": {
                "type": "AzureBlobFSLocation",
                "fileName": "customer_data.csv",
                "fileSystem": "starter1"
            },
            "columnDelimiter": ",",
            "escapeChar": "\\",
            "firstRowAsHeader": true,
            "quoteChar": "\""
        },
        "schema": [
            {
                "name": "id",
                "type": "String"
            },
            {
                "name": "first_name",
                "type": "String"
            },
            {
                "name": "last_name",
                "type": "String"
            },
            {
                "name": "email",
                "type": "String"
            },
            {
                "name": "gender",
                "type": "String"
            },
            {
                "name": "ip_address",
                "type": "String"
            }
        ]
    }
}
"@

$ADLSCSVCustomerAddress = @"
{
    "name": "<<datasetname>>",
    "properties": {
        "linkedServiceName": {
            "referenceName": "<<linkedServiceName>>",
            "type": "LinkedServiceReference"
        },
        "annotations": [],
        "type": "DelimitedText",
        "typeProperties": {
            "location": {
                "type": "AzureBlobFSLocation",
                "fileName": "customer_address.csv",
                "fileSystem": "starter1"
            },
            "columnDelimiter": ",",
            "escapeChar": "\\",
            "firstRowAsHeader": true,
            "quoteChar": "\""
        },
        "schema": [
            {
                "name": "id",
                "type": "String"
            },
            {
                "name": "street_address",
                "type": "String"
            },
            {
                "name": "country",
                "type": "String"
            },
            {
                "name": "postcode",
                "type": "String"
            },
            {
                "name": "phone",
                "type": "String"
            }
        ]
    }
}
"@

$ADLSCSVCreditCardNo = @"
{
    "name": "<<datasetname>>",
    "properties": {
        "linkedServiceName": {
            "referenceName": "<<linkedServiceName>>",
            "type": "LinkedServiceReference"
        },
        "annotations": [],
        "type": "DelimitedText",
        "typeProperties": {
            "location": {
                "type": "AzureBlobFSLocation",
                "fileName": "creditcard_info.csv",
                "fileSystem": "starter1"
            },
            "columnDelimiter": ",",
            "escapeChar": "\\",
            "firstRowAsHeader": true,
            "quoteChar": "\""
        },
        "schema": [
            {
                "name": "id",
                "type": "String"
            },
            {
                "name": "creditcardno",
                "type": "String"
            },
            {
                "name": "ccardtype",
                "type": "String"
            },
            {
                "name": "ccardcountry",
                "type": "String"
            }
        ]
    }
}
"@

$SynapseDataSetCustInfo = @"
{
    "name": "<<datasetName>>",
    "properties": {
        "linkedServiceName": {
            "referenceName": "<<linkedServiceName>>",
            "type": "LinkedServiceReference"
        },
        "annotations": [],
        "type": "AzureSqlDWTable",
        "schema": [
            {
                "name": "id",
                "type": "int",
                "precision": 10
            },
            {
                "name": "first_name",
                "type": "varchar"
            },
            {
                "name": "last_name",
                "type": "varchar"
            },
            {
                "name": "email",
                "type": "varchar"
            },
            {
                "name": "gender",
                "type": "varchar"
            },
            {
                "name": "ip_address",
                "type": "varchar"
            }
        ],
        "typeProperties": {
            "schema": "dbo",
            "table": "CustomerInfo"
        }
    }
}
"@

$SynapseCustomerAddressDataSet = @"
{
    "name": "<<datasetName>>",
    "properties": {
        "linkedServiceName": {
            "referenceName": "<<linkedServiceName>>",
            "type": "LinkedServiceReference"
        },
        "annotations": [],
        "type": "AzureSqlDWTable",
        "schema": [
            {
                "name": "id",
                "type": "int",
                "precision": 10
            },
            {
                "name": "street_address",
                "type": "varchar"
            },
            {
                "name": "country",
                "type": "varchar"
            },
            {
                "name": "postcode",
                "type": "varchar"
            }
        ],
        "typeProperties": {
            "schema": "dbo",
            "table": "CustomerAddress"
        }
    }
}
"@

$SynapseCredCardDataset = @"
{
    "name": "<<datasetName>>",
    "properties": {
        "linkedServiceName": {
            "referenceName": "<<linkedServiceName>>",
            "type": "LinkedServiceReference"
        },
        "annotations": [],
        "type": "AzureSqlDWTable",
        "schema": [
            {
                "name": "id",
                "type": "int",
                "precision": 10
            },
            {
                "name": "creditcardno",
                "type": "varchar"
            },
            {
                "name": "ccardtype",
                "type": "varchar"
            },
            {
                "name": "ccardcountry",
                "type": "varchar"
            }
        ],
        "typeProperties": {
            "schema": "dbo",
            "table": "CreditCardInfo"
        }
    }
}
"@

$mainPipeline = @"
{
    "name": "ADLSToSynapseCopyPipeline",
    "properties": {
        "activities": [
            {
                "name": "CopytoADLS",
                "type": "Copy",
                "dependsOn": [],
                "policy": {
                    "timeout": "0.01:00:00",
                    "retry": 0,
                    "retryIntervalInSeconds": 30,
                    "secureOutput": false,
                    "secureInput": false
                },
                "userProperties": [],
                "typeProperties": {
                    "source": {
                        "type": "DelimitedTextSource",
                        "storeSettings": {
                            "type": "AzureBlobStorageReadSettings",
                            "recursive": true,
                            "wildcardFileName": "*",
                            "enablePartitionDiscovery": false
                        },
                        "formatSettings": {
                            "type": "DelimitedTextReadSettings"
                        }
                    },
                    "sink": {
                        "type": "DelimitedTextSink",
                        "storeSettings": {
                            "type": "AzureBlobFSWriteSettings"
                        },
                        "formatSettings": {
                            "type": "DelimitedTextWriteSettings",
                            "quoteAllText": true,
                            "fileExtension": ".txt"
                        }
                    },
                    "enableStaging": false
                },
                "inputs": [
                    {
                        "referenceName": "azureStorageLinkedServiceDataSet",
                        "type": "DatasetReference"
                    }
                ],
                "outputs": [
                    {
                        "referenceName": "azureStorageGen2LinkedServiceDataSet",
                        "type": "DatasetReference"
                    }
                ]
            },
            {
                "name": "Copycustomerdata",
                "type": "Copy",
                "dependsOn": [
                    {
                        "activity": "CopytoADLS",
                        "dependencyConditions": [
                            "Succeeded"
                        ]
                    }
                ],
                "policy": {
                    "timeout": "7.00:00:00",
                    "retry": 0,
                    "retryIntervalInSeconds": 30,
                    "secureOutput": false,
                    "secureInput": false
                },
                "userProperties": [],
                "typeProperties": {
                    "source": {
                        "type": "DelimitedTextSource",
                        "storeSettings": {
                            "type": "AzureBlobFSReadSettings",
                            "recursive": true,
                            "enablePartitionDiscovery": false
                        },
                        "formatSettings": {
                            "type": "DelimitedTextReadSettings"
                        }
                    },
                    "sink": {
                        "type": "SqlDWSink"
                    },
                    "enableStaging": false,
                    "translator": {
                        "type": "TabularTranslator",
                        "mappings": [
                            {
                                "source": {
                                    "name": "id",
                                    "type": "String",
                                    "physicalType": "String"
                                },
                                "sink": {
                                    "name": "id",
                                    "type": "Int32",
                                    "physicalType": "int"
                                }
                            },
                            {
                                "source": {
                                    "name": "first_name",
                                    "type": "String",
                                    "physicalType": "String"
                                },
                                "sink": {
                                    "name": "first_name",
                                    "type": "String",
                                    "physicalType": "varchar"
                                }
                            },
                            {
                                "source": {
                                    "name": "last_name",
                                    "type": "String",
                                    "physicalType": "String"
                                },
                                "sink": {
                                    "name": "last_name",
                                    "type": "String",
                                    "physicalType": "varchar"
                                }
                            },
                            {
                                "source": {
                                    "name": "email",
                                    "type": "String",
                                    "physicalType": "String"
                                },
                                "sink": {
                                    "name": "email",
                                    "type": "String",
                                    "physicalType": "varchar"
                                }
                            },
                            {
                                "source": {
                                    "name": "gender",
                                    "type": "String",
                                    "physicalType": "String"
                                },
                                "sink": {
                                    "name": "gender",
                                    "type": "String",
                                    "physicalType": "varchar"
                                }
                            },
                            {
                                "source": {
                                    "name": "ip_address",
                                    "type": "String",
                                    "physicalType": "String"
                                },
                                "sink": {
                                    "name": "ip_address",
                                    "type": "String",
                                    "physicalType": "varchar"
                                }
                            }
                        ],
                        "typeConversion": true,
                        "typeConversionSettings": {
                            "allowDataTruncation": true,
                            "treatBooleanAsNumber": false
                        }
                    }
                },
                "inputs": [
                    {
                        "referenceName": "azureADLSCSVCustomerDataLinkedServiceDataSet",
                        "type": "DatasetReference"
                    }
                ],
                "outputs": [
                    {
                        "referenceName": "azureSynapseCustInfoLinkedServiceDataSet",
                        "type": "DatasetReference"
                    }
                ]
            },
            {
                "name": "Copycustomeraddress",
                "type": "Copy",
                "dependsOn": [
                    {
                        "activity": "CopytoADLS",
                        "dependencyConditions": [
                            "Succeeded"
                        ]
                    }
                ],
                "policy": {
                    "timeout": "7.00:00:00",
                    "retry": 0,
                    "retryIntervalInSeconds": 30,
                    "secureOutput": false,
                    "secureInput": false
                },
                "userProperties": [],
                "typeProperties": {
                    "source": {
                        "type": "DelimitedTextSource",
                        "storeSettings": {
                            "type": "AzureBlobFSReadSettings",
                            "recursive": true,
                            "enablePartitionDiscovery": false
                        },
                        "formatSettings": {
                            "type": "DelimitedTextReadSettings"
                        }
                    },
                    "sink": {
                        "type": "SqlDWSink"
                    },
                    "enableStaging": false,
                    "translator": {
                        "type": "TabularTranslator",
                        "mappings": [
                            {
                                "source": {
                                    "name": "id",
                                    "type": "String",
                                    "physicalType": "String"
                                },
                                "sink": {
                                    "name": "id",
                                    "type": "Int32",
                                    "physicalType": "int"
                                }
                            },
                            {
                                "source": {
                                    "name": "street_address",
                                    "type": "String",
                                    "physicalType": "String"
                                },
                                "sink": {
                                    "name": "street_address",
                                    "type": "String",
                                    "physicalType": "varchar"
                                }
                            },
                            {
                                "source": {
                                    "name": "country",
                                    "type": "String",
                                    "physicalType": "String"
                                },
                                "sink": {
                                    "name": "country",
                                    "type": "String",
                                    "physicalType": "varchar"
                                }
                            },
                            {
                                "source": {
                                    "name": "postcode",
                                    "type": "String",
                                    "physicalType": "String"
                                },
                                "sink": {
                                    "name": "postcode",
                                    "type": "String",
                                    "physicalType": "varchar"
                                }
                            }
                        ],
                        "typeConversion": true,
                        "typeConversionSettings": {
                            "allowDataTruncation": true,
                            "treatBooleanAsNumber": false
                        }
                    }
                },
                "inputs": [
                    {
                        "referenceName": "azureADLSCSVCustomerAddressLinkedServiceDataSet",
                        "type": "DatasetReference"
                    }
                ],
                "outputs": [
                    {
                        "referenceName": "azureSynapseCustAddLinkedServiceDataSet",
                        "type": "DatasetReference"
                    }
                ]
            },
            {
                "name": "Copycreditcardno",
                "type": "Copy",
                "dependsOn": [
                    {
                        "activity": "CopytoADLS",
                        "dependencyConditions": [
                            "Succeeded"
                        ]
                    }
                ],
                "policy": {
                    "timeout": "7.00:00:00",
                    "retry": 0,
                    "retryIntervalInSeconds": 30,
                    "secureOutput": false,
                    "secureInput": false
                },
                "userProperties": [],
                "typeProperties": {
                    "source": {
                        "type": "DelimitedTextSource",
                        "storeSettings": {
                            "type": "AzureBlobFSReadSettings",
                            "recursive": true,
                            "enablePartitionDiscovery": false
                        },
                        "formatSettings": {
                            "type": "DelimitedTextReadSettings"
                        }
                    },
                    "sink": {
                        "type": "SqlDWSink"
                    },
                    "enableStaging": false,
                    "translator": {
                        "type": "TabularTranslator",
                        "mappings": [
                            {
                                "source": {
                                    "name": "id",
                                    "type": "String",
                                    "physicalType": "String"
                                },
                                "sink": {
                                    "name": "id",
                                    "type": "Int32",
                                    "physicalType": "int"
                                }
                            },
                            {
                                "source": {
                                    "name": "creditcardno",
                                    "type": "String",
                                    "physicalType": "String"
                                },
                                "sink": {
                                    "name": "creditcardno",
                                    "type": "String",
                                    "physicalType": "varchar"
                                }
                            },
                            {
                                "source": {
                                    "name": "ccardtype",
                                    "type": "String",
                                    "physicalType": "String"
                                },
                                "sink": {
                                    "name": "ccardtype",
                                    "type": "String",
                                    "physicalType": "varchar"
                                }
                            },
                            {
                                "source": {
                                    "name": "ccardcountry",
                                    "type": "String",
                                    "physicalType": "String"
                                },
                                "sink": {
                                    "name": "ccardcountry",
                                    "type": "String",
                                    "physicalType": "varchar"
                                }
                            }
                        ],
                        "typeConversion": true,
                        "typeConversionSettings": {
                            "allowDataTruncation": true,
                            "treatBooleanAsNumber": false
                        }
                    }
                },
                "inputs": [
                    {
                        "referenceName": "azureADLSCSVCreditCardNoLinkedServiceDataSet",
                        "type": "DatasetReference"
                    }
                ],
                "outputs": [
                    {
                        "referenceName": "azureSynapseCredCardLinkedServiceDataSet",
                        "type": "DatasetReference"
                    }
                ]
            }
        ],
        "annotations": [],
        "lastPublishTime": "2021-07-13T08:54:16Z"
    },
    "type": "Microsoft.DataFactory/factories/pipelines"
}
"@