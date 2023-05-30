function Get-DaylightSaving {
    <#
    .SYNOPSIS
    Returns info about your timezone's DST
    .DESCRIPTION
    Returns info about your timezone's DST, including start and end times.
    .EXAMPLE
    Get-DaylightSaving
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
    
    $TZo = Get-CimInstance win32_timezone
    $TimeZone = $TZo.StandardName
    $TZa = [System.TimeZoneInfo]::FindSystemTimeZoneById($TimeZone)

    if ($TZa.SupportsDaylightSavingTime) {

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

        # Here, 12 + 1 SHOULD equal 1 (January)
        $monthAfterDaylight = if (($TZo.DaylightMonth + 1) -eq 13) {1} else {$TZo.DaylightMonth + 1}
        $monthAfterStandard = if (($TZo.StandardMonth + 1) -eq 13) {1} else {$TZo.StandardMonth + 1}

        # This calculates the standard date that DST changes in the given year
        $stdDayOfWeek = Invoke-Command -ScriptBlock $indexToDayOfWeek -ArgumentList ($TZo.StandardDayOfWeek)
        $stdProps = @{
            Ordinal = $TZo.StandardDay
            DayOfWeek = $stdDayOfWeek
            StartDate = Get-Date -Year ($Date.Year) -Month ($TZo.StandardMonth) -Day 1 | Get-TruncatedDate -Truncate Hour
            EndDate = Get-Date -Year ($Date.Year) -Month $monthAfterStandard -Day 1 | Get-TruncatedDate -Truncate Hour
        }
        $stdDate = (Find-DateByWeekNumber @stdProps).AddHours(
            $TZo.StandardHour).AddMinutes($TZo.StandardMinute
            ).AddSeconds($TZo.StandardSecond).AddMilliseconds($TZo.StandardMillisecond)
        #

        # This calculates the daylight date that DST changes in the given year
        $dayDayOfWeek = Invoke-Command -ScriptBlock $indexToDayOfWeek -ArgumentList ($TZo.DaylightDayOfWeek)
        $dayProps = @{
            Ordinal = $TZo.DaylightDay
            DayOfWeek = $dayDayOfWeek
            StartDate = Get-Date -Year ($Date.Year) -Month ($TZo.DaylightMonth) -Day 1 | Get-TruncatedDate -Truncate Hour
            EndDate = Get-Date -Year ($Date.Year) -Month $monthAfterDaylight -Day 1 | Get-TruncatedDate -Truncate Hour
        }
        $dayDate = (Find-DateByWeekNumber @dayProps).AddHours(
            $TZo.DaylightHour).AddMinutes($TZo.DaylightMinute
            ).AddSeconds($TZo.DaylightSecond).AddMilliseconds($TZo.DaylightMillisecond)
        #

        # Now we can know where on the calendar we are now
        if ($Date -ge $stdDate -or $Date -lt $dayDate) {
            $CurrentDstMode = 'Standard'
            $CurrentDstName = $TZa.StandardName
            $CurrentBias = $TZo.Bias - $TZo.StandardBias
            $NextDstMode = 'Daylight'
            $NextDstName = $TZa.DaylightName
            $NextBias = $TZo.Bias - $TZo.DaylightBias

        } elseif ($Date -lt $stdDate -and $Date -ge $dayDate) {
            $CurrentDstMode = 'Daylight'
            $CurrentDstName = $TZa.DaylightName
            $CurrentBias = $TZo.Bias - $TZo.DaylightBias
            $NextDstMode = 'Standard'
            $NextDstName = $TZa.StandardName
            $NextBias = $TZo.Bias - $TZo.StandardBias
            
        }
        
        $NextBiasShift = $NextBias - $CurrentBias
        $NextBiasShiftDirection = if ($NextBiasShift -lt 0) {
            -1
        } elseif ($NextBiasShift -gt 0) {
            1
        } else {0}

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
            $stdDate = (Find-DateByWeekNumber @stdProps).AddHours(
                $TZo.StandardHour).AddMinutes($TZo.StandardMinute
                ).AddSeconds($TZo.StandardSecond).AddMilliseconds($TZo.StandardMillisecond)
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
            $dayDate = (Find-DateByWeekNumber @dayProps).AddHours(
                $TZo.DaylightHour).AddMinutes($TZo.DaylightMinute
                ).AddSeconds($TZo.DaylightSecond).AddMilliseconds($TZo.DaylightMillisecond)
        }


        # Now the next date for change is
        $UntilNextChange = @(
            [timespan]($stdDate - $Date)
            [timespan]($dayDate - $Date)
        ) | Sort-Object | Select-Object -First 1
        $nextChange = $Date + $UntilNextChange

        $SystemChange = [pscustomobject]@{
            IsFixedDateRule = $TZa.GetAdjustmentRules().DaylightTransitionEnd[-1].IsFixedDateRule
            DaylightTransitionStart = $TZa.GetAdjustmentRules().DaylightTransitionStart
            DaylightTransitionEnd = $TZa.GetAdjustmentRules().DaylightTransitionEnd
        }

    }#END: if ($TZa.SupportsDaylightSavingTime) {
    

    # Now output an object
    [PSCustomObject][ordered]@{
        TimeStamp = $Date
        CurrentBias = $CurrentBias
        SupportsDaylightSavingTime = $TZa.SupportsDaylightSavingTime
        CurrentDstMode = $CurrentDstMode
        CurrentDstName = $CurrentDstName
        Win32_TimeZone = $TZo
        SystemChange = $SystemChange
        NextStandardChangeOn = $stdDate
        NextDaylightChangeOn = $dayDate
        NextDstMode = $NextDstMode
        NextDstName = $NextDstName
        NextChange = $nextChange
        UntilNextChange = $UntilNextChange
        NextBiasShiftDirection = $NextBiasShiftDirection
        NextBias = $NextBias
    }

    
}#END: function Get-DaylightSaving {}
