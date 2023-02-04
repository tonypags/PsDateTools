function Convert-UtcToLocal {
    <#
    .SYNOPSIS
    DEPRECIATED: Use 'ConvertTo-LocalTime -Utc' instead
    #>
    [CmdletBinding()]
    param(
        [Parameter(
            ValueFromPipeline
        )]
        [ValidateNotNull()]
        [datetime]
        $UtcDate
    )

    $strCurrentTimeZone = (Get-WmiObject win32_timezone).StandardName
    $TZ = [System.TimeZoneInfo]::FindSystemTimeZoneById($strCurrentTimeZone)
    [System.TimeZoneInfo]::ConvertTimeFromUtc($UtcDate, $TZ)
    
    Write-Warning "[Convert-UtcToLocal] This function is depreciated. Use 'ConvertTo-LocalTime -Utc' instead."

}#END: function Convert-UtcToLocal {}
