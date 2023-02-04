param(
    [Parameter()]
    [int]
    $year = (Get-Date).Year
)

# EASTER is 1st Sunday after 1st Full Moon after 1st Day of Spring (Paschal Moon)
# Calculate the Golden Number (GN)
$GN = ($year % 19) + 1

# correction c requires solar s and leap l
$s = ($year - 1600) / 100 - ($year - 1600) / 400
$l = ((($year - 1400) / 100) * 8) / 25
$c = $s - $l

# Calculate P-prime
$PFM = (-11 * ($GN - 3) + $c) % 30
$PFM = (33 - (11 * $GN) + $c) % 30
# = (33 − 11g + c) mod 30
# = (3 − 11g + c) mod 30

# # Calculate the Century (C)
# $C = [int]($year / 100) + 1
# # Calculate the Moon Correction (MC)
# # $MC = [int]((3 * $C) / 4) - 12
# $MC = ((3 * $C) / 4) - 12
# # Calculate the Epact (E)
# # $E = [int]((8 * $C + 5) / 25) - 5
# $E = ((8 * $C + 5) / 25) - 5
# # Calculate the Solar Correction (SC)
# # $SC = [int]((5 * ($year % 4) + 4) / 4)
# [int]$SC = (5 * ($year % 4) + 4) / 4
# # Calculate the Lunar Correction (LC)
# [int]$LC = (11 * $GN + 20 + $MC - $E + $SC) % 30
# # Calculate the Paschal Full Moon (PFM)
# $PFM = 44 - $LC

# If PFM is greater than 31, then subtract 31 from it and add 1 to the month
if ($PFM -gt 31) {
    $PFM -= 31
    $month = 4
} else {
    $month = 3
}
Write-Host "The Paschal Full Moon for $year is $month/$PFM"

#Use the decimal to find the time of day of the full moon -TP
$dd = [math]::Floor($PFM)
$pctDay = if ($PFM % 1) {
    "$PFM" -replace '^\d+'
} else {'00'}
$decHH = 24 * $pctDay
$HH = [math]::Floor($decHH)
$pctHour = if ($decHH % 1) {
    "$decHH" -replace '^\d+'
} else {'00'}
$DECmm = 60 * $pctHour
$mm = [math]::Floor($DECmm)
# throw away the seconds






# https://www.whydomath.org/Reading_Room_Material/ian_stewart/2000_03.html

# 1. Divide x by 19 to get a quotient (which we ignore) and a remainder A. This is the year’s position in the 19-year lunar cycle. (A + 1 is the year’s Golden Number.)
$A = ($year % 19)
$GN = $A + 1

# 2. Divide x by 100 to get a quotient B and a remainder C.
$B = [math]::Floor($year / 100)
$C = $year % 100

# 3. Divide B by 4 to get a quotient D and a remainder E.
$D = $B / 4
$E = $B % 4

# 4. Divide 8B + 13 by 25 to get a quotient G and a remainder (which we ignore).
$B = [math]::Floor(((8 * $B) + 13) / 25)

# 5. Divide 19A + B – D – G + 15 by 30 to get a quotient (which we ignore) and a remainder H.
$H = (19 * $A) + $B - $D - $G + 15 % 30

# (The year’s Epact is 23 – H when H is less than 24 and 53 – H otherwise.)
$Epact = if ($H -lt 24) {
    23 - $H
} else {
    53 - $H
}

# 6. Divide A + 11H by 319 to get a quotient M and a remainder (which we ignore).
$M = [math]::Floor(($A + (11 * $H)) / 39)

# 7. Divide C by 4 to get a quotient J and a remainder K.
$J = [math]::Floor($C / 4)
$K = $C % 4

# 8. Divide 2E + 2J – K – H + M + 32 by 7 to get a quotient (which we ignore) and a remainder L.
$L = ((2 * $E) + (2 * $J) - $K - $H + $M + 32) % 7

# 9. Divide H – M + L + 90 by 25 to get a quotient N and a remainder (which we ignore).
$N = [math]::Floor(($H - $M + $L + 90) / 25)

# 10. Divide H – M + L + N + 19 by 32 to get a quotient (which we ignore) and a remainder P.
$P = ($H - $M + $L + $N + 19) % 32

# Easter Sunday is the Pth day of the Nth month (N can be either 3 for March or 4 for April). 
$easter = Get-Date "$N/$P/$year"
# The year’s dominical letter can be found by dividing 2E + 2J – K by 7 and taking the remainder
# (a remainder of 0 is equivalent to the letter A, 1 is equivalent to B, and so on).




# Find the next Sunday after the PFM, this is Easter
$PaschalFullMoon = Get-Date "$month/$dd/$Year $($HH):$($mm)"

# This is 1  week too early.
###Looking at wiki for help
###Also double check robot logic
$EasterSunday = $PaschalFullMoon | Find-Weekday -DayOfWeek Sunday
$GoodFriday = $EasterSunday | Find-Weekday -DayOfWeek Friday -Backwards
$PalmSunday = $EasterSunday | Find-Weekday -DayOfWeek Sunday -Backwards

$EasterSunday
$GoodFriday 
$PalmSunday 
