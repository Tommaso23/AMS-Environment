param functionappAppServicePlanName string
param location string

resource appServicePlan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: functionappAppServicePlanName
  location: location
  sku: {
    name: 'P1v3'
  }
  kind: 'linux'
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

output serverFarmId string = appServicePlan.id
