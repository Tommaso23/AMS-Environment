param location string = 'germanywestcentral'
param storageAccountName string = 'st-encoderasset'
param functionAppStorageAccountName string = 'st-functionapp'
param sites_tom_encoder_fa_api_name string = 'tom-encoder-fa-api'


param vaults_vault138_name string = 'vault138'
param profiles_cdn_profile_tom_encoder_name string = 'cdn-profile-tom-encoder'
param components_tom_encoder_fa_api_name string = 'tom-encoder-fa-api'
param workspaces_log_mcencoder_name string = 'log-mcencoder'
param containerGroups_ffmpegcontainer_name string = 'ffmpegcontainer'
param serverfarms_GermanyWestCentralLinuxDynamicPlan_name string = 'GermanyWestCentralLinuxDynamicPlan'
param databaseAccounts_tom_encoder_cosmos_account_name string = 'tom-encoder-cosmos-account'
param actionGroups_Application_Insights_Smart_Detection_name string = 'Application Insights Smart Detection'
param smartdetectoralertrules_failure_anomalies_tom_encoder_fa_api_name string = 'failure anomalies - tom-encoder-fa-api'
param workspaces_DefaultWorkspace_d0bdc55f_fe1e_4172_96a6_6b55f5dd28ff_DEWC_externalid string = '/subscriptions/d0bdc55f-fe1e-4172-96a6-6b55f5dd28ff/resourceGroups/DefaultResourceGroup-DEWC/providers/Microsoft.OperationalInsights/workspaces/DefaultWorkspace-d0bdc55f-fe1e-4172-96a6-6b55f5dd28ff-DEWC'

// create storage account for media assets
resource storageAccount 'Microsoft.Storage/storageAccounts@2022-05-01'= {
  name: storageAccountName
  location: location
  tags: {
    owner: 'tagValue'
  }
  sku: {
    name: 'Standard_LRS'
    tier: 'Standard'
  }
  kind: 'StorageV2'
  properties: {
    defaultToOAuthAuthentication: false
    allowCrossTenantReplication: false
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    allowSharedKeyAccess: true
    networkAcls: {
      bypass: 'AzureServices'
      virtualNetworkRules: []
      ipRules: []
      defaultAction: 'Allow'
    }
    supportsHttpsTrafficOnly: true
    encryption: {
      services: {
        file: {
          keyType: 'Account'
          enabled: true
        }
        blob: {
          keyType: 'Account'
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
    accessTier: 'Hot'
  }
}

//create storage account for function app
resource functionAppStorageAccount 'Microsoft.Storage/storageAccounts@2022-05-01'= {
  name: functionAppStorageAccountName
  location: location
  tags: {
    owner: 'tagValue'
  }
  sku: {
    name: 'Standard_LRS'
    tier: 'Standard'
  }
  kind: 'StorageV2'
  properties: {
    defaultToOAuthAuthentication: false
    allowCrossTenantReplication: false
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    allowSharedKeyAccess: true
    networkAcls: {
      bypass: 'AzureServices'
      virtualNetworkRules: []
      ipRules: []
      defaultAction: 'Allow'
    }
    supportsHttpsTrafficOnly: true
    encryption: {
      services: {
        file: {
          keyType: 'Account'
          enabled: true
        }
        blob: {
          keyType: 'Account'
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
    accessTier: 'Hot'
  }
}

//create queue
resource storageAccountQueue 'Microsoft.Storage/storageAccounts/queueServices/queues@2023-01-01' = {
  name: '${functionAppStorageAccount.name}/default/encoderjobs-queue'
  properties: {
    metadata: {}
  }
  dependsOn: [
    functionAppStorageAccount
  ]
}


// create file share
resource storageAccountAssetFileShare 'Microsoft.Storage/storageAccounts/fileServices/shares@2023-01-01' = {
  name: '${storageAccount.name}/default/assets-share'
  properties: {
    accessTier: 'TransactionOptimized'
    shareQuota: 102400
    enabledProtocols: 'SMB'
  }
  dependsOn: [
    storageAccount
  ]
}

// create script share
resource storageAccountScriptFileShare 'Microsoft.Storage/storageAccounts/fileServices/shares@2023-01-01' = {
  name: '${storageAccount.name}/default/scripts-share'
  properties: {
    accessTier: 'TransactionOptimized'
    shareQuota: 102400
    enabledProtocols: 'SMB'
  }
}


// create blob storage
resource storageAccountContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  name: '${storageAccount.name}/default/filestoragecontainer'
  properties: {
    immutableStorageWithVersioning: {
      enabled: false
    }
    defaultEncryptionScope: '$account-encryption-key'
    denyEncryptionScopeOverride: false
    publicAccess: 'Container'
  }
  dependsOn: [
    storageAccount
  ]
}


// create function app
resource functionApp 'Microsoft.Web/sites@2023-01-01' = {
  name: sites_tom_encoder_fa_api_name
  location: location
  kind: 'functionapp,linux'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    enabled: true
    hostNameSslStates: [
      {
        name: '${sites_tom_encoder_fa_api_name}.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Standard'
      }
      {
        name: '${sites_tom_encoder_fa_api_name}.scm.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Repository'
      }
    ]
    serverFarmId: resourceGroup().id
    reserved: true
    isXenon: false
    hyperV: false
    vnetRouteAllEnabled: false
    vnetImagePullEnabled: false
    vnetContentShareEnabled: false
    siteConfig: {
      numberOfWorkers: 1
      linuxFxVersion: 'DOTNET-ISOLATED|8.0'
      acrUseManagedIdentityCreds: false
      alwaysOn: false
      http20Enabled: true
      functionAppScaleLimit: 200
      minimumElasticInstanceCount: 0
    }
    scmSiteAlsoStopped: false
    clientAffinityEnabled: false
    clientCertEnabled: false
    clientCertMode: 'Required'
    hostNamesDisabled: false
    customDomainVerificationId: '517B90CD51655432EB5DD9D88E4493ABCFD99BDA4241179C0DA8BC449D4EC896'
    containerSize: 0
    dailyMemoryTimeQuota: 0
    httpsOnly: false
    redundancyMode: 'None'
    storageAccountRequired: false
    keyVaultReferenceIdentity: 'SystemAssigned'
  }
}

// create cosmos DB
resource databaseAccounts_tom_encoder_cosmos_account_name_resource 'Microsoft.DocumentDB/databaseAccounts@2023-11-15' = {
  name: databaseAccounts_tom_encoder_cosmos_account_name
  location: location
  kind: 'GlobalDocumentDB'
  identity: {
    type: 'None'
  }
  properties: {
    publicNetworkAccess: 'Enabled'
    enableAutomaticFailover: false
    enableMultipleWriteLocations: false
    isVirtualNetworkFilterEnabled: false
    virtualNetworkRules: []
    disableKeyBasedMetadataWriteAccess: false
    enableFreeTier: false
    enableAnalyticalStorage: false
    analyticalStorageConfiguration: {
      schemaType: 'WellDefined'
    }
    databaseAccountOfferType: 'Standard'
    defaultIdentity: 'FirstPartyIdentity'
    networkAclBypass: 'None'
    disableLocalAuth: false
    enablePartitionMerge: false
    enableBurstCapacity: false
    minimalTlsVersion: 'Tls12'
    consistencyPolicy: {
      defaultConsistencyLevel: 'Session'
      maxIntervalInSeconds: 5
      maxStalenessPrefix: 100
    }
    locations: [
      {
        locationName: location
        provisioningState: 'Succeeded'
        failoverPriority: 0
        isZoneRedundant: false
      }
    ]
    cors: []
    capabilities: []
    ipRules: []
    backupPolicy: {
      type: 'Periodic'
      periodicModeProperties: {
        backupIntervalInMinutes: 240
        backupRetentionIntervalInHours: 8
        backupStorageRedundancy: 'Geo'
      }
    }
    networkAclBypassResourceIds: []
    keysMetadata: {}
  }
}



resource profiles_cdn_profile_tom_encoder_name_resource 'Microsoft.Cdn/profiles@2022-11-01-preview' = {
  name: profiles_cdn_profile_tom_encoder_name
  location: 'Global'
  sku: {
    name: 'Standard_Microsoft'
  }
  kind: 'cdn'
  properties: {
    extendedProperties: {}
  }
}

resource workspaces_log_mcencoder_name_resource 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' = {
  name: workspaces_log_mcencoder_name
  location: location
  properties: {
    sku: {
      name: 'pergb2018'
    }
    retentionInDays: 30
    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
    }
    workspaceCapping: {
      dailyQuotaGb: -1
    }
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

resource serverfarms_GermanyWestCentralLinuxDynamicPlan_name_resource 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: serverfarms_GermanyWestCentralLinuxDynamicPlan_name
  location: location
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
    size: 'Y1'
    family: 'Y'
    capacity: 0
  }
  kind: 'functionapp'
  properties: {
    perSiteScaling: false
    elasticScaleEnabled: false
    maximumElasticWorkerCount: 1
    isSpot: false
    reserved: true
    isXenon: false
    hyperV: false
    targetWorkerCount: 0
    targetWorkerSizeId: 0
    zoneRedundant: false
  }
}

resource profiles_cdn_profile_tom_encoder_name_cdn_endpoint_tom_encoder 'Microsoft.Cdn/profiles/endpoints@2022-11-01-preview' = {
  parent: profiles_cdn_profile_tom_encoder_name_resource
  name: 'cdn-endpoint-tom-encoder'
  location: 'Global'
  properties: {
    originHostHeader: 'tomencoderassetssa.blob.core.windows.net'
    contentTypesToCompress: [
      'application/eot'
      'application/font'
      'application/font-sfnt'
      'application/javascript'
      'application/json'
      'application/opentype'
      'application/otf'
      'application/pkcs7-mime'
      'application/truetype'
      'application/ttf'
      'application/vnd.ms-fontobject'
      'application/xhtml+xml'
      'application/xml'
      'application/xml+rss'
      'application/x-font-opentype'
      'application/x-font-truetype'
      'application/x-font-ttf'
      'application/x-httpd-cgi'
      'application/x-javascript'
      'application/x-mpegurl'
      'application/x-opentype'
      'application/x-otf'
      'application/x-perl'
      'application/x-ttf'
      'font/eot'
      'font/ttf'
      'font/otf'
      'font/opentype'
      'image/svg+xml'
      'text/css'
      'text/csv'
      'text/html'
      'text/javascript'
      'text/js'
      'text/plain'
      'text/richtext'
      'text/tab-separated-values'
      'text/xml'
      'text/x-script'
      'text/x-component'
      'text/x-java-source'
    ]
    isCompressionEnabled: true
    isHttpAllowed: true
    isHttpsAllowed: true
    queryStringCachingBehavior: 'IgnoreQueryString'
    origins: [
      {
        name: 'default-origin-fa96716a'
        properties: {
          hostName: 'tomencoderassetssa.blob.core.windows.net'
          httpPort: 80
          httpsPort: 443
          originHostHeader: 'tomencoderassetssa.blob.core.windows.net'
          priority: 1
          weight: 1000
          enabled: true
        }
      }
    ]
    originGroups: []
    geoFilters: []
  }
}

resource databaseAccounts_tom_encoder_cosmos_account_name_tom_encoder_db 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2023-11-15' = {
  parent: databaseAccounts_tom_encoder_cosmos_account_name_resource
  name: 'tom-encoder-db'
  properties: {
    resource: {
      id: 'tom-encoder-db'
    }
  }
}



resource sites_tom_encoder_fa_api_name_web 'Microsoft.Web/sites/config@2023-01-01' = {
  parent: sites_tom_encoder_fa_api_name_resource
  name: 'web'
  location: location
  properties: {
    numberOfWorkers: 1
    defaultDocuments: [
      'Default.htm'
      'Default.html'
      'Default.asp'
      'index.htm'
      'index.html'
      'iisstart.htm'
      'default.aspx'
      'index.php'
    ]
    netFrameworkVersion: 'v4.0'
    linuxFxVersion: 'DOTNET-ISOLATED|8.0'
    requestTracingEnabled: false
    remoteDebuggingEnabled: false
    remoteDebuggingVersion: 'VS2019'
    httpLoggingEnabled: false
    acrUseManagedIdentityCreds: false
    logsDirectorySizeLimit: 35
    detailedErrorLoggingEnabled: false
    publishingUsername: '$tom-encoder-fa-api'
    scmType: 'None'
    use32BitWorkerProcess: false
    webSocketsEnabled: false
    alwaysOn: false
    managedPipelineMode: 'Integrated'
    virtualApplications: [
      {
        virtualPath: '/'
        physicalPath: 'site\\wwwroot'
        preloadEnabled: false
      }
    ]
    loadBalancing: 'LeastRequests'
    experiments: {
      rampUpRules: []
    }
    autoHealEnabled: false
    vnetRouteAllEnabled: false
    vnetPrivatePortsCount: 0
    cors: {
      allowedOrigins: [
        'https://portal.azure.com'
      ]
      supportCredentials: false
    }
    localMySqlEnabled: false
    managedServiceIdentityId: 13208
    ipSecurityRestrictions: [
      {
        ipAddress: 'Any'
        action: 'Allow'
        priority: 2147483647
        name: 'Allow all'
        description: 'Allow all access'
      }
    ]
    scmIpSecurityRestrictions: [
      {
        ipAddress: 'Any'
        action: 'Allow'
        priority: 2147483647
        name: 'Allow all'
        description: 'Allow all access'
      }
    ]
    scmIpSecurityRestrictionsUseMain: false
    http20Enabled: true
    minTlsVersion: '1.2'
    scmMinTlsVersion: '1.2'
    ftpsState: 'FtpsOnly'
    preWarmedInstanceCount: 0
    functionAppScaleLimit: 200
    functionsRuntimeScaleMonitoringEnabled: false
    minimumElasticInstanceCount: 0
    azureStorageAccounts: {}
  }
}

resource profiles_cdn_profile_tom_encoder_name_cdn_endpoint_tom_encoder_default_origin_fa96716a 'Microsoft.Cdn/profiles/endpoints/origins@2022-11-01-preview' = {
  parent: profiles_cdn_profile_tom_encoder_name_cdn_endpoint_tom_encoder
  name: 'default-origin-fa96716a'
  properties: {
    hostName: 'tomencoderassetssa.blob.core.windows.net' //parametrizzare con nome storage account blob
    httpPort: 80
    httpsPort: 443
    originHostHeader: 'tomencoderassetssa.blob.core.windows.net'
    priority: 1
    weight: 1000
    enabled: true
  }
  dependsOn: [
    profiles_cdn_profile_tom_encoder_name_resource
  ]
}

resource databaseAccounts_tom_encoder_cosmos_account_name_tom_encoder_db_EncoderJobs 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2023-11-15' = {
  parent: databaseAccounts_tom_encoder_cosmos_account_name_tom_encoder_db
  name: 'EncoderJobs'
  properties: {
    resource: {
      id: 'EncoderJobs'
      indexingPolicy: {
        indexingMode: 'consistent'
        automatic: true
        includedPaths: [
          {
            path: '/*'
          }
        ]
        excludedPaths: [
          {
            path: '/"_etag"/?'
          }
        ]
      }
      partitionKey: {
        paths: [
          '/id'
        ]
        kind: 'Hash'
      }
      uniqueKeyPolicy: {
        uniqueKeys: []
      }
      conflictResolutionPolicy: {
        mode: 'LastWriterWins'
        conflictResolutionPath: '/_ts'
      }
      computedProperties: []
    }
  }
  dependsOn: [
    databaseAccounts_tom_encoder_cosmos_account_name_resource
  ]
}

resource databaseAccounts_tom_encoder_cosmos_account_name_tom_encoder_db_EncoderPresets 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2023-11-15' = {
  parent: databaseAccounts_tom_encoder_cosmos_account_name_tom_encoder_db
  name: 'EncoderPresets'
  properties: {
    resource: {
      id: 'EncoderPresets'
      indexingPolicy: {
        indexingMode: 'consistent'
        automatic: true
        includedPaths: [
          {
            path: '/*'
          }
        ]
        excludedPaths: [
          {
            path: '/"_etag"/?'
          }
        ]
      }
      partitionKey: {
        paths: [
          '/id'
        ]
        kind: 'Hash'
      }
      uniqueKeyPolicy: {
        uniqueKeys: []
      }
      conflictResolutionPolicy: {
        mode: 'LastWriterWins'
        conflictResolutionPath: '/_ts'
      }
      computedProperties: []
    }
  }
  dependsOn: [
    databaseAccounts_tom_encoder_cosmos_account_name_resource
  ]
}

resource databaseAccounts_tom_encoder_cosmos_account_name_1ef2606b_b668_42d2_949a_ffa13987a08b 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2023-11-15' = {
  parent: databaseAccounts_tom_encoder_cosmos_account_name_resource
  name: '1ef2606b-b668-42d2-949a-ffa13987a08b'
  properties: {
    roleDefinitionId: databaseAccounts_tom_encoder_cosmos_account_name_00000000_0000_0000_0000_000000000002.id
    principalId: '6e8a2b9b-cf63-426b-b944-b5611c268c45'
    scope: '${databaseAccounts_tom_encoder_cosmos_account_name_resource.id}/dbs/tom-encoder-db/colls/EncoderJobs'
  }
}

resource databaseAccounts_tom_encoder_cosmos_account_name_537302ef_f6a3_44de_a5e8_63151e300573 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2023-11-15' = {
  parent: databaseAccounts_tom_encoder_cosmos_account_name_resource
  name: '537302ef-f6a3-44de-a5e8-63151e300573'
  properties: {
    roleDefinitionId: databaseAccounts_tom_encoder_cosmos_account_name_1d60ffaf_3404_4448_b688_dd8a441e5f1a.id
    principalId: '6d2dbc11-ecf1-4709-b4be-af198550f7bf'
    scope: databaseAccounts_tom_encoder_cosmos_account_name_resource.id
  }
}

resource databaseAccounts_tom_encoder_cosmos_account_name_c6065151_ba39_46d2_8098_173d1d1172f0 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2023-11-15' = {
  parent: databaseAccounts_tom_encoder_cosmos_account_name_resource
  name: 'c6065151-ba39-46d2-8098-173d1d1172f0'
  properties: {
    roleDefinitionId: databaseAccounts_tom_encoder_cosmos_account_name_00000000_0000_0000_0000_000000000002.id
    principalId: '6d2dbc11-ecf1-4709-b4be-af198550f7bf'
    scope: '${databaseAccounts_tom_encoder_cosmos_account_name_resource.id}/dbs/tom-encoder-db/colls/EncoderPresets'
  }
}

resource databaseAccounts_tom_encoder_cosmos_account_name_d4988ed0_7ab7_4da3_afb8_99015e6f8d57 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2023-11-15' = {
  parent: databaseAccounts_tom_encoder_cosmos_account_name_resource
  name: 'd4988ed0-7ab7-4da3-afb8-99015e6f8d57'
  properties: {
    roleDefinitionId: databaseAccounts_tom_encoder_cosmos_account_name_00000000_0000_0000_0000_000000000002.id
    principalId: '6d2dbc11-ecf1-4709-b4be-af198550f7bf'
    scope: '${databaseAccounts_tom_encoder_cosmos_account_name_resource.id}/dbs/tom-encoder-db/colls/EncoderJobs'
  }
}

resource databaseAccounts_tom_encoder_cosmos_account_name_e21b5273_947d_4561_8ccb_7112a6d27dd5 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2023-11-15' = {
  parent: databaseAccounts_tom_encoder_cosmos_account_name_resource
  name: 'e21b5273-947d-4561-8ccb-7112a6d27dd5'
  properties: {
    roleDefinitionId: databaseAccounts_tom_encoder_cosmos_account_name_00000000_0000_0000_0000_000000000002.id
    principalId: '6e8a2b9b-cf63-426b-b944-b5611c268c45'
    scope: '${databaseAccounts_tom_encoder_cosmos_account_name_resource.id}/dbs/tom-encoder-db/colls/EncoderPresets'
  }
}







