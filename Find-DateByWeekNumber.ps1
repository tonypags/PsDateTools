<#
.Synopsis
   Find-DateByWeekNumber
.DESCRIPTION
   Long description
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
   Find-DateByWeekNumber 3 sat -FullYear

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
   Inputs to this cmdlet (if any)
.OUTPUTS
   Output from this cmdlet (if any)
.NOTES
   General notes
.COMPONENT
   The component this cmdlet belongs to
.ROLE
   The role this cmdlet belongs to
.FUNCTIONALITY
   The functionality that best describes this cmdlet
#>
function Find-DateByWeekNumber
{
    [CmdletBinding(DefaultParameterSetName='MonthRange', 
                  PositionalBinding=$false)]
    [Alias('month')]
    [OutputType([datetime[]])]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   Position=0)]
        [ValidateSet('1','2','3','4','5','1st','First','2nd','Second','3rd','Third','4th','Fourth','5th','Fifth','Last')]
        [string]
        $WeekNumber,

        # Param2 help description
        [Parameter(Mandatory=$true,
                   Position=1)]
        [ValidateSet('Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday','Mon','Tue','Tues','Wed','Weds','Thu','Thurs','Fri','Sat','Sun')]
        [string]
        $DayOfWeek,

        # Param3 help description
        [Parameter(Position=2,
                   ParameterSetName='MonthRange')]
        [ValidateNotNull()]
        [datetime]
        $StartDate=((Get-Date).ToShortDateString()),

        # Param3 help description
        [Parameter(Position=3,
                   ParameterSetName='MonthRange')]
        [ValidateNotNull()]
        [datetime]
        $EndDate=$StartDate,

        # Switch to return entire year's worth of dates. 
        [Parameter(Position=4)]
        [ValidateRange(0,23)]
        [int16]
        $Hour=0,

        # Switch to return entire year's worth of dates. 
        [Parameter(ParameterSetName='FullYear')]
        [switch]
        $FullYear
    )

    Begin
    {
        $Now = Get-Date
        $ResultDates = New-Object System.Collections.ArrayList
        $Last = $false
    }
    Process
    {
    }
    End
    {
        # Resolve FullYear switch
        if($FullYear){
            [datetime]$StartDate='1/1'
            [datetime]$EndDate='12/31'
        }
        
        # Resolve the user input to an integer. 
        $intWeekNumber = switch ($WeekNumber)
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
            Default {0}
        }

        # Resolve the user input to a weekday full name
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
            'Thurs' {'Thursday'}
            'Fri' {'Friday'}
            'Sat' {'Saturday'}
            'Sun' {'Sunday'}
            Default {throw 'invalid weekday';Exit}
        }

        # this is so the loop below doesn't stop 1 month early
        $EndDate = $EndDate.AddMonths(1) 
        
        # Isolate the month string value, and year int value
        [int]$StartMonth= $StartDate.Month
        [int]$EndMonth  = $EndDate.Month
        [int]$StartYear= $StartDate.Year
        [int]$EndYear  = $EndDate.Year

        # Weeknumber TIMES 7 and then MINUS 7 to find search start date, +1 again to avoid miscalculation of week by -1 in March.
        if($intWeekNumber -gt 5){throw 'invalid week number';Exit}
        if($intWeekNumber -gt 0){
            $iSearch = $intWeekNumber * 7 - 7 + 1
        }elseif($intWeekNumber -eq -1){
            $Last = $true
        }else{throw 'invalid week number';Exit}
        
        # Start the loop off at the start month. 
        $testDate = Get-Date -Year $StartYear -Month $StartMonth -Hour $Hour -Minute 0 -Second 0 -Millisecond 0

        # Repeat for each month in range until the last month matches the given + 1 as calculated above ON $EndMonth = $EndMonth.AddMonths(1) 
        While(!(
            ($EndMonth -eq ($testDate.Month)) -and 
            ($EndYear  -eq ($testDate.Year ))
        ))
        {
            $iWeekday=$null
            # Then add 1 until you find the dates to match
            for (
                %{if($Last){$i = 31}else{$i = $iSearch}};
                $iWeekday -ne $strDayOfWeek;
                %{if($Last){$i--}else{$i++}}
            )
            {
                # Make a date within the current month the day = $i
                $testDate = Get-Date $testDate -Day $i
                # Grab that date's "day of week" string value
                $iWeekday = $testDate.DayOfWeek
                
                if($iWeekday -eq $strDayOfWeek){
                    [void]$ResultDates.Add($testDate)
                    $testDate = $testDate.AddMonths(1)
                }
            }
        }
        
        # Output the result
        Write-Output $ResultDates
    }
}

