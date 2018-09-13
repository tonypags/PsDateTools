function Test-ThisSaturdayNthWeek {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,
                    Position=1)]
        [ValidateRange(1,5)]
        [int]$WeekNumber = 3
    )
    
    begin {
        $DayToLookup = 'Saturday'
    }
    
    process {
        $ThisComingSaturday = Get-Date -Hour 0 -Minute 0 -Second 0 -Millisecond 0 |
            Find-Weekday -DayOfWeek Saturday
        $ThisWeekNumber = Find-WeekNumberByDate -Date $ThisComingSaturday
        if ($ThisWeekNumber.WeekNumber -eq $WeekNumber) {
            $true
        } else {
            $false
        }
    }
    
    end {
    }
}
