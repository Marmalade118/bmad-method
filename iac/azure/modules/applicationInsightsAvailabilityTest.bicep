param applicationInsightsInstanceResourceId string
param requestUrl string
param testName string
param location string = resourceGroup().location

param application string
param tags object = {}
@allowed([
  'dev'
  'uat'
  'prod'
])
param environment string = 'dev' 

param businessUnit string = 'digital'

param rgName string = 'wt-${application}-${environment}'

//appi-spa-dev
resource standardWebTest 'Microsoft.Insights/webtests@2022-06-15' = {
  name: testName
  location: location
  tags: {
    'hidden-link:${applicationInsightsInstanceResourceId}': 'Resource'
  }
  kind: 'standard'
  properties: {
    SyntheticMonitorId: testName
    Name: testName
    Description: null
    Enabled: true
    Frequency: 300
    Timeout: 120 
    Kind: 'standard'
    RetryEnabled: true
    Locations: [
      {
        Id: 'emea-nl-ams-azr'
      }
      {
        Id: 'emea-ru-msa-edge'
      }
      {
        Id: 'apac-hk-hkn-azr'
      }
      {
        Id: 'latam-br-gru-edge'
      }
      {
        Id: 'emea-au-syd-edge'
      }
    ]
    Configuration: null
    Request: {
      RequestUrl: 'https://${requestUrl}'
      Headers: null
      HttpVerb: 'GET'
      RequestBody: null
      ParseDependentRequests: false
      FollowRedirects: null
    }
    ValidationRules: {
      ExpectedHttpStatusCode: 200
      IgnoreHttpStatusCode: false
      ContentValidation: null
      SSLCheck: true
      SSLCertRemainingLifetimeCheck: 7
    }
  }
}
