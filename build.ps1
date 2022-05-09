#Requires -Modules Psake
[cmdletbinding()]
param(
    [string[]]$task = 'default'
)

@(
    'Pester'
    'psake'
    'PSDeploy'
    'PSScriptAnalyzer'

) | ForEach-Object {

    if (!(Get-Module -Name $_ -ListAvailable)) { Install-Module -Name $_ -Scope CurrentUser -Force }

}

Invoke-psake -taskList $task -buildFile "$PSScriptRoot\psakeBuild.ps1" -Verbose:$VerbosePreference
