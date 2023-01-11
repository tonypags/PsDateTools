
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
    $props.DifferenceStart = '1/1/2000 7:00 AM'
    $props.DifferenceEnd = '1/1/2000 11:00 AM'
    $props.GracePeriod = New-TimeSpan -Hours 2

    $diffEvents = Compare-Events @props
    $diffEvents

    hasConflict     : False
    GracePeriod     : 02:00:00
    Overlap         : -02:00:00
    Downtime        : 02:00:00
    exactSame       : False
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

        # Comparison Event time and date
        [Parameter(Mandatory)]
        [datetime]
        $DifferenceStart,
        
        # Comparison Event END time and date (Start plus duration)
        [Parameter(Mandatory)]
        [datetime]
        $DifferenceEnd,

        # Amount of overlap to allow (downtime required if negative)
        [Parameter(HelpMessage='Amount of overlap to allow (downtime required if negative)')]
        [ValidateNotNull()]
        [timespan]
        $GracePeriod=([timespan]0)

    )#END: param()

    $exactSame = $false

    # To calculate the overlap/downtime, first determine which event starts earlier

    # This method REVEALS which variable has the early date
    $referenceIsEarlyEvent = if ($ReferenceStart -eq $DifferenceStart) {
        
        # Edge case--Use the end date instead
        if ($ReferenceEnd -eq $DifferenceEnd) {
            # Edge case--throw a conflict
            $exactSame = $true
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

    $hasConflict = ($Overlap - $GracePeriod) -gt 0

    [pscustomobject]@{
        hasConflict     = $hasConflict
        GracePeriod     = $GracePeriod
        Overlap         = $Overlap
        Downtime        = $Downtime
        exactSame       = $exactSame
        ReferenceStart  = $ReferenceStart
        ReferenceEnd    = $ReferenceEnd
        DifferenceStart = $DifferenceStart
        DifferenceEnd   = $DifferenceEnd
    }

}#END: function Compare-Events {}
