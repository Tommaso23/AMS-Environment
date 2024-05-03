param applicationInsightsName string
param location string
param workspaceId string



resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: applicationInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: workspaceId
  }
}

output instrumentationKey string = applicationInsights.properties.InstrumentationKey
