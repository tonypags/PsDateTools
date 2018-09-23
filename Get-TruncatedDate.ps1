function Get-TruncatedDate
{
    [CmdletBinding ()]
    Param
    (
        [Parameter (Position=0,
                    ValueFromPipeline=$true)]
        [datetime[]]
        $Date = $(Get-Date),

        [Parameter (Position=1)]
        [ValidateSet (
            'Millisecond',
            'Second',
            'Minute',
            'Hour',
            'Day',
            'Month')]
        [string]
        $Truncate = 'Hour'
    )

begin {}

process {
    switch ($Truncate)
        {
            'MilliSecond' {
                $DateSplat = @{
                    MilliSecond = 0
                }
                break
            }
            'Second' {
                $DateSplat = @{
                    MilliSecond = 0
                    Second = 0
                }
                break
            }
            'Minute' {
                $DateSplat = @{
                    MilliSecond = 0
                    Second = 0
                    Minute = 0
                }
                break
            }
            'Hour' {
                $DateSplat = @{
                    MilliSecond = 0
                    Second = 0
                    Minute = 0
                    Hour = 0
                }
                break
            }
            'Day' {
                $DateSplat = @{
                    MilliSecond = 0
                    Second = 0
                    Minute = 0
                    Hour = 0
                    Day = 1
                }
                break
            }
            'Month' {
                $DateSplat = @{
                    MilliSecond = 0
                    Second = 0
                    Minute = 0
                    Hour = 0
                    Day = 1
                    Month = 1
                }
                break
            }
        } # end switch ($Truncate)

    foreach ($Item in $Date)
        {
            $Item | Get-Date @DateSplat
        }
    } # end process block

end {}

} # end function Get-TruncatedDate
