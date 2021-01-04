function Get-NyseHolidays {
    [CmdletBinding()]
    [OutputType([datetime[]])]
    param (
        
    )
    
    Process {
        # Look at the stored values for this first.
        $HolidayFilePath = Get-HolidayFilePath
        $staticHolidays = (Get-Content $HolidayFilePath) -as [datetime[]] | Sort-Object
        if ($staticHolidays[-1] -gt (Get-Date)) {
            Write-Output $staticHolidays
        
        # Otherwise, attempt to re-populate the stored value.
        } else {
            $Url = 'https://www.nyse.com/markets/hours-calendars'
            $SiteReply = Invoke-WebRequest -Uri $Url -DisableKeepAlive
            $rawTable = $SiteReply | Get-WebRequestTable
            $rawHeaders = $rawTable |
                Get-Member |
                Where-Object {$_.MemberType -eq 'NoteProperty'} |
                Select -ExpandProperty Name

            if ($rawHeaders -contains 'P4') {

                # This is the way to handle the table where there are no column headers
                # 1st record is column headers
                $ColumnOrder = $rawTable[0] | foreach {$_.P1,$_.P2,$_.P3,$_.P4}

                # All Dates can now be resolved from remaining rows
                $numRecords = $rawTable.count
                $rawTable[1..($numRecords-1)] | Foreach-Object {
                    Get-Date "$($_.P2.TrimEnd('*') -replace '\s\(.*\)') $($ColumnOrder[1])"
                    Get-Date "$($_.P3.TrimEnd('*') -replace '\s\(.*\)') $($ColumnOrder[2])"
                    Get-Date "$($_.P4.TrimEnd('*') -replace '\s\(.*\)') $($ColumnOrder[3])"
                }
            } elseif ($rawHeaders -contains 'HOLIDAY') {
                # Make an emply collection
                $DateSet = New-Object System.Collections.ArrayList
                
                # Get the year numbers from the column headers
                $YearSet  = ($rawHeaders | Sort-Object)[0..2]

                # Get the Holiday names
                $HolidayNameSet = $rawTable.HOLIDAY
                
                # Loop thru each year and return all dates to the collection
                Foreach ($Year in $YearSet) {
                    Foreach ($Holiday in $HolidayNameSet) {
                        $rawYearlessDate = $rawTable |
                            Where-Object {$_.HOLIDAY -eq $Holiday } |
                            Select-Object -ExpandProperty $Year
                        $YearlessDate = $rawYearlessDate.TrimEnd('*') -replace '\s\(.*\)'
                        $DateToAdd = Get-Date "$($YearlessDate) $($Year)"
                        [void]($DateSet.Add($DateToAdd))
                    }
                }#Foreach ($Year in $YearSet) {
                $DateSet | Add-Content -Path $HolidayFilePath
                Write-Output $DateSet
            } else {
                throw 'No Match for table handler!'
            }#if ($rawHeaders -contains 'P4') {
        }#if ($staticHolidays[-1] -gt (Get-Date)) {
    }
}
