function ConvertFrom-GlobalDateString {
    param([string]$Date, $DateOrTimeOrBoth = 'Both')

    $Culture = Get-Culture
    $CultureDateTimeFormat = $Culture.DateTimeFormat
    $DateFormat = $CultureDateTimeFormat.ShortDatePattern
    $TimeFormat = $CultureDateTimeFormat.LongTimePattern
    $fmtDateTime = switch ($DateOrTimeOrBoth) {
        'Date' {$DateFormat} ;
        'Time' {$TimeFormat} ;
        'Both' {"$DateFormat $TimeFormat"} ;
        Default {'Unhandled parameter value'}
    }

    [DateTime]::ParseExact(
        $Date,
        $fmtDateTime,
        [System.Globalization.DateTimeFormatInfo]::InvariantInfo,
        [System.Globalization.DateTimeStyles]::None
    )
}
