function Get-HolidayFilePath {
    [CmdletBinding()]
    param (
        
    )
    
    Join-Path (Split-Path $PSCommandPath -Parent) 'lib\Holidays.txt' 

}
