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
   Find-WeekNumberByDate '3/30/2018' |fl

Date           : 3/30/2018 12:00:00 AM
WeekNumber     : 5
DayOfWeek      : Friday
RfaStandardEDF : ???Friday

.EXAMPLE
   Find-WeekNumberByDate '3/20/2018' -RfaStandardEDF '22-00'|fl

Date           : 3/20/2018 12:00:00 AM
WeekNumber     : 3
DayOfWeek      : Tuesday
RfaStandardEDF : 3rdTuesday_22-00

.INPUTS
   Inputs to this cmdlet (if any)
.OUTPUTS
   Output from this cmdlet (if any)
.NOTES
   The 5th week is illegal in this function, due to internal procedures at the company. 
   It will return a result with "???" instead of "5th".
.COMPONENT
   The component this cmdlet belongs to
.ROLE
   The role this cmdlet belongs to
.FUNCTIONALITY
   The functionality that best describes this cmdlet
#>
function Find-WeekNumberByDate
{
    [CmdletBinding(DefaultParameterSetName='MonthRange', 
                  PositionalBinding=$false)]
    [OutputType([datetime[]])]
    Param
    (
        # The date(s) to find the relative date in the current month
        [Parameter(Position=0)]
        [datetime]
        $Date=(Get-Date -Hour 0 -Minute 0 -Second 0 -Millisecond 0),

        # Optional string to add signifying the time window for patching (ie: '00-04')
        [Parameter(Position=1)]
        [ValidatePattern('\d\d\-\d\d')]
        [string]
        $RfaStandardEDF
    )

    Begin
    {
        $ResultDates = New-Object System.Collections.ArrayList
    }
    Process
    {
        # Week number is truncated dividend of 7, plus 1
        $WeekNumber = [math]::Truncate(($Date.Day) / 7) + 1

        # Add the EDF string is requested
            $Numeral = switch ($WeekNumber)
            {
                1 {'1st'}
                2 {'2nd'}
                3 {'3rd'}
                4 {'4th'}
                #5 {'5th'}
                Default {'???'}
            }
        # Build this object instance
        $thisObject = New-Object psobject -Property @{
            Date = $Date
            WeekNumber = $WeekNumber
            DayOfWeek = $Date.DayOfWeek
            RfaStandardEDF = "$($Numeral)$($Date.DayOfWeek)$(if($RfaStandardEDF){'_'})$($RfaStandardEDF)"
        }

        # Add the result
        [void]($ResultDates.Add($thisObject))
    }
    End
    {
        # Output the final result
        Write-Output $ResultDates
    }
}
