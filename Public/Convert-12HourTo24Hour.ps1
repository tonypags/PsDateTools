function Convert-12HourTo24Hour
{
    param([string]$12Hour)

    $24Hour = switch ($12Hour)
    {
        '12AM' {00}
        '1AM' {01}
        '2AM' {02}
        '3AM' {03}
        '4AM' {04}
        '5AM' {05}
        '6AM' {06}
        '7AM' {07}
        '8AM' {08}
        '9AM' {09}
        '10AM' {10}
        '11AM' {11}
        '12PM' {12}
        '1PM' {13}
        '2PM' {14}
        '3PM' {15}
        '4PM' {16}
        '5PM' {17}
        '6PM' {18}
        '7PM' {19}
        '8PM' {20}
        '9PM' {21}
        '10PM' {22}
        '11PM' {23}
        Default {$null}
    }
    Write-Output $24Hour
}
