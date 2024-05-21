param location string
param deploymentScriptName string
param functionAppName string
//var functionAppUrl = 'https://${functionAppName}.azurewebsites.net/api/encoderpresets/create?'

resource deploymentScript 'Microsoft.Resources/deploymentScripts@2023-08-01' = {
  name: deploymentScriptName
  location: location
  kind: 'AzureCLI'
  properties: {
    azCliVersion: '2.52.0'
    scriptContent: 'sleep 30 && curl -X POST https://${functionAppName}.azurewebsites.net/api/encoderpresets/create? -H "Content-Type:application/json" --data \'{"Name": "TestDepl2", "Description": "libx264 encoding at 1280x720 resolution", "PresetParameters": "-i ##MOUNTPOINT##/##FILENAME -c:v libx264 -b:v 2000k -b:a 128k -f dash ##MOUNTPOINT/##JOB_ID##/output/manifest.mpd"}\''
    cleanupPreference: 'OnSuccess'
    retentionInterval: 'P1D'
  }
}

