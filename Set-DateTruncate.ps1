function Set-DateTruncate {
    [CmdletBinding(DefaultParameterSetName="TructateMinutes")]
    param (
        # The datetime object to affect
        [Parameter(Mandatory=$true,
                    Position=0,
                    ValueFromPipeline=$true)]
        [datetime[]]
        $Date,

        # Enable to truncate milliseconds (top of current second--past)
        [Parameter(Position=1,
                    ParameterSetName="TructateMillisecond")]
        [switch]
        $Millisecond,

        # Enable to truncate seconds (top of current minute--past)
        [Parameter(Position=1,
                    ParameterSetName="TructateSecond")]
        [switch]
        $Second,

        # Enable to truncate minutes (top of current hour--past)
        [Parameter(Position=1,
                    ParameterSetName="TructateMinute")]
        [switch]
        $Minute,

        # Enable to truncate hours (0h of current day--past)
        [Parameter(Position=1,
                    ParameterSetName="TructateHour")]
        [switch]
        $Hour,

        # Enable to truncate days (1d0h of current month--past)
        [Parameter(Position=1,
                    ParameterSetName="TructateDay")]
        [switch]
        $Day,

        # Enable to truncate months (1M1d0h of current year--past)
        [Parameter(Position=1,
                    ParameterSetName="TructateMonth")]
        [switch]
        $Month
    )
    begin {
    }
    process {
        ForEach ($D in $Date) {
            $TruncSplat = @{}
            switch ($PsCmdlet.ParameterSetName) {
                'TructateMilliSecond' {
                    $TruncSplat.Add('MilliSecond',0)
                }
                'TructateSecond' {
                    $TruncSplat.Add('MilliSecond',0)
                    $TruncSplat.Add('Second',0)
                }
                'TructateMinute' {
                    $TruncSplat.Add('MilliSecond',0)
                    $TruncSplat.Add('Second',0)
                    $TruncSplat.Add('Minute',0)
                }
                'TructateHour' {
                    $TruncSplat.Add('MilliSecond',0)
                    $TruncSplat.Add('Second',0)
                    $TruncSplat.Add('Minute',0)
                    $TruncSplat.Add('Hour',0)
                }
                'TructateDay' {
                    $TruncSplat.Add('MilliSecond',0)
                    $TruncSplat.Add('Second',0)
                    $TruncSplat.Add('Minute',0)
                    $TruncSplat.Add('Hour',0)
                    $TruncSplat.Add('Day',1)
                }
                'TructateMonth' {
                    $TruncSplat.Add('MilliSecond',0)
                    $TruncSplat.Add('Second',0)
                    $TruncSplat.Add('Minute',0)
                    $TruncSplat.Add('Hour',0)
                    $TruncSplat.Add('Day',1)
                    $TruncSplat.Add('Month',1)
                }
                Default { throw "Invalid Parameter Value supplied by user." }
            }#switch ($PsCmdlet.ParameterSetName)

            # Truncate that Date
            $D | Get-Date @TruncSplat
        }#ForEach ($D in $Date)
    }#process
    end {
    }
}
