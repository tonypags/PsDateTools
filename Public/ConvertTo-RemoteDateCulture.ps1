function ConvertTo-RemoteDateCulture {
    [CmdletBinding()]
    param (
        [string]$Date,
        [string]$ComputerName
    )

    begin {
    }

    process {
    }

    end {
        # Call out to the remote machine
        Try{
            $CultureDateTimeFormat = (
                Invoke-Command -ComputerName $Computer -ScriptBlock {
                    Get-Culture} -ea Stop).DateTimeFormat
            $DateFormat = $CultureDateTimeFormat.ShortDatePattern
            $TimeFormat = $CultureDateTimeFormat.LongTimePattern
            $DateTimeFormat = "$DateFormat $TimeFormat"

            # Output the info
            [DateTime]::ParseExact(
                $Date,
                $DateTimeFormat,
                [System.Globalization.DateTimeFormatInfo]::InvariantInfo,
                [System.Globalization.DateTimeStyles]::None
            )
        }
        Catch{
            Write-Error "Unable to PsRemote into $Computer!" -ea Continue
        }
    }
}
