Describe 'PsDateTools Tests' {

    BeforeAll {
        Import-Module "PsDateTools" -ea 0 -Force
        $script:thisModule = Get-Module -Name "PsDateTools"
        $script:funcNames = $thisModule.ExportedCommands.Values |
            Where-Object {$_.CommandType -eq 'Function'} |
            Select-Object -ExpandProperty Name
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

        It -Tag 'new' 'Finds the oldest date in a range of times based on a date and 2 times' {
            $timeProps = @{}
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

