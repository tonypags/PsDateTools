function Find-WeekNumberByDate
{
   <#
   .Synopsis
      Will check a given date for its week number.
   .DESCRIPTION
      Resolves the number of the week in which the day of the 
      given month falls.
   .PARAMETER Date
      The date(s) to amalyze.
   .EXAMPLE
      Find-WeekNumberByDate '3/30/2018' |fl

      Ordinal          : 5th
      OrdinalWeekday   : 5th Friday
      WeekNumber       : 5
      isLastWeek       : True
      OrdinalWithMonth : 5th Friday of March
      Date             : 3/30/2018 12:00:00 AM
      DayOfWeek        : Friday
      Month            : March
   .INPUTS
      This function accepts datetime objects.
   .OUTPUTS
      Output from this cmdlet is a PsCustomObject.
   #>
   [CmdletBinding(DefaultParameterSetName='MonthRange', 
                  PositionalBinding=$false)]
   [OutputType([datetime[]])]
   Param
   (
      # The date(s) to amalyze.
      [Parameter(Position=0,
                  ValueFromPipeline=$true,
                  ValueFromPipelineByPropertyName=$true)]
      [datetime]
      $Date=(Get-Date)
   )

   Begin
   {
   }
   Process
   {
      # Week number is truncated dividend of 7, plus 1
      $WeekNumber = [math]::Truncate(($Date.Day) / 7) + 1

      # Determine the ordinal
      $Suffix = Get-OrdinalSuffix -num $WeekNumber
      
      # Determine if this date is in the last week or not
      $LastDayInMonth = Resolve-LastDayInMonth -Date $Date
      $isLastWeek = ($Date.Day + 6) -ge $LastDayInMonth

      # output all the properties.
      New-Object psobject -Property @{
         Date = $Date
         isLastWeek = $isLastWeek
         WeekNumber = $WeekNumber
         DayOfWeek = $Date.DayOfWeek
         Month = $Date.ToString('MMMM')
         Ordinal = "$($WeekNumber)$($Suffix)"
         OrdinalWeekday = "$($WeekNumber)$($Suffix) $($Date.DayOfWeek)"
         OrdinalWithMonth = "$($WeekNumber)$($Suffix) $($Date.DayOfWeek) of $($Date.ToString('MMMM'))"
      }
   }
   End
   {
   }
}
