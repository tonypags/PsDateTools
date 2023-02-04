<#
.Synopsis
   Simple conversion of spans to dates
.DESCRIPTION
   Takes an array of timespan objects and a datetime object and
   calculates a resultant set of datetime objects based on the input.
   If the Backwards switch is enabled, the conversion is negative (historical).
.EXAMPLE
   1..30 | %{New-Timespan -Days $_} | ConvertTo-DatetimeArray -Date '1/1/2020'
.EXAMPLE
   New-Timespan -Days 10 | ConvertTo-DatetimeArray
.INPUTS
   An array of timespan objects
.OUTPUTS
   An array of datetime objects
#>
function ConvertTo-DateTimeArray
{
    [CmdletBinding()]
    [Alias()]
    [OutputType([Datetime[]])]
    Param
    (
        # Timespan array to convert into datetime objects
        [Parameter(Mandatory=$true,
                    ValueFromPipeline=$true,
                    Position=0)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [timespan[]]
        $Timespan,

        # Date for comparison
        [Parameter(Position=1)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [datetime]
        $Date=(Get-Date),

        # Apply timespan to the given date in the past
        [Parameter()]
        [switch]
        $Backwards
    )

    Begin
    {
        $arrTimespan = New-Object -TypeName 'System.Collections.ArrayList'
    }
    Process
    {
        foreach ($span in $Timespan){
            [void]($arrTimespan.Add($span))
        }
    }
    End
    {
        # Sort the incoming list
        if($Backwards){$SortSplat = @{'Descending'=$true}}
        $sortedTimespan = $arrTimespan | Sort-Object @SortSplat

        # Recurse the set and spit out datetimes in order
        foreach ($span in $sortedTimespan){
            if($Backwards){
                $Date - $span
            }else{
                $Date + $span
            }
        }
    }
}
