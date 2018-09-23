function Get-TruncatedDate
{
    [CmdletBinding ()]
    Param
    (
        [Parameter (Position = 0,
                    ValueFromPipeline)]
        [datetime[]]
        $Date = $(Get-Date),

        [Parameter (Position = 1)]
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
                $GD_Params = @{
                    MilliSecond = 0
                }
                break
            }
            'Second' {
                $GD_Params = @{
                    MilliSecond = 0
                    Second = 0
                }
                break
            }
            'Minute' {
                $GD_Params = @{
                    MilliSecond = 0
                    Second = 0
                    Minute = 0
                }
                break
            }
            'Hour' {
                $GD_Params = @{
                    MilliSecond = 0
                    Second = 0
                    Minute = 0
                    Hour = 0
                }
                break
            }
            'Day' {
                $GD_Params = @{
                    MilliSecond = 0
                    Second = 0
                    Minute = 0
                    Hour = 0
                    Day = 1
                }
                break
            }
            'Month' {
                $GD_Params = @{
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

    foreach ($D_Item in $Date)
        {
            $D_Item | Get-Date @GD_Params
        }
    } # end process {}

end {}

} # end function Get-TruncatedDate
