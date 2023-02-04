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
7.  Build the NuGet package.
8.  Push to private repo.
#>
