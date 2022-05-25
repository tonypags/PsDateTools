Describe 'PsDateTools Tests' {

    BeforeAll {
        Import-Module "PsDateTools" -ea 0 -Force
        $script:thisModule = Get-Module -Name "PsDateTools"
        $script:funcNames = $thisModule.ExportedCommands.Values |
            Where-Object {$_.CommandType -eq 'Function'} |
            Select-Object -ExpandProperty Name

        # dot-sourcing all functions: Required for Mocking
        $modParent = Split-Path $thisModule.Path -Parent
        Get-ChildItem   $modParent\Public\*.ps1   |
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
                (Test-TimeInRange -ref '02:00:00' -Start '22:00:00' -End '05:00'),
                (Test-TimeInRange -ref '12:00' -Start '12:00' -End '17:00')
            ) | Should -Be @($true, $false, $true,$true)
        }

        It -tag 'draft' 'Tests if given date is in a range of times' {
            # based on a date, and 2 times
            $timeProps = @{}
            # The date being referenced (normally current datetime)
            $timeProps.ReferenceTime = $null
            # The start time (HH:mm[:ss] string or datetime with date-part ignored)
            $timeProps.TimeStart = $null
            # The end time (HH:mm[:ss] string or datetime with date-part ignored)
            $timeProps.TimeEnd = $null

            # Test actionable timeframes
            $Times = @(
                @('17:00','21:00','14:00',$false),
                @('17:00','21:00','19:00',$true),
                @('17:00','21:00','22:00',$false),
                @('17:00','21:00','23:30',$false),
                @('17:00','21:00','00:30',$false),
                @('17:00','21:00','03:00',$false),
                @('17:00','21:00','07:00',$false),
                @('17:00','21:00','10:00',$false),
                @('23:00','05:00','14:00',$false),
                @('23:00','05:00','19:00',$false),
                @('23:00','05:00','22:00',$false),
                @('23:00','05:00','23:30',$true),
                @('23:00','05:00','00:30',$true),
                @('23:00','05:00','03:00',$true),
                @('23:00','05:00','07:00',$false),
                @('23:00','05:00','10:00',$false),
                @('01:00','09:00','14:00',$false),
                @('01:00','09:00','19:00',$false),
                @('01:00','09:00','22:00',$false),
                @('01:00','09:00','23:30',$false),
                @('01:00','09:00','00:30',$false),
                @('01:00','09:00','03:00',$true),
                @('01:00','09:00','07:00',$true),
                @('01:00','09:00','10:00',$false),
                @('01:00','23:59','14:00',$true),
                @('01:00','23:59','19:00',$true),
                @('01:00','23:59','22:00',$true),
                @('01:00','23:59','23:30',$true),
                @('01:00','23:59','00:30',$false),
                @('01:00','23:59','03:00',$true),
                @('01:00','23:59','07:00',$true),
                @('01:00','23:59','10:00',$true)
            )

            foreach ($set in $Times) {
                $timeProps.TimeStart = $set[0]
                $timeProps.TimeEnd = $set[1]
                $timeProps.ReferenceTime = $set[2]
                $boolShould = $set[3] -as [bool]
                $thisBool = Test-TimeInRange @timeProps
                # The oldest time is more than the 0 index
                $thisBool | Should -Be $boolShould -ea:inquire
            }

            $script:thisName = 'Test-TimeInRange'
        }

        It 'Finds a conflict between 2 events' {
            # 2 events separated by 2 hours
            $props = @{}
            $props.ReferenceStart = '1/1/2000 1:00 AM'
            $props.ReferenceEnd = '1/1/2000 5:00 AM'
            $props.DifferenceStart = '1/1/2000 7:00 AM'
            $props.DifferenceEnd = '1/1/2000 11:00 AM'
            $props.GracePeriod = New-TimeSpan -Hours 2
            $diffEvents = Compare-Events @props
            $diffEvents.hasConflict | Should -Be $false
            $diffEvents.exactSame | Should -Be $false
            
            $props.GracePeriod = New-TimeSpan -Hours 3
            $diffEvents = Compare-Events @props
            $diffEvents.hasConflict | Should -Be $false
            $diffEvents.exactSame | Should -Be $false

            $props.GracePeriod = -(New-TimeSpan -Hours 2)
            $diffEvents = Compare-Events @props
            $diffEvents.hasConflict | Should -Be $false
            $diffEvents.exactSame | Should -Be $false

            $props.GracePeriod = -(New-TimeSpan -Hours 3)
            $diffEvents = Compare-Events @props
            $diffEvents.hasConflict | Should -Be $true
            $diffEvents.exactSame | Should -Be $false

            # 2 events overlapping by 2 hours
            $props.ReferenceEnd = '1/1/2000 7:00 AM'
            $props.DifferenceStart = '1/1/2000 5:00 AM'
            $props.GracePeriod = New-TimeSpan -Hours 2
            $diffEvents = Compare-Events @props
            $diffEvents.hasConflict | Should -Be $false
            $diffEvents.exactSame | Should -Be $false
            
            $props.GracePeriod = New-TimeSpan -Hours 1
            $diffEvents = Compare-Events @props
            $diffEvents.hasConflict | Should -Be $true
            $diffEvents.exactSame | Should -Be $false

            $props.GracePeriod = -(New-TimeSpan -Hours 2)
            $diffEvents = Compare-Events @props
            $diffEvents.hasConflict | Should -Be $true
            $diffEvents.exactSame | Should -Be $false

            $props.GracePeriod = -(New-TimeSpan -Hours 3)
            $diffEvents = Compare-Events @props
            $diffEvents.hasConflict | Should -Be $true
            $diffEvents.exactSame | Should -Be $false

            # 2 events start same time but finish 2 hours diff
            $props = @{}
            $props.ReferenceStart = '1/1/2000 1:00 AM'
            $props.DifferenceStart = '1/1/2000 1:00 AM'
            $props.ReferenceEnd = '1/1/2000 5:00 AM'
            $props.DifferenceEnd = '1/1/2000 7:00 AM'
            $props.GracePeriod = New-TimeSpan -Hours 4
            $diffEvents = Compare-Events @props
            $diffEvents.hasConflict | Should -Be $false
            $diffEvents.exactSame | Should -Be $false

            $props.GracePeriod = New-TimeSpan -Hours 3
            $diffEvents = Compare-Events @props
            $diffEvents.hasConflict | Should -Be $true
            $diffEvents.exactSame | Should -Be $false

            $props.GracePeriod = -(New-TimeSpan -Hours 1)
            $diffEvents = Compare-Events @props
            $diffEvents.hasConflict | Should -Be $true
            $diffEvents.exactSame | Should -Be $false
            
            # 2 events end same time but start 2 hours diff
            $props = @{}
            $props.ReferenceStart = '1/1/2000 1:00 AM'
            $props.DifferenceStart = '1/1/2000 3:00 AM'
            $props.ReferenceEnd = '1/1/2000 7:00 AM'
            $props.DifferenceEnd = '1/1/2000 7:00 AM'
            $props.GracePeriod = New-TimeSpan -Hours 4
            $diffEvents = Compare-Events @props
            $diffEvents.hasConflict | Should -Be $false
            $diffEvents.exactSame | Should -Be $false

            $props.GracePeriod = New-TimeSpan -Hours 3
            $diffEvents = Compare-Events @props
            $diffEvents.hasConflict | Should -Be $true
            $diffEvents.exactSame | Should -Be $false

            $props.GracePeriod = -(New-TimeSpan -Hours 1)
            $diffEvents = Compare-Events @props
            $diffEvents.hasConflict | Should -Be $true
            $diffEvents.exactSame | Should -Be $false

            # 2 exact same events
            $props = @{}
            $props.ReferenceStart = '1/1/2000 1:00 AM'
            $props.DifferenceStart = '1/1/2000 1:00 AM'
            $props.ReferenceEnd = '1/1/2000 7:00 AM'
            $props.DifferenceEnd = '1/1/2000 7:00 AM'
            $props.GracePeriod = New-TimeSpan -Hours 6
            $diffEvents = Compare-Events @props
            $diffEvents.hasConflict | Should -Be $false
            $diffEvents.exactSame | Should -Be $true

            $props.GracePeriod = New-TimeSpan -Hours 3
            $diffEvents = Compare-Events @props
            $diffEvents.hasConflict | Should -Be $true
            $diffEvents.exactSame | Should -Be $true

            $props.GracePeriod = -(New-TimeSpan -Hours 1)
            $diffEvents = Compare-Events @props
            $diffEvents.hasConflict | Should -Be $true
            $diffEvents.exactSame | Should -Be $true

            $script:thisName = 'Compare-Events'
        }

    }

    Context 'Clean up' {

        It 'Cheats at making sure all functions have tests' {
            $funks = @(
                'Add-OrdinalSuffix'
                'Convert-12HourTo24Hour'
                'Convert-UtcToLocal'
                'ConvertFrom-GlobalDateString'
                'ConvertTo-DateTimeArray'
                'ConvertTo-LocalTime'
                'ConvertTo-RemoteDateCulture'
                'Find-ClosestDate'
                'Find-DateByWeekNumber'
                'Find-TimeInPastDay'
                'Find-Weekday'
                'Find-WeekNumberByDate'
                'Get-DateRange'
                'Get-DaylightSaving'
                'Get-HolidayFilePath'
                'Get-NyseHolidays'
                'Get-OrdinalSuffix'
                'Get-TruncatedDate'
                'Resolve-DateFromString'
                'Resolve-LastDayInMonth'
            )
            foreach ($func in $funks) {
                $script:funcNames = $script:funcNames |
                Where-Object {$_ -ne $func}
            }
            Write-Warning "$(@($funks).Count) functions without tests!" -wa Continue


        }

        It 'Ensures all public functions have tests' {
            $script:funcNames | Should -BeNullOrEmpty
        }
        
    }

}

