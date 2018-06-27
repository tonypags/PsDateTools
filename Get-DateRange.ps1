<#
.Synopsis
   Returns a series of consecutive dates when given a start and end date. 
.EXAMPLE
   Get-DateRange -StartDate '1/1/2017' -EndDate '1/4/2017'
   1/1/2017
   1/2/2017
   1/3/2017
   1/4/2017
.INPUTS
   Inputs to this cmdlet are not accepted. 
.OUTPUTS
   Output from this cmdlet is an array of datetime objects. 
#>
function Get-DateRange
{
    [CmdletBinding()]
    [OutputType([datetime[]])] 
    Param
    (
        [Parameter(Mandatory=$true, 
                   Position=0)]
        [datetime]
        $StartDate,
        
        [Parameter(Mandatory=$true, 
                   Position=1)]
        [datetime]
        $EndDate,
        
        [Parameter()]
        [switch]
        $Extremes
    )



    Begin
    {
        $DateArray = @()
    }
    Process
    {
    }
    End
    {
        for 
        (
            $i = $StartDate
            $i -le $EndDate
            $i = $i.AddDays(1)
        )
        { $DateArray += [datetime]$i.ToShortDateString() }

        if($Extremes){
            $FullArray = $DateArray | sort
            $DateArray = @()
            $DateArray += $FullArray[0]
            $DateArray += $FullArray[-1]
            $DateArray =  $DateArray | sort
        }

        Write-Output $DateArray
    }
}

