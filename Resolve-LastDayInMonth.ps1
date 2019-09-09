function Resolve-LastDayInMonth {
    param (
        [datetime]$Date = (Get-Date)
    )
    ($Date.AddMonths(1) | Get-TruncatedDate -Truncate Day).AddDays(-1).Day
}
