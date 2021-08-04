function Convert-UtcToLocal {
    <#
    .SYNOPSIS
    Converts a datetime object in UTC to your local timezone
    .DESCRIPTION
    Converts a datetime object in UTC to your local timezone
    .PARAMETER UtcDate
    A [datetime] object that represents a time in Universal Coordinated Time.
    .EXAMPLE
    Convert-UtcToLocal -UtcDate 'Tuesday, August 3, 2021 3:59:55 PM'
    .EXAMPLE
    $localDate = [datetime]$UtcDate | Convert-UtcToLocal
    .NOTES
    Taken from https://devblogs.microsoft.com/scripting/powertip-convert-from-utc-to-my-local-time-zone/
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
    
    Write-Warning "This function is depreciated. Use 'ConvertTo-LocalTime -Utc' instead."

}#END: function Convert-UtcToLocal {}
