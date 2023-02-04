function Get-DateRange {
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
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory,Position=0)]
        [datetime]
        $StartDate,
        
        [Parameter(Mandatory,Position=1)]
        [datetime]
        $EndDate,
        
        [Parameter()]
        [switch]
        $Extremes
    )

    $DateArray = [system.collections.arraylist]@()
    for 
    (
        $i = $StartDate;
        $i -le $EndDate;
        $i = $i.AddDays(1)
    )
    { [void]($DateArray.Add(($i | Get-TruncatedDate -Truncate Hour )))}

    if($Extremes){
        $FullArray = $DateArray | Sort-Object
        $DateArray = @()
        $DateArray += $FullArray[0]
        $DateArray += $FullArray[-1]
        $DateArray =  $DateArray | Sort-Object
    }

    if ($StartDate -gt $EndDate) {
        Write-Warning "No output is expected with StartDate > EndDate!"
    } else {
        $DateArray
    }
    
}
