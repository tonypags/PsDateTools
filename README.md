# PsDateTools
Cmdlets for Manipulating dates in PowerShell.

***

# Getting Started
1.	Installation process 
    Access to the repository required:

        $repo = 'PsGallery'
        Install-Module -Name PsDateTools -Repository $repo

    Without Repository available, clone directly from Git:

        $uri = 'https://github.com/tonypags/PsDateTools'.Trim()
        $ModuleParent = $env:PSModulePath -split ';' | Where {$_ -like "*$($env:USERNAME)*"} | Select -First 1
        Set-Location $ModuleParent
        git clone $uri

<br>

2.	Dependencies

    This module has the following PowerShell Dependancies:
    
        None

    This module has the following Software Dependancies:
    
        Windows OS

<br>

3.	Version History

    - v0.0.1.0  - Initial Commit.
    - v0.2.0.10 - Folder Restructure.
    - v0.2.0.13 - Added build files for psdeploy

<br>



# Build, Test, and Publish
## Overview

An example of using the Release Pipeline Model with PowerShell-based tools. This repository hosts the ```ServerInfo.ps1``` 
script which will return system information about a given computer. This repository also includes associated tests and build
tasks for day to day operations and deployment of the script.

## Usage

A ```psake``` script has been created to manage the various operations related to testing and deployment of ```ServerInfo.ps1```

### Build Operations


* Test the script via Pester and Script Analyzer  
```powershell
.\build.ps1

```
    
* Test the script with Pester only  
```powershell
.\build.ps1 -Task Test

```
    
* Test the script with Script Analyzer only  
```powershell
.\build.ps1 -Task Analyze

```
    
* Deploy the script via PSDeploy  
```powershell
.\build.ps1 -Task Deploy

```

* Publish the script via PSDeploy  
```powershell
.\build.ps1 -Task Package

```


<br>


# Contribute
How to help make this module better: 

1.  Add your changes to a new feature sub-branch.

2.  Add Pester tests for your changes.

3.  Push your branch to origin.

4.  Submit a PR with description of changes.

5.  Follow up in 1 business day.


<br>

