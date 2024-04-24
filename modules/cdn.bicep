param cdnProfileName string

resource profiles_cdn_profile_tom_encoder_name_resource 'Microsoft.Cdn/profiles@2022-11-01-preview' = {
  name: cdnProfileName
  location: 'Global'
  sku: {
    name: 'Standard_Microsoft'
  }
}

