$argCompleteProps = @{
    CommandName = 'ConvertTo-LocalTime'
    ParameterName = 'TimeZone'
}
Register-ArgumentCompleter @argCompleteProps -ScriptBlock {
    param(
        $commandName,
        $parameterName,
        $wordToComplete,
        $commandAst,
        $fakeBoundParameter
    )

    # PowerShell code to populate $wordtoComplete
    @(Get-TimeZone -ListAvailable | Sort-Object -Property ID).where({
        $_.id -match "$wordToComplete"
    }) | ForEach-Object { 
        # completion text,listitem text,result type,Tooltip
        [System.Management.Automation.CompletionResult]::new(
            "'$($_.id)'",
            "'$($_.id)'",
            'ParameterValue',
            $_.BaseUtcOffset
        )
    }
    #https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/register-argumentcompleter?view=powershell-5.1
}

function ConvertTo-LocalTime {
    <#
    .SYNOPSIS
    Convert a remote time to local time
    .DESCRIPTION
    You can use this command to convert datetime from another timezone to
    your local time. You should be able to enter the remote time using your
    local time and date format.
    .PARAMETER DateTime
    Specify the date and time from the non-local time zone.
    .PARAMETER TimeZone
    Select the non-local time zone. Tip: Key in a partial name and use tab-completion.
    .PARAMETER Utc
    Use this to specify the non-local timezone is UTC+0.
    Defaults to this option if no TimeZone is specified.
    .EXAMPLE
    ConvertTo-LocalTime "2/2/2021 2:00PM" -TimeZone 'Central Europe Standard Time'

    Tuesday, February 2, 2021 8:00:00 AM

    Convert a Central Europe time to local time, which in this example is
    Eastern Standard Time.
    .EXAMPLE
    ConvertTo-LocalTime "7/2/2021 2:00PM" -TimeZone 'Central Europe Standard Time' -Verbose
    VERBOSE: Converting Friday, July 2, 2021 2:00 PM [Central Europe Standard Time 01:00:00 UTC] to local time.
    Friday, July 2, 2021 9:00:00 AM

    The calculation should take day light savings time into account.
    Verbose output indicates the time zone and its UTC offset.

    .NOTES
    This function is slow, but robostly able to convert times. For speedier
    logic when looping many records, try using this:
    
    $UtcDate = [datetime]'9/1/2021'
    $strCurrentTimeZone = (Get-WmiObject win32_timezone).StandardName
    $TZ = [System.TimeZoneInfo]::FindSystemTimeZoneById($strCurrentTimeZone)
    [System.TimeZoneInfo]::ConvertTimeFromUtc($UtcDate, $TZ)

    ---
    Taken from https://jdhitsolutions.com/blog/powershell/7962/convert-to-local-time-with-powershell/

    Learn more about PowerShell: http://jdhitsolutions.com/blog/essential-powershell-resources/
    ---
    #>

    [CmdletBinding(DefaultParameterSetName='ByUtcHardcode')]
    [Alias("ctlt")]
    [Outputtype([System.Datetime])]
    param(

        # Specify the date and time from the non-local time zone.
        [Parameter(
            Mandatory,
            Position = 0,
            HelpMessage = "Specify the date and time from the other time zone"
        )]
        [ValidateNotNullorEmpty()]
        [Alias("Time","Date","dt")]
        [datetime]
        $DateTime,

        # Select the non-local time zone. Tip: Key in a partial name and use tab-completion.
        [Parameter(
            Mandatory,
            Position = 1,
            ParameterSetName='ByTimezone',
            HelpMessage = "Select the corresponding time zone."
        )]
        [Alias("tz")]
        [string]
        $TimeZone,

        # Use this to specify the non-local timezone is UTC+0.
        [Parameter(
            ParameterSetName='ByUtcHardcode'
        )]
        [switch]
        $Utc

    )

    if ($PSCmdlet.ParameterSetName -eq 'ByTimezone') {
    
        $tzone = Get-TimeZone -Id $Timezone
        $strDatetime = "{0:f}" -f $DateTime
        
        Write-Verbose "Converting $strDatetime [$($tzone.id
            ) $($tzone.BaseUTCOffSet
            ) UTC] to local time."
            
        $HoursToAdd = -($tzone.BaseUtcOffset.totalhours)
        
        $DateTime.AddHours($HoursToAdd).ToLocalTime()
        
    } elseif ($PSCmdlet.ParameterSetName -eq 'ByUtcHardcode') {
        
        $strCurrentTimeZone = (Get-WmiObject win32_timezone).StandardName
        $TZ = [System.TimeZoneInfo]::FindSystemTimeZoneById($strCurrentTimeZone)
        [System.TimeZoneInfo]::ConvertTimeFromUtc($DateTime, $TZ)

    } else {
        throw "Parameter usage error. Type 'Get-Help ConvertTo-LocalTime -s' for more info."
    }

}#END: function ConvertTo-LocalTime {}
