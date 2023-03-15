function Find-TimeInPastDay {
    <#
    .SYNOPSIS
    Finds the datetime value of the most recent given time

    .DESCRIPTION
    Given a time (string HH:mm[:ss[.fff]]) and reference datetime,
    it finds a new datetime in the past equal to the given time.

    .PARAMETER Time
    The time (HH:mm[:ss[.fff]] string)

    .PARAMETER Date
    Datetime used as the day's reference point

    .PARAMETER Skip
    Number of days to skip

    .EXAMPLE
    $Date = Get-Date 'Monday, December 13, 2021 4:15:31 PM'
    $time = '23:55'
    Find-TimeInPastDay $time -Date $Date
    Sunday, December 12, 2021 11:55:59 PM
    .EXAMPLE
    $Date = Get-Date 'Wednesday, December 1, 2021 9:00:00 AM'
    $time = '19:05:00'
    Find-TimeInPastDay $time -Date $Date
    Tuesday, November 30, 2021 7:05:00 PM
    .NOTES
    This function has some repeating logic that can be abstracted
    to a scriptblock. It would require calling a method using a
    variable string; if n/a then use a switch/if.
    #>
    [CmdletBinding()]
    param (
        # The time (HH:mm[:ss[.fff]] string)
        [Parameter(Mandatory,Position=0)]
        [string]
        $Time,

        # Datetime used as the day's reference point
        [Parameter(Mandatory,Position=1)]
        [datetime]
        $Date,

        # Number of days to skip
        [Parameter(Position=2)]
        [ValidateNotNull()]
        [int]
        $Skip = 0
    )

    # Handle the Skip parameter first
    $Date = $Date.AddDays(-$Skip)

    # Seconds & Milliseconds are optional on the parameter string value
    # Find the time-parts like parameter values for Get-Date
    $timeParts = $Time -split ':|\.'
    $timeToFind = @{}
    $timeToFind.Hour = $timeParts[0] -as [int]
    $timeToFind.Minute = $timeParts[1] -as [int]
    if ($timeParts[2]) {$timeToFind.Second = $timeParts[2] -as [int]}
    if ($timeParts[3]) {$timeToFind.Millisecond = $timeParts[3] -as [int]}

    # Go to previous day if the reference time is lower than the target time
    if (
        $Date.Hour -lt $timeToFind.Hour -or
        (
            $Date.Hour -eq $timeToFind.Hour -and
            $Date.Minute -lt $timeToFind.Minute
        )
    ) {
        $Date = $Date.Date

        # This transform depends on if we received seconds or milliseconds in $Time string
        $Date = if ($timeToFind.ContainsKey('Millisecond')) {
            $Date.AddMilliseconds(-1)
        } elseif ($timeToFind.ContainsKey('Second')) {
            $Date.AddSeconds(-1)
        } else {
            $Date.AddMinutes(-1)
        }
    }

    While (
        # Subtract 1 Hour until we get within 1 of the desired time
        $Date.Hour -gt $timeToFind.Hour + 1
    ) {
        $Date = $Date.AddHours(-1)
    }
    Write-Debug "Hour +1 Found: $($Date.Hour)"


    While (
        # Subtract 1 Minute until we get within 1 of the desired time
        $Date.Minute -gt $timeToFind.Minute + 1 -or
        $Date.Hour -ne $timeToFind.Hour
    ) {
        $Date = $Date.AddMinutes(-1)
    } 
    Write-Debug "Minute +1 Found: $($Date.Minute)"


    if ($timeToFind.ContainsKey('Second')) {

        While (
            # Subtract 1 Second until we get within 1 of the desired time
            $Date.Second -gt $timeToFind.Second + 1 -or
            $Date.Minute -ne $timeToFind.Minute
        ) {
            $Date = $Date.AddSeconds(-1)
        }
        Write-Debug "Second +1 Found: $($Date.Second)"

    } else {

        While (
            # Subtract 1 Minute until we get within 1 of the desired time
            $Date.Minute -ne $timeToFind.Minute -or
            $Date.Hour -ne $timeToFind.Hour
        ) {
            $Date = $Date.AddMinutes(-1)
        }
        Write-Debug "Minute Finalized: $($Date.Minute)"

    }


    if ($timeToFind.ContainsKey('Millisecond')) {

        While (
            # Subtract 1 Millisecond until we get within 1 of the desired time
            $Date.Millisecond -ne $timeToFind.Millisecond -or
            $Date.Second -ne $timeToFind.Second
        ) {
            $Date = $Date.AddMilliseconds(-1)
        }
        Write-Debug "Millisecond Finalized: $($Date.Millisecond)"

    } else {

        if ($timeToFind.ContainsKey('Second')) {

            While (
                # Subtract 1 Second until we get within 1 of the desired time
                $Date.Second -ne $timeToFind.Second -or
                $Date.Minute -ne $timeToFind.Minute
            ) {
                $Date = $Date.AddSeconds(-1)
            }
            Write-Debug "Second Finalized: $($Date.Second)"
        
        }
        
    }

    $Date

}#END: function Find-TimeInPastDay
