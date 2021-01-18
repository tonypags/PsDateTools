function Get-NyseHoliday {
    <#
    .SYNOPSIS
    Returns the dates of the NYSE-observed holidays.
    .DESCRIPTION
    Returns the dates of the NYSE-observed holidays for a given timeframe, or the next dates by default.  
    .EXAMPLE
    Get-NyseHoliday
    Monday, January 18, 2021 4:35:39 PM
    Assume the current date is 1/1/2021
    .OUTPUTS
    Outputs an array of datetime objects.
    #>
    [CmdletBinding()]
    param (

        <# Returns dates from a different year (Default is current year)
        [Parameter()]
        [int]
        $Year#>
    
    )
    
    begin {
        
        $arrHolidates = @()
        #$thisYear = (Get-Date).Year
        
    }
    
    end {
        
        <# Handle the Year parameter if entered
        $yearOffset = if ($Year) {

            # Figure out how many years to add to the current year
            $Year - $thisYear

        } else {
            $Year = $thisYear
            0
        }
        # year support for next version #>


        # Code logic to find each one of these dates. 
        #leverage Find-DateByWeekNumber for some of these.
    

        # Figure out how each date is calculated.
        # How is good friday defined. 
        #first sunday after first full moon after spring equinox.
        #We need a function to find full moons
        #We need a function to find solstice and equinox
        # IMPOSSIBLE!?


        # How is Martin Luther King, Jr. Day observed on the third Monday of January each year. 
        $ThirdMondayJanSplat = @{
            Ordinal = '3rd'
            DayOfWeek = 'Monday'
            Month = 'January'
        }

        # How is Washington's Birthday defined as the third Monday of February
        $ThirdMondayFebSplat = @{
            Ordinal = '3rd'
            DayOfWeek = 'Monday'
            Month = 'February'
        }

        # memorial day and labor day on the last Monday of May
        $LastMondayMaySplat = @{
            Ordinal = 'Last'
            DayOfWeek = 'Monday'
            Month = 'May'
        }

        # Labor day is the first Monday in September 
        $FirstMondaySeptSplat = @{
            Ordinal = '1st'
            DayOfWeek = 'Monday'
            Month = 'September'
        }

        # LThanksgiving is the fourth Thursday in November
        $FourthThursNovSplat = @{
            Ordinal = '4th'
            DayOfWeek = 'Thursday'
            Month = 'November'
        }

        $LastMondayOfMay = Find-DateByWeekNumber @LastMondayMaySplat
        $ThirdMondayOfJan = Find-DateByWeekNumber @ThirdMondayJanSplat
        $ThirdMondayOfFeb = Find-DateByWeekNumber @ThirdMondayFebSplat
        $FirstMondaySept = Find-DateByWeekNumber @FirstMondaySeptSplat
        $FourthThursNov =
         Find-DateByWeekNumber @FourthThursNovSplat


        # List all holidays observed by the NYSE.
        # By default the year will be the current year, optional calc from there.
        $arrHolidates += [PSCustomObject]@{
            Method = 'Static'
            Date = [datetime]"January 1, $($Year)"
            Name = "New Years Day"
        }
        $arrHolidates += [PSCustomObject]@{
            Method = 'WeekNumber'
            Date = $ThirdMondayOfJan
            Name = "Martin Luther King, Jr. Day"
        }
        $arrHolidates += [PSCustomObject]@{
            Method = 'WeekNumber'
            Date = $ThirdMondayOfFeb
            Name = "Washington's Birthday"
        }
        $arrHolidates += [PSCustomObject]@{
            Method = 'Other'
            Date = $null
            Name = "Good Friday"
        }
        $arrHolidates += [PSCustomObject]@{
            Method = 'WeekNumber'
            Date = $LastMondayOfMay
            Name = "Memorial Day"
        }
        $arrHolidates += [PSCustomObject]@{
            Method = 'Static'
            Date = [datetime]"July 4, $($Year)"
            Name = "Independence Day"
        }
        $arrHolidates += [PSCustomObject]@{
            Method = 'WeekNumber'
            Date = $FirstMondaySept
            Name = "Labor Day"
        }
        $arrHolidates += [PSCustomObject]@{
            Method = 'WeekNumber'
            Date = $FourthThursNov
            Name = "Thanksgiving Day"
        }
        $arrHolidates += [PSCustomObject]@{
            Method = 'Static'
            Date = [datetime]"December 24, $($Year)"
            Name = "Christmas Day"
        }
    
        Foreach ($Date in $arrHolidates) {
            
            # Figure out if the actual date is a weekend
            switch ($Date.Date.DayOfWeek) {
                
                # re-calculate that date and return its observed date.
                'Saturday' {$Date.Date = $Date.Date.AddDays(-1)}
                'Sunday'   {$Date.Date = $Date.Date.AddDays(1)}
                Default    {<#DO NOTHING#>}

            }#END: switch ($Date.Date.DayOfWeek)
         
        }#END: Foreach ($Date in $arrHolidates)
    

        # Return the final date (array) to the pipeline.
        Write-Output $arrHolidates

    }

}#END: Get-NyseHoliday
