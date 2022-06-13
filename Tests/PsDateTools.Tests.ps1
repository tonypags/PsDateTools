Describe 'PsDateTools Tests' {

    BeforeAll {
        Import-Module "PsDateTools" -ea 0 -Force
        $script:thisModule = Get-Module -Name "PsDateTools"
        $script:funcNames = $thisModule.ExportedCommands.Values |
            Where-Object {$_.CommandType -eq 'Function'} |
            Select-Object -ExpandProperty Name

        # dot-sourcing all functions: Required for Mocking
        Get-ChildItem   $PSScriptRoot\..\Private\*.ps1,
                        $PSScriptRoot\..\Public\*.ps1   |
        ForEach-Object {. $_.FullName}
    }

    Context 'Test Module import' {

        It 'Ensures module is imported' {
            $script:thisModule.Name | Should -Be 'PsDateTools'
        }

    }

    Context 'Test PsDateTools Functions' {

        # Remove the tested item from the initial array
        AfterEach {
            $script:funcNames = $script:funcNames | Where-Object {$_ -ne $script:thisName}
        }

        It 'Finds the datetime value for a given time and reference date' {
            $Date = Get-Date 'Monday, December 13, 2021 4:15:31 PM'
            $time = '23:55'
            $pastDate = Find-TimeInPastDay $time -Date $Date
            $pastDate.Day | Should -Be 12
            $pastDate.Hour | Should -Be 23
            $pastDate.Minute | Should -Be 55
            $time = '23:55:46'
            $pastDate = Find-TimeInPastDay $time -Date $Date
            $pastDate.Second | Should -Be 46
            $time = '23:05:01.999'
            $pastDate = Find-TimeInPastDay $time -Date $Date
            $pastDate.Minute | Should -Be 5
            $pastDate.Millisecond | Should -Be 999

        }

        It 'Test if a given time is between 2 other given times' {
            @(
                (Test-TimeInRange -ref '12:00:30' -Start '12:00' -End '17:00'),
                (Test-TimeInRange -ref '12:00' -Start '22:00' -End '05:00:00'),
                (Test-TimeInRange -ref '02:00:00' -Start '22:00:00' -End '05:00')
            ) | Should -Be @($true, $false, $true)
        }




        It -tag 'draft' 'Finds the oldest date in a range of times' {
            # based on a date, a frequency(timespan), and 2 times
            $timeProps = @{}
            # The frequency (timespan) expected within the timeframe
            $timeProps.Frequency = $null
            # The date being referenced (normally current datetime)
            $timeProps.Date = $null
            # The start time (HH:mm[:ss] string or datetime with date-part ignored)
            $timeProps.StartTime = $null
            # The end time (HH:mm[:ss] string or datetime with date-part ignored)
            $timeProps.EndTime = $null

            # Test actionable timeframes
            $Times = @(
                @('17:00','21:00')
                @('23:00','05:00')
                @('01:00','09:00')
                @('01:00','23:59')
            )
            # Test reference dates
            $Refs = @(
                '14:00'
                '19:00'
                '22:00'
                '23:30'
                '00:30'
                '03:00'
                '07:00'
                '10:00'
            )

            foreach ($time in $Times) {
                $timeProps.StartTime = $time[0]
                $timeProps.EndTime = $time[-1]
                foreach ($ref in $Refs) {
                    $timeProps.Date = $ref
                    $oldestTime = Find-TimeInRange @timeProps
                    # The oldest time is less than the ref time
                    $oldestTime | Should -BeLessOrEqual $timeProps.Date
                    # The oldest time is less than the -1 index
                    $oldestTime | Should -BeLessOrEqual $timeProps.EndTime
                    # The oldest time is more than the 0 index
                    $oldestTime | Should -BeGreaterOrEqual $timeProps.StartTime
                }
            }

            $oldestTime = Find-TimeInRange -Date [datetime]'1/1/2020 23:59:59.999' -StartTime '22:00' -EndTime '23:59:59.999'

            $script:thisName = 'Find-TimeInRange'
        }

    }

    Context 'Clean up' {

        It 'Ensures all public functions have tests' {
            $script:funcNames | Should -BeNullOrEmpty
        }
        
    }

}

