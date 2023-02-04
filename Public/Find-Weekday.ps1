<#
.Synopsis
Determines the previous or next date from the current or imported date. 
.DESCRIPTION
Calulates a date based on a start date, a day of the week, and an offset in weeks. 
.EXAMPLE
Find the next Monday after today.

Find-Weekday -Date (Get-Date) -DayOfWeek Mon
.EXAMPLE
Find the last Monday before today.

Find-Weekday -Date (Get-Date) -DayOfWeek Mon -Backwards
.EXAMPLE
Find the next Friday that isn't a holiday, as defined by an external file.

Find-Weekday -Date (Get-Date) -DayOfWeek Friday -ExcludeHolidays (
    Get-Content c:\temp\holidays.txt)
.EXAMPLE
Find the next or last weekday. 

PS > $SomeDate
Friday, July 30, 2021 10:48:12 PM

PS > $SomeDate | Find-Weekday -Next
Monday, August 2, 2021 10:48:12 PM

PS > $SomeDate | Find-Weekday -Last
Thursday, July 29, 2021 10:48:12 PM
#>
function Find-Weekday 
{
    [CmdletBinding(DefaultParameterSetName='AnyWeekday')]
    [OutputType([datetime])]
    Param
    (
        # The date from which to start the find
        [Parameter(ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=0)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [datetime]
        [Alias('ReportDate','Last_Start','Next_Start')]
        $Date,

        # Day of week to find, any in the past or future
        [Parameter(Mandatory=$true,
                   Position=1,
                   ParameterSetName='AnyWeekday')]
        [ValidateSet(
            'Sunday', 'Monday', 'Tuesday', 'Wednesday',
            'Thursday', 'Friday', 'Saturday','Sun',
            'Mon', 'Tue', 'Tues', 'Wed', 'Weds', 
            'Thu', 'Thur', 'Thurs', 'Fri', 'Sat'
        )]
        [string]
        $DayOfWeek,

        # Look in the past (neg) direction
        [Parameter(ParameterSetName='AnyWeekday')]
        [switch]
        $Backwards=$false,

        # Find the next weekday in the future
        [Parameter(ParameterSetName='NextWeekday')]
        [switch]
        $Next,

        # Find the last weekday in the past
        [Parameter(ParameterSetName='LastWeekday')]
        [switch]
        $Last,

        # A collection of more dates of which to exclude 
        [datetime[]]
        $ExcludeHolidays
    )

    Begin
    {

    }
    Process
    {
        if($PSCmdlet.ParameterSetName -eq 'AnyWeekday'){
            $UpOrDown = if($Backwards){-1}else{1}
            Do{
                $Date = $Date.AddDays($UpOrDown)
            }until(
                ($DayOfWeek -like 
                    "$(([regex]::Match((($Date).DayOfWeek),'...')).value)*"
                ) -and
                ($ExcludeHolidays -notcontains $Date)
            )
        }elseif($PSCmdlet.ParameterSetName -eq 'NextWeekday'){
            Do{
                $Date = $Date.AddDays(1)
            }until(
                ($ExcludeHolidays -notcontains $Date) -and 
                (@('Saturday','Sunday') -notcontains ($Date).DayOfWeek)
            )
        }elseif($PSCmdlet.ParameterSetName -eq 'LastWeekday'){
            Do{
                $Date = $Date.AddDays(-1)
            }until(
                ($ExcludeHolidays -notcontains $Date) -and 
                (@('Saturday','Sunday') -notcontains ($Date).DayOfWeek)
            )
        }
    }
    End
    {
        $Date
    }
}


