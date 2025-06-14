param application string

@allowed([
  'dev'
  'uat'
  'prod'
])
param environment string = 'dev' 

var mapName = 'mapping-${application}-${environment}'

resource msMaps 'Microsoft.Maps/accounts@2023-06-01' = {
	name: mapName
	location: 'westeurope'
	sku: {
		name: 'G2'
	}
	kind: 'Gen2'
}

#disable-next-line outputs-should-not-contain-secrets
output msMapsKey string = msMaps.listKeys().primaryKey
