param webAppApplicationInsightsName string
param location string
param webAppWorkspaceId string

resource webAppApplicationInsights 'microsoft.insights/components@2020-02-02' = {
  name: webAppApplicationInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Flow_Type: 'Redfield'
    Request_Source: 'IbizaWebAppExtensionCreate'
    RetentionInDays: 90
    WorkspaceResourceId: webAppWorkspaceId
    IngestionMode: 'LogAnalytics'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

output instrumentationKey string = webAppApplicationInsights.properties.InstrumentationKey

