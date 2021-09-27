function Resolve-LastDayInMonth {
    param (
        [datetime]$Date = (Get-Date)
    )
    [datetime]::DaysInMonth(($Date.Year),($Date.Month))
}
