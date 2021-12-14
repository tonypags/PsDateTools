function Test-TimeInRange {
    <#
    .SYNOPSIS
    Determine if a given time is between 2 other given times.
    .DESCRIPTION
    Determine if a given time is between 2 other given times.
    .EXAMPLE
    Test-TimeInRange -ref '12:00' -Start '09:00' -End '17:00'
    True
    .EXAMPLE
    Test-TimeInRange -ref '12:00' -Start '22:00' -End '05:00:00'
    False
    .EXAMPLE
    Test-TimeInRange -ref '02:00:00' -Start '22:00:00' -End '05:00'
    True
    .EXAMPLE
    Test-TimeInRange -ref '12:00' -Start '12:00' -End '17:00'
    True
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position=0)]
        [Alias('Date')]
        [string]
        $ReferenceTime = ((Get-Date).ToString('HH:mm:ss')),

        [Parameter(Mandatory,Position=1)]
        [Alias('Start')]
        [string]
        $TimeStart,

        [Parameter(Mandatory,Position=2)]
        [Alias('End')]
        [string]
        $TimeEnd
    )

    # Convert times of day into seconds after midnight
    [int[]]$arrStart = $TimeStart     -split ':'
    [int[]]$arrEnd   = $TimeEnd       -split ':'
    [int[]]$arrRef   = $ReferenceTime -split ':'
    $secStart = $arrStart[0] * 3600 + $arrStart[1] * 60 + $arrStart[2]
    $secEnd   = $arrEnd[0]   * 3600 + $arrEnd[1]   * 60 + $arrEnd[2]
    $secRef   = $arrRef[0]   * 3600 + $arrRef[1]   * 60 + $arrRef[2]

    # If the start time (in seconds) is larger than the end time,
    #  the range of times crosses midnight
    $multiDay = if ($secStart -gt $secEnd) {$true} else {$false}

    # Does the ref fall in between or not?
    if ($multiDay) {

        # OR CONDITIONAL handles cross-midnight case
        # if the ref time is greater than the start time and less than 86400 (sec/day)
        #  OR less than the end time and greater than 0
        (

            # Ref falls before midnight
            $secStart -le $secRef -and
            $secRef   -le 86400 -and
            $secEnd   -ge 0

        ) -or (

            # Ref falls after midnight
            $secStart -le 86400 -and
            0         -le $secRef -and
            $secRef   -le $secEnd

        )

    } else {

        # if the ref time falls btw the 2 times, time IN RANGE
        $secStart -le $secRef -and
        $secRef   -le $secEnd

    }

}#END: function Test-TimeInRange
