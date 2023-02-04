# Based off of https://gist.github.com/markwragg/8c24a6462feee7849ba7e06b0b0782fa Get-OrdinalNumber
Function Get-OrdinalSuffix {
    Param(
        [Parameter(Mandatory=$true)]
        [int64]$Num
    )

    switch -regex ($Num) {
        '.?11$'     { 'th'; break }
        '.?12$'     { 'th'; break }
        '.?13$'     { 'th'; break }
        '.?1$'      { 'st'; break }
        '.?2$'      { 'nd'; break }
        '.?3$'      { 'rd'; break }
        default     { 'th'; break }
    }

}
