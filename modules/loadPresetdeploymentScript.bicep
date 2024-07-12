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
    scriptContent: 'sleep 30 && curl -X POST https://${functionAppName}.azurewebsites.net/api/encoderpresets -H "Content-Type:application/json" --data \'{"Name": "MPEG-DASH", "Description": "Dynamic Adaptive Streaming over HTTP (DASH)", "PresetParameters": "-i ##MOUNTPOINT##/##FILENAME -y -preset veryslow -keyint_min 100 -g 100 -sc_threshold 0 -r 25 -c:v libx264 -pix_fmt yuv420p -c:a aac -b:a 128k -ac 1 -ar 44100 -map v:0 -s:0 960x540 -b:v:0 2M -maxrate:0 2.14M -bufsize:0 3.5M -map v:0 -s:1 416x234 -b:v:1 145k -maxrate:1 155k -bufsize:1 220k -map v:0 -s:2 640x360 -b:v:2 365k -maxrate:2 390k -bufsize:2 640k -map v:0 -s:3 768x432 -b:v:3 730k -maxrate:3 781k -bufsize:3 1278k -map v:0 -s:4 768x432 -b:v:4 1.1M -maxrate:4 1.17M -bufsize:4 2M -map v:0 -s:5 1280x720 -b:v:5 3M -maxrate:5 3.21M -bufsize:5 5.5M -map v:0 -s:6 1280x720 -b:v:6 4.5M -maxrate:6 4.8M -bufsize:6 8M -map v:0 -s:7 1920x1080 -b:v:7 6M -maxrate:7 6.42M -bufsize:7 11M -map v:0 -s:8 1920x1080 -b:v:8 7.8M -maxrate:8 8.3M -bufsize:8 14M -map 0:a -init_seg_name init\\$RepresentationID\\$.\\$ext\\$ -media_seg_name chunk\\$RepresentationID\\$-\\$Number%05d\\$.\\$ext\\$ -use_template 1 -use_timeline 1 -seg_duration 4 -adaptation_sets \\"id=0,streams=v id=1,streams=a\\" -f dash ##MOUNTPOINT/##JOB_ID##/output/manifest.mpd"}\''
    cleanupPreference: 'OnSuccess'
    retentionInterval: 'P1D'
  }
}

