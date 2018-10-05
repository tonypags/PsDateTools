function Get-RfaHolidays {
    [CmdletBinding()]
    [OutputType([datetime[]])]
    param (
        
    )
    
    process {
        $Url = 'https://www.nyse.com/markets/hours-calendars'
        $SiteReply = Invoke-WebRequest -Uri $Url -DisableKeepAlive
        $rawTable = $SiteReply | Get-WebRequestTable

        # 1st record is column headers
        $ColumnOrder = $rawTable[0] | foreach {$_.P1,$_.P2,$_.P3,$_.P4}

        # All Dates can now be resolved from remaining rows
        $numRecords = $rawTable.count
        $rawTable[1..$numRecords] | Foreach-Object {
            Get-Date "$($_.P2.TrimEnd('*') -replace '\s\(.*\)') $($ColumnOrder[1])"
            Get-Date "$($_.P3.TrimEnd('*') -replace '\s\(.*\)') $($ColumnOrder[2])"
            Get-Date "$($_.P4.TrimEnd('*') -replace '\s\(.*\)') $($ColumnOrder[3])"
        }
    }
}
