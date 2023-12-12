# Based off of https://gist.github.com/markwragg/8c24a6462feee7849ba7e06b0b0782fa Get-OrdinalNumber
function Add-OrdinalSuffix {
    [CmdletBinding()]
    Param(
        [Parameter(ValueFromPipeline)]
        [int64[]]
        $Num
    )

    Process {
        foreach ($N in $Num) {
            "$($N)$(Get-OrdinalSuffix $N)"
        }
    }
}
