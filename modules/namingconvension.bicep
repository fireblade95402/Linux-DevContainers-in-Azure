// The name of the team that will be responsible for the resource.
@maxLength(8)
param teamName string

// The environment that the resource is for. Accepted values are defined to ensure consistency.
@allowed([
  'development'
  'test'
  'acceptance'
  'production'
])
param environment string

// The function/goal of the resource, for instance the name of an application it supports
param function string

// An index number. This enables you to have some sort of versioning or to create redundancy
param index int

// First, we create shorter versions of the function and the teamname. 
// This is used for resources with a limited length to the name.
// There is a risk to doing at this way, as results might be non-desirable.
// An alternative might be to have these values be a parameter
var functionShort = length(function) > 5 ? substring(function,0,5) : function
var teamNameShort = length(teamName) > 5 ? substring(teamName,0,5) : teamName

// We only need the first letter of the environment, so we substract it.
var environmentLetter = substring(environment,0,1)

// This line constructs the resource name. It uses [PH] for the resource type abbreviation.
// This part can be replaced in the final template
var resourceNamePlaceHolder = '${teamName}-${environmentLetter}-${function}-[PH]-${padLeft(index,2,'0')}'
// This line creates a short version for resources with a max name length of 24
var resourceNameShortPlaceHolder = '${teamName}-${environmentLetter}-${functionShort}-[PH]-${padLeft(index,2,'0')}'

// Storage accounts have specific limitations. The correct convention is created here
var storageAccountNamePlaceHolder = '${teamName}${environmentLetter}${functionShort}sta${padLeft(index,2,'0')}'
// VM names create computer names. These can be a max of 15 characters. So a different structure is required
var vmNamePlaceHolder = '${teamNameShort}-${environmentLetter}-${functionShort}-${padLeft(index,2,'0')}'

// Outputs are created to give the results back to the main template
output resourceName string = resourceNamePlaceHolder 
output resourceNameShort string = resourceNameShortPlaceHolder
output storageAccountName string = storageAccountNamePlaceHolder
output vmName string = vmNamePlaceHolder 
