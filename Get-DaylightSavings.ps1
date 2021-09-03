function Get-DaylightSavings {
    <#
    .SYNOPSIS
    Returns info about your timezone's DST
    .DESCRIPTION
    Returns info about your timezone's DST, including start and end times.
    .EXAMPLE
    Get-DaylightSavings 
    .OUTPUTS
    A PsCustomObject with a Win32_TimeZone object as one of its properties.
    #>
    [CmdletBinding()]
    param (
        # Provide a date, defaults to now
        [Parameter(Position=0)]
        [ValidateNotNull()]
        [datetime]
        $Date = (Get-Date)
    )
    
    $TimeZone = (Get-WmiObject win32_timezone).StandardName
    $TZa = [System.TimeZoneInfo]::FindSystemTimeZoneById($TimeZone)
    $TZo = (Get-WmiObject win32_timezone)

    # We'll use this logic twice
    $indexToDayOfWeek = {param($index)
        switch ($index) {
            0 {'Sunday'}
            1 {'Monday'}
            2 {'Tuesday'}
            3 {'Wednesday'}
            4 {'Thursday'}
            5 {'Friday'}
            6 {'Saturday'}
        }
    }

    # This calculates the current year std date that DST changes
    $stdDayOfWeek = Invoke-Command -ScriptBlock $indexToDayOfWeek -ArgumentList ($TZo.StandardDayOfWeek)
    $stdProps = @{
        Ordinal = $TZo.StandardDay
        DayOfWeek = $stdDayOfWeek
        StartDate = "$($TZo.StandardMonth)/1"
        EndDate   = "$($TZo.StandardMonth + 1)/1"
    }
    $stdDate = Find-DateByWeekNumber @stdProps
    

    # This calculates the current year day date that DST changes
    $dayDayOfWeek = Invoke-Command -ScriptBlock $indexToDayOfWeek -ArgumentList ($TZo.DaylightDayOfWeek)
    $dayProps = @{
        Ordinal = $TZo.DaylightDay
        DayOfWeek = $dayDayOfWeek
        StartDate = "$($TZo.DaylightMonth)/1"
        EndDate = "$($TZo.DaylightMonth + 1)/1"
    }
    $dayDate = Find-DateByWeekNumber @dayProps


    # Now we can know where on the calendar we are now
    if ($Date -ge $stdDate -or $Date -lt $dayDate) {
        $CurrentDstMode = 'Standard'
        $CurrentDstName = $TZa.StandardName
        $NextDstMode = 'Daylight'
        $NextDstName = $TZa.DaylightName
        $NextBiasShiftDirection = 1 # Spring Ahead
    } elseif ($Date -lt $stdDate -and $Date -ge $dayDate) {
        $CurrentDstMode = 'Daylight'
        $CurrentDstName = $TZa.DaylightName
        $NextDstMode = 'Standard'
        $NextDstName = $TZa.StandardName
        $NextBiasShiftDirection = -1 # Fall Behind
    }

    # Adjust for next year if needed
    if ($Date -ge $stdDate) {
        $stdProps.Set_Item(
            'StartDate' ,
            ("$($TZo.StandardMonth)/1/$($Date.Year + 1)")
        )
        $stdProps.Set_Item(
            'EndDate'   ,
            ("$($TZo.StandardMonth + 1)/1/$($Date.Year + 1)")
        )
        $stdDate = Find-DateByWeekNumber @stdProps
    }
    if ($Date -ge $dayDate) {
        $dayProps.Set_Item(
            'StartDate' ,
            ("$($TZo.DaylightMonth)/1/$($Date.Year + 1)")
        )
        $dayProps.Set_Item(
            'EndDate'   ,
            ("$($TZo.DaylightMonth + 1)/1/$($Date.Year + 1)")
        )
        $dayDate = Find-DateByWeekNumber @dayProps
    }


    # Now the next date for change is
    $UntilNextChange = @(
        [timespan]($stdDate - $Date)
        [timespan]($dayDate - $Date)
    ) | Sort-Object | Select-Object -First 1
    $nextChange = $Date + $UntilNextChange

    # and the bias is and will be 
    # the current bias time, plus direction times DaylightBias
    $NextBias = $TZo.Bias +
        ($NextBiasShiftDirection * $TZo.DaylightBias)
    # Also note if the Daylight Bias Direction is + or -
    $DaylightBiasDirection = if ($TZo.DaylightBias -lt 0) {
        -1
    } elseif ($TZo.DaylightBias -gt 0) {
        1
    } else {0}

    
    # Now output an object
    [PSCustomObject]@{
        TimeStamp = $Date
        CurrentDstMode = $CurrentDstMode
        CurrentDstName = $CurrentDstName
        Win32_TimeZone = $TZo
        SystemChange = [pscustomobject]@{
            IsFixedDateRule = $TZa.GetAdjustmentRules().DaylightTransitionEnd[-1].IsFixedDateRule
            DaylightTransitionStart = $TZa.GetAdjustmentRules().DaylightTransitionStart
            DaylightTransitionEnd = $TZa.GetAdjustmentRules().DaylightTransitionEnd
        }
        NextStandardChangeOn = $stdDate
        NextDaylightChangeOn = $dayDate
        NextDstMode = $NextDstMode
        NextDstName = $NextDstName
        NextChange = $nextChange
        UntilNextChange = $UntilNextChange
        NextBiasShiftDirection = $NextBiasShiftDirection * $DaylightBiasDirection
        NextBias = $NextBias
    }

}#END: function Get-DaylightSavings {}
