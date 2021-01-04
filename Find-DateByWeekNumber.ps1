function Find-DateByWeekNumber
{
    <#
    .Synopsis
        Returns array of dates as specified by Ordinal and weekday.
    .DESCRIPTION
        Returns a date as specified by required parameters 
        the first (Ordinal) represents the week of the month and the second 
        (DayOfWeek) represents the weekday. Returns an array of dates 
        when either the FullYear or ThisYear switches are enabled, or the 
        "MonthDate" (StartDate AND EndDate) parameters are entered and valid.
    .PARAMETER Ordinal
        The string that represents the number of the week, ie: '3rd'.
    .PARAMETER DayOfWeek
        The day of the week, ie Monday (or mon).
    .PARAMETER StartDate
        Day to start MonthRange of returned datetime values.
    .PARAMETER EndDate
        Day to start MonthRange of returned datetime values. Must be after StartDate.
    .PARAMETER Month
        Option to return dates over specified month.
    .PARAMETER ThisYear
        Option to return dates over 12 months from January to December.
    .PARAMETER FullYear
        Option to return dates over 12 months starting from the current month.
    .PARAMETER Hour
        Set the hour of day returned with the date (24h). Defaults to 0 (12AM).
    .EXAMPLE
        Find-DateByWeekNumber 2 sat

        Saturday, June 09, 2018 12:00:00 AM
        Returns only the current month
    .EXAMPLE
        Find-DateByWeekNumber 2 sat '6/1' '9/30'

        Saturday, June 09, 2018 12:00:00 AM
        Saturday, July 14, 2018 12:00:00 AM
        Saturday, August 11, 2018 12:00:00 AM
        Saturday, September 08, 2018 12:00:00 AM
    .EXAMPLE
        Find-DateByWeekNumber 3 sat -ThisYear

        Saturday, January 20, 2018 12:00:00 AM
        Saturday, February 17, 2018 12:00:00 AM
        Saturday, March 17, 2018 12:00:00 AM
        Saturday, April 21, 2018 12:00:00 AM
        Saturday, May 19, 2018 12:00:00 AM
        Saturday, June 16, 2018 12:00:00 AM
        Saturday, July 21, 2018 12:00:00 AM
        Saturday, August 18, 2018 12:00:00 AM
        Saturday, September 15, 2018 12:00:00 AM
        Saturday, October 20, 2018 12:00:00 AM
        Saturday, November 17, 2018 12:00:00 AM
        Saturday, December 15, 2018 12:00:00 AM
    .INPUTS
        This function does not accept pipeline input.
    .OUTPUTS
        Output from this cmdlet is a .Net datetime arraylist.
    #>
    [CmdletBinding(DefaultParameterSetName='MonthRange')]
    [Alias('month')]
    [OutputType([datetime[]])]
    Param
    (
        # A number or string ordnial indicating which week of the month.
        [Parameter(Mandatory=$true,
                    Position=0)]
        [ValidateSet('1st','2nd','3rd','4th','5th','Last',
            'First','Second','Third','Fourth','Fifth',
            '1','2','3','4','5')]
        [string]
        $Ordinal,

        # The weekday, ie: Friday.
        [Parameter(Mandatory=$true,
                    Position=1)]
        [ValidateSet('Monday','Tuesday','Wednesday',
            'Thursday','Friday','Saturday','Sunday',
            'Mon','Tue','Tues','Wed','Weds','Thu',
            'Thur','Thurs','Fri','Sat','Sun')]
        [string]
        $DayOfWeek,

        # Day to start MonthRange of returned datetime values.
        [Parameter(Position=2,
                   ParameterSetName='MonthRange')]
        [ValidateNotNull()]
        [datetime]
        $StartDate=($Now.ToShortDateString()),

        # Day to end MonthRange of returned datetime values. Must be after StartDate.
        [Parameter(Position=3,
                   ParameterSetName='MonthRange')]
        [ValidateScript({$_ -ge $StartDate})]
        [datetime]
        $EndDate,

        # Option to return dates over 12 months from January to December.
        [Parameter(ParameterSetName='ThisYear')]
        [switch]
        $ThisYear,

        # Option to return dates over 12 months starting from the current month.
        [Parameter(ParameterSetName='FullYear')]
        [switch]
        $FullYear,

        # Option to return dates over specified month.
        [Parameter(ParameterSetName='OneMonth')]
        [ValidateSet('January','February','March','April','May','June','July','August','September','October','November','December')]
        [string]
        $Month,

        # Set the hour of day returned with the date (24h). Defaults to 0 (12AM).
        [Parameter(Position=4)]
        [ValidateRange(0,23)]
        [int16]
        $Hour=0
    )

    Begin
    {
        Write-Verbose "Define Array"
        $ResultDates = New-Object System.Collections.ArrayList
    }
    Process
    {
    }
    End
    {

        # Handle Month
        if($PsCmdlet.ParameterSetName -eq 'OneMonth'){
            Write-Verbose "Handle Month"
            switch ($Month) {
                January { $StartDate = Get-Date '1/1' | Get-TruncatedDate -Truncate Day }
                February { $StartDate = Get-Date '2/1' | Get-TruncatedDate -Truncate Day }
                March { $StartDate = Get-Date '3/1' | Get-TruncatedDate -Truncate Day }
                April { $StartDate = Get-Date '4/1' | Get-TruncatedDate -Truncate Day }
                May { $StartDate = Get-Date '5/1' | Get-TruncatedDate -Truncate Day }
                June { $StartDate = Get-Date '6/1' | Get-TruncatedDate -Truncate Day }
                July { $StartDate = Get-Date '7/1' | Get-TruncatedDate -Truncate Day }
                August { $StartDate = Get-Date '8/1' | Get-TruncatedDate -Truncate Day }
                September { $StartDate = Get-Date '9/1' | Get-TruncatedDate -Truncate Day }
                October { $StartDate = Get-Date '10/1' | Get-TruncatedDate -Truncate Day }
                November { $StartDate = Get-Date '11/1' | Get-TruncatedDate -Truncate Day }
                December { $StartDate = Get-Date '12/1' | Get-TruncatedDate -Truncate Day }
                Default {
                    [datetime]$StartDate=$Now | Get-TruncatedDate -Truncate Day
                }
            }
            $EndDate=$StartDate.AddMonths(1).AddSeconds(-1)
        }


        # Handle Most Parameters
        if ($ThisYear) {

            Write-Verbose "Handle ThisYear"
            # Get this years first and last day
            [datetime]$StartDate = Get-Date | Get-TruncatedDate -Truncate Month
            $EndDate = $StartDate.AddYears(1).AddDays(-1)

        } elseif ($FullYear) {

            Write-Verbose "Handle FullYear"
            # Get this month's first day, then add a year and minus a day
            $StartDate = Get-Date | Get-TruncatedDate -Truncate Hour
            $EndDate = $StartDate.AddYears(1).AddDays(-1)

        } elseif ($StartDate) {

            Write-Verbose "Handle StartDate"
            # Truncate the entered dates' times
            $StartDate = $StartDate | Get-TruncatedDate -Truncate Hour
            $EndDate = $EndDate | Get-TruncatedDate -Truncate Hour

        } elseif (!$StartDate) {
            
            Write-Verbose "Handle NO StartDate"
            # By default just this month's first and last days
            $StartDate = Get-Date | Get-TruncatedDate -Truncate Day
            $EndDate = $StartDate.AddMonths(1).AddDays(-1)

        }

        # Handle Hour Parameter
        if ($Hour) {
            Write-Verbose "Handle Hour"
            $StartDate = $StartDate.AddHours($Hour)
            $EndDate = $EndDate.AddHours($Hour)
        }
        
        # Resolve the user input to an integer. 
        Write-Verbose "Handle Ordinal"
        $intWeekNumber = switch ($Ordinal)
        {
            '1' {1}
            '2' {2}
            '3' {3}
            '4' {4}
            '5' {5}
            '1st' {1}
            'First' {1}
            '2nd' {2}
            'Second' {2}
            '3rd' {3}
            'Third' {3}
            '4th' {4}
            'Fourth' {4}
            '5th' {5}
            'Fifth' {5}
            'Last' {-1}
            Default {}
        }

        # Resolve the user input to a weekday full name
        Write-Verbose "Handle DayOfWeek"
        $strDayOfWeek = switch ($DayOfWeek)
        {
            'Monday' {'Monday'}
            'Tuesday' {'Tuesday'}
            'Wednesday' {'Wednesday'}
            'Thursday' {'Thursday'}
            'Friday' {'Friday'}
            'Saturday' {'Saturday'}
            'Sunday' {'Sunday'}
            'Mon' {'Monday'}
            'Tue' {'Tuesday'}
            'Tues' {'Tuesday'}
            'Wed' {'Wednesday'}
            'Weds' {'Wednesday'}
            'Thu' {'Thursday'}
            'Thur' {'Thursday'}
            'Thurs' {'Thursday'}
            'Fri' {'Friday'}
            'Sat' {'Saturday'}
            'Sun' {'Sunday'}
            Default {}
        }

        # Assign the ordinals their 7-day ranges
        Write-Verbose "Handle intWeekNumber"
        $intDayRange = switch ($intWeekNumber) {
            1 {1..7}
            2 {8..14}
            3 {15..21}
            4 {22..28}
            5 {29..31}
            Default {}
        }

        # Start at the beginning
        $LoopDate = $StartDate
        Write-Verbose "Entering LoopDate"
        While ($LoopDate -le $EndDate) {
            
            # Handle Last case
            if ($Ordinal -eq 'Last') {

                $LastDay = Resolve-LastDayInMonth -Date $LoopDate
                $intDayRange = ($LastDay - 6)..($LastDay)

            }

            if (
                # If this date is in day range
                $intDayRange -contains $LoopDate.Day -and
                # AND the weekday matches
                $LoopDate.DayOfWeek -eq $strDayOfWeek
            ) {
                # Add the date to the array
                [void]($ResultDates.Add($LoopDate))
            }

            # Increment date before looping
            $LoopDate = $LoopDate.AddDays(1)
        }

        # Output the result
        Write-Verbose "Output pending"
        Write-Output $ResultDates
    }
}
