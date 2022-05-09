<#
# Build, Test, and Publish
1.  Pester test. 
2.  Get next version number `v#.#.#.#` and a comment `[string]` for the change log.
3.  Create a new Package folder as .\Package\v#.#.#.#\
4.  Copy the PSD1 files in as-is.
    Update the version number and copyright date if required.
	Update the Exported Function Name array with the basenames of the files under the Public folder only.
5.  Create a new, blank PSM1 file in here. 
    Populate it with all of the PS1 files' content from the .\Public and .\Private folders.
6.  Create a NUSPEC file and update the version and change log.
    
NEXT TO DO:
7.  Build the NuGet package.
8.  Push to private repo.
#>
Deploy "Deploy $modName Module" {

    By Task BuildModuleAndManifest {

        $oldModulePath = $PSScriptRoot
    
        $modName     = Split-Path $oldModulePath -Leaf
        $oldPsd1Path = Join-Path $oldModulePath "$modName.psd1"
        $PublicPath  = Join-Path $oldModulePath "Public"
        $PrivatePath = Join-Path $oldModulePath "Private"
        
        $PublicFunctions = @()
        $preManifestHash = Import-PowerShellDataFile -Path $oldPsd1Path
        $oldVersion      = $preManifestHash.ModuleVersion -as [version]
        $newRevision     = $oldVersion.Revision + 1
        $newVersion      = [version]"$($oldVersion.ToString(3)).$($newRevision)"
        $newBuildPath    = "~\Desktop\$($modName)\v$($newVersion)"
        $newPsd1Path     = Join-Path $newBuildPath "$modName.psd1"
        $newPsm1Path     = Join-Path $newBuildPath "$modName.psm1"

        New-Item $newPsm1Path -ItemType 'File' -Force
        Get-ChildItem $PrivatePath -Filter "*.ps1" | ForEach-Object {
            Get-Content $_.FullName | Out-File $newPsm1Path -Append
        }
        Get-ChildItem $PublicPath -Filter "*.ps1" | ForEach-Object {
            $PublicFunctions += $_.Basename
            Get-Content $_.FullName | Out-File $newPsm1Path -Append
        }
        
        # Customize defaults
        $preManifestHash.CompanyName       = $null # Default is 'unknown'
        $preManifestHash.VariablesToExport = $null # Default is '*'
        $preManifestHash.PrivateData       = $null # Creates a duplicate unless this is null

        # Next, update version on old manifest
        $preManifestHash.ModuleVersion = $newVersion
        New-ModuleManifest @preManifestHash -Path $oldPsd1Path
        
        $postManifestHash = $preManifestHash.Clone()
        $postManifestHash.FunctionsToExport = $PublicFunctions
        New-ModuleManifest @postManifestHash -Path $newPsd1Path
        
        # Update the new manifest with the project URI
        $pUri = 'https://github.com/tonypags/PsDateTools'
        $newLine = "        ProjectUri = '$($pUri)'"
        (Get-Content $newPsd1Path) -replace
            '        # ProjectUri = ''''',$newLine -replace
            '    PSData = ''System\.Collections\.Hashtable'''
        # https://github.com/PowerShell/PowerShell/issues/5922 # <-- This is
        # ... why I can't just set it as a value like the others

    }

    By Task UpdateReadMeVersionChangeLog {

        $modName         = Split-Path $PSScriptRoot -Leaf
        $oldPsd1Path     = Join-Path $PSScriptRoot "$modName.psd1"
        $preManifestHash = Import-PowerShellDataFile -Path $oldPsd1Path
        $newVersion      = $preManifestHash.ModuleVersion -as [version]

        # Find the most recent git commit message and tag
        Push-Location
        Set-Location $PSScriptRoot
        $ChangeMsg = git log -n 1 --format=%s
        Invoke-Expression "git tag -a v$($newVersion) -m '$($ChangeMsg)'"
        git push --tags
        Pop-Location

        # Update the Markdown file to have the version update
        $ReadmePath = Join-Path $PSScriptRoot "$README.md"
        $ReadmeContent = Get-Content $ReadmePath
        $ReadmeLength = $ReadmeContent.Count
        $verSectionLine = (Select-String 'Version History' $ReadmePath).LineNumber
        $nextBreak = @($ReadmeContent |
            Select-Object -Skip $verSectionLine |
            Select-String '<br>').LineNumber[0]
        $nextBreakIndex = $verSectionLine + $nextBreak - 1
        $lastVersionIndex = $nextBreakIndex - 2
        $lastReadmeIndex = $ReadmeLength - 1

        # Finally, update the markdown file
        $newContent = $ReadmeContent[0..$lastVersionIndex]
        $newContent += '    - v{0} - {1}' -f $newVersion,$ChangeMsg
        $newContent += ''
        $newContent += $ReadmeContent[$nextBreakIndex..$lastReadmeIndex]
        try{
            $newContent | Out-File $ReadmePath -ea 'Stop'
            Write-Verbose "Added change log message: $($ChangeMsg)"
        }catch{throw $_}

    }

    By Task MakeNugetPackage {
    
        $modName         = Split-Path $PSScriptRoot -Leaf
        $oldPsd1Path     = Join-Path $PSScriptRoot "$modName.psd1"
        $preManifestHash = Import-PowerShellDataFile -Path $oldPsd1Path
        $newVersion      = $preManifestHash.ModuleVersion -as [version]
        $newBuildPath    = "~\Desktop\$($modName)\v$($newVersion)"
        $MonolithPath    = Join-Path $newBuildPath "$modName.nuspec"

        # Load the Nuspec file and modify it
        $strDate = (Get-Date).ToUniversalTime().ToString('yyyy-MM-dd HH:mm:ssZ')
        $xmlFile = New-Object xml
        $xmlFile.Load($MonolithPath)
        $xmlFile.package.metadata.version = $newVersion
        $xmlFile.package.metadata.releaseNotes = "Version $($newVersion
                    ) was modified by $($env:USERNAME) on $($strDate)"
        $xmlFile.Save($MonolithPath)

    }
}
