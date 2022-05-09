properties {
    $script = $PSScriptRoot
    [void]$script
}

task default -depends Analyze, Test

task Analyze {
    $saResults = Invoke-ScriptAnalyzer -Path $script -Severity 'Error' -Recurse -Verbose:$false
    if ($saResults) {
        $saResults | Format-Table  
        Write-Error -Message 'One or more Script Analyzer errors where found. Build cannot continue!'
    }
}

task Test {
    $testResults = Invoke-Pester -Path $PSScriptRoot -PassThru
    if ($testResults.FailedCount -gt 0) {
        $testResults | Format-List
        Write-Error -Message 'One or more Pester tests failed. Build cannot continue!'
    }
}

task Deploy -depends Analyze, Test {
    Invoke-PSDeploy -Path "$PSScriptRoot\psdeploy.ps1" -Force -Verbose:$VerbosePreference
}

task Package -depends Deploy {
    Invoke-PSDeploy -Path "$PSScriptRoot\pspackage.ps1" -Force -Verbose:$VerbosePreference
}
