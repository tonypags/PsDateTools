<#
.Synopsis
   Finds a given date closest to today's date. 
.DESCRIPTION
   Sometimes when a date without a year is given to the Get-Date cmdlet, 
   PowerShell automatically assumes you are referring to the current year. 

   The date given to the function will be compared to the current date, 
   and the closest date found to that date will be returned. 

   Effectively, if you want to ensure the retuend date is from last month, 
   but it's January this month, this funciton will always give you the M/d 
   date from last year. Also works for future date cases. 
.EXAMPLE
   Get-Date
Friday, February 03, 2017 8:09:03 PM
   PS C:\> '12/15' | Find-ClosestDate
   PS C:\> Thursday, December 15, 2016 12:00:00 AM
.EXAMPLE
   Get-Date
Friday, February 03, 2017 8:47:16 PM
   PS C:\>'8/10' | Find-ClosestDate

   Wednesday, August 10, 2016 12:00:00 AM
   PS C:\>'8/5'|Find-ClosestDate

   Saturday, August 05, 2017 12:00:00 AM
.INPUTS
   Inputs to this cmdlet are a [string] in the form 'M/d'. 
.OUTPUTS
   Output from this cmdlet are a [datetime] object. 
.NOTES
   Future versions can include the ability to reference any date, 
   instead of being forced to reference the current date. 
#>
function Find-ClosestDate
{
    [CmdletBinding()]
    [OutputType([datetime])]
    Param
    (
        # The date as a string
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   Position=0)]
        [ValidateNotNull()]
        [ValidateScript({
            (Get-Date $_).tostring('M/d') -eq $_ 
        })]
        [string]
        $InputDateString
    )

    Process
    {
        $Today = Get-Date
        $SearchDate = (Get-Date $InputDateString).AddYears(-3)
        
        $prevSpan = $null
        for ($i = 0; $i -lt 7; $i++)
        { 
            $prevDate = $tempDate
            $tempDate = $SearchDate.AddYears($i)

            $thisSpan = [math]::Abs(($tempDate - $Today).Days)
            if($prevSpan){
                if($thisSpan -gt $prevSpan){
                    $Answer = $prevDate
                    $i = $i + 10
                }
            }
            $prevSpan = $thisSpan
        }
        $Answer
    }
}

