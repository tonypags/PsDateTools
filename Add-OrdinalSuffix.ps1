# Based off of https://gist.github.com/markwragg/8c24a6462feee7849ba7e06b0b0782fa Get-OrdinalNumber
Function Add-OrdinalSuffix {
    Param(
        [Parameter(Mandatory=$true,
                    ValueFromPipeline=$true)]
        [int64[]]$Num
    )

    Process {
        foreach ($N in $Num) {
            $Suffix = Switch -regex ($N) {
                '.?1$'      { 'st'; break }
                '.?2$'      { 'nd'; break }
                '.?3$'      { 'rd'; break }
                default     { 'th'; break }
            }
            Write-Output "$N$Suffix"
        }
    }
}
