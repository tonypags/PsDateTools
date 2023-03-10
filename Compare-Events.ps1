
function Compare-Events {
    <#
    .SYNOPSIS
    Compares two events to determine if they overlap.
    .DESCRIPTION
    Compares two events to determine if they overlap.
    .EXAMPLE
    ipmo PsDateTools -force
    $props = @{}
    $props.ReferenceStart = '1/1/2000 1:00 AM'
    $props.ReferenceEnd = '1/1/2000 5:00 AM'
    $props.ReferenceLocation = '123 Main St, Anytown USA'
    $props.DifferenceStart = '1/1/2000 7:00 AM'
    $props.DifferenceEnd = '1/1/2000 11:00 AM'
    $props.DifferenceLocation = '123 Main St, Anytown USA'
    $props.GracePeriod = New-TimeSpan -Hours 2

    $diffEvents = Compare-Events @props
    $diffEvents

    hasConflict        : False
    GracePeriod        : 02:00:00
    Overlap            : -02:00:00
    Downtime           : 02:00:00
    ExactSame          : False
    SameTime           : False
    SamePlace          : True
    ReferenceStart     : 1/1/2000 1:00 AM
    ReferenceEnd       : 1/1/2000 5:00 AM
    ReferenceLocation  : '123 Main St, Anytown USA
    DifferenceStart    : 1/1/2000 7:00 AM
    DifferenceEnd      : 1/1/2000 11:00 AM
    DifferenceLocation : '123 Main St, Anytown USA

    .EXAMPLE
    ipmo PsDateTools -force
    $props = @{}
    $props.ReferenceStart = '1/1/2000 1:00 AM'
    $props.ReferenceEnd = '1/1/2000 5:00 AM'
    $props.DifferenceStart = '1/1/2000 7:00 AM'
    $props.DifferenceEnd = '1/1/2000 11:00 AM'
    $props.GracePeriod = New-TimeSpan -Hours 2

    $diffEvents = Compare-Events @props
    $diffEvents

    hasConflict     : False
    GracePeriod     : 02:00:00
    Overlap         : -02:00:00
    Downtime        : 02:00:00
    ExactSame       : False
    SameTime        : False
    ReferenceStart  : 1/1/2000 1:00 AM
    ReferenceEnd    : 1/1/2000 5:00 AM
    DifferenceStart : 1/1/2000 7:00 AM
    DifferenceEnd   : 1/1/2000 11:00 AM

    .NOTES
    Overlap is defined as the amount of time it takes for the earlier event to finish after the later event starts.
    Downtime is defined as the amount of time after the earlier event finishes, before the later event starts.
    Grace Period is defined as the amount of Overlap to allow before calling a Conflict true.
    A negative Grace Period will enforce a minimum amount of Downtime.
    #>
    [CmdletBinding()]
    param(

        # Baseline Event time and date
        [Parameter(Mandatory)]
        [datetime]
        $ReferenceStart,
        
        # Baseline Event END time and date (Start plus duration)
        [Parameter(Mandatory)]
        [datetime]
        $ReferenceEnd,

        # Baseline Event Location (optional)
        [Parameter()]
        [string]
        $ReferenceLocation,

        # Comparison Event time and date
        [Parameter(Mandatory)]
        [datetime]
        $DifferenceStart,
        
        # Comparison Event END time and date (Start plus duration)
        [Parameter(Mandatory)]
        [datetime]
        $DifferenceEnd,

        # Baseline Event Location (optional)
        [Parameter()]
        [string]
        $DifferenceLocation,

        # Amount of overlap to allow (downtime required if negative)
        [Parameter(HelpMessage='Amount of overlap to allow (downtime required if negative)')]
        [ValidateNotNull()]
        [timespan]
        $GracePeriod=([timespan]0)

    )#END: param()

    $hasLocation = -not ([string]::IsNullOrWhiteSpace($ReferenceLocation) -and [string]::IsNullOrWhiteSpace($DifferenceLocation))
    $SameTime    = $false
    $SamePlace   = $false

    # To calculate the overlap/downtime, first determine which event starts earlier

    # This method REVEALS which variable has the early date
    $referenceIsEarlyEvent = if ($ReferenceStart -eq $DifferenceStart) {
        
        # Edge case--Use the end date instead
        if ($ReferenceEnd -eq $DifferenceEnd) {
            # Edge case--throw a conflict
            $SameTime  = $true
            $false
        } elseif ($ReferenceEnd -lt $DifferenceEnd) {
            $true
        } else {
            $false
        }
    } elseif ($ReferenceStart -lt $DifferenceStart) {
        $true
    } else {
        $false
    }

    # This method ABSTRACTS which variable has the early date
    $sortedStarts = @($ReferenceStart,$DifferenceStart) | Sort-Object
    $lateStart = $sortedStarts[1]
    $earlyEnd = if ($referenceIsEarlyEvent) {$ReferenceEnd} else {$DifferenceEnd}
    
    # Downtime time is later start minus early end
    # |---EARLY---| <downtime> |---LATER---|
    $Downtime = $lateStart - $earlyEnd
    # Overlap is negative Downtime
    $Overlap = -$Downtime

    if ($hasLocation) {
        # Also test if the location string matches
        if ($ReferenceLocation.Trim() -eq $DifferenceLocation.Trim()) {
            $SamePlace = $true
        }
    }

    $hasConflict = if ($hasLocation) {
        ($Overlap - $GracePeriod) -gt 0 -and -not $SamePlace
    } else {
        ($Overlap - $GracePeriod) -gt 0
    }

    $ExactSame = if ($hasLocation) {
        $SameTime -and $SamePlace
    } else {
        $SameTime
    }

    $output = [ordered]@{}
    $output.hasConflict     = $hasConflict
    $output.GracePeriod     = $GracePeriod
    $output.Overlap         = $Overlap
    $output.Downtime        = $Downtime
    $output.ExactSame       = $ExactSame
    $output.SameTime        = $SameTime
    if ($hasLocation) {$output.SamePlace = $SamePlace}
    $output.ReferenceStart  = $ReferenceStart
    $output.ReferenceEnd    = $ReferenceEnd
    if ($hasLocation) {$output.ReferenceLocation  = $ReferenceLocation}
    $output.DifferenceStart = $DifferenceStart
    $output.DifferenceEnd   = $DifferenceEnd
    if ($hasLocation) {$output.DifferenceLocation = $DifferenceLocation}

    [pscustomobject]$output

}#END: function Compare-Events {}
