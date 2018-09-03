﻿<#######<Script>#######>
<#######<Header>#######>
# Name: Start-MarioThemeSong
# Copyright: Gerry Williams (https://www.gerrywilliams.net)
# License: MIT License (https://opensource.org/licenses/mit)
# Script Modified from: n/a
<#######</Header>#######>
<#######<Body>#######>
Function Start-MarioThemeSong
{
    <#
    .Synopsis
    Start-MarioThemeSong plays the Mario Theme Song.
    .Description
    Start-MarioThemeSong plays the Mario Theme Song.
    .Example
    Start-MarioThemeSong
    Start-MarioThemeSong plays the Mario Theme Song.
    #>    
    
    [Cmdletbinding()]

    Param
    (
    )

    Begin
    {
        Function Play-MarioIntro 
        {
            [console]::beep($E, $SIXTEENTH)
            [console]::beep($E, $EIGHTH)
            [console]::beep($E, $SIXTEENTH)
            Start-Sleep -m $SIXTEENTH
            [console]::beep($C, $SIXTEENTH)
            [console]::beep($E, $EIGHTH)
            [console]::beep($G, $QUARTER)
        }

        Function Play-MarioIntro2
        {
            [console]::beep($C, $EIGHTHDOT)
            [console]::beep($GbelowC, $SIXTEENTH)
            Start-Sleep -m $EIGHTH
            [console]::beep($EbelowG, $SIXTEENTH)
            Start-Sleep -m $SIXTEENTH
            [console]::beep($A, $EIGHTH)
            [console]::beep($B, $SIXTEENTH)
            Start-Sleep -m $SIXTEENTH
            [console]::beep($Asharp, $SIXTEENTH)
            [console]::beep($A, $EIGHTH)
            [console]::beep($GbelowC, $SIXTEENTHDOT)
            [console]::beep($E, $SIXTEENTHDOT)
            [console]::beep($G, $EIGHTH)
            [console]::beep($AHigh, $EIGHTH)
            [console]::beep($F, $SIXTEENTH)
            [console]::beep($G, $SIXTEENTH)
            Start-Sleep -m $SIXTEENTH
            [console]::beep($E, $EIGHTH)
            [console]::beep($C, $SIXTEENTH)
            [console]::beep($D, $SIXTEENTH)
            [console]::beep($B, $EIGHTHDOT)
            [console]::beep($C, $EIGHTHDOT)
            [console]::beep($GbelowC, $SIXTEENTH)
            Start-Sleep -m $EIGHTH
            [console]::beep($EbelowG, $EIGHTH)
            Start-Sleep -m $SIXTEENTH
            [console]::beep($A, $EIGHTH)
            [console]::beep($B, $SIXTEENTH)
            Start-Sleep -m $SIXTEENTH
            [console]::beep($Asharp, $SIXTEENTH)
            [console]::beep($A, $EIGHTH)
            [console]::beep($GbelowC, $SIXTEENTHDOT)
            [console]::beep($E, $SIXTEENTHDOT)
            [console]::beep($G, $EIGHTH)
            [console]::beep($AHigh, $EIGHTH)
            [console]::beep($F, $SIXTEENTH)
            [console]::beep($G, $SIXTEENTH)
            Start-Sleep -m $SIXTEENTH
            [console]::beep($E, $EIGHTH)
            [console]::beep($C, $SIXTEENTH)
            [console]::beep($D, $SIXTEENTH)
            [console]::beep($B, $EIGHTHDOT)
            Start-Sleep -m $EIGHTH
            [console]::beep($G, $SIXTEENTH)
            [console]::beep($Fsharp, $SIXTEENTH)
            [console]::beep($F, $SIXTEENTH)
            [console]::beep($Dsharp, $EIGHTH)
            [console]::beep($E, $SIXTEENTH)
            Start-Sleep -m $SIXTEENTH
            [console]::beep($GbelowCSharp, $SIXTEENTH)
            [console]::beep($A, $SIXTEENTH)
            [console]::beep($C, $SIXTEENTH)
            Start-Sleep -m $SIXTEENTH
            [console]::beep($A, $SIXTEENTH)
            [console]::beep($C, $SIXTEENTH)
            [console]::beep($D, $SIXTEENTH)
            Start-Sleep -m $EIGHTH
            [console]::beep($G, $SIXTEENTH)
            [console]::beep($Fsharp, $SIXTEENTH)
            [console]::beep($F, $SIXTEENTH)
            [console]::beep($Dsharp, $EIGHTH)
            [console]::beep($E, $SIXTEENTH)
            Start-Sleep -m $SIXTEENTH
            [console]::beep($CHigh, $EIGHTH)
            [console]::beep($CHigh, $SIXTEENTH)
            [console]::beep($CHigh, $QUARTER)
            [console]::beep($G, $SIXTEENTH)
            [console]::beep($Fsharp, $SIXTEENTH)
            [console]::beep($F, $SIXTEENTH)
            [console]::beep($Dsharp, $EIGHTH)
            [console]::beep($E, $SIXTEENTH)
            Start-Sleep -m $SIXTEENTH
            [console]::beep($GbelowCSharp, $SIXTEENTH)
            [console]::beep($A, $SIXTEENTH)
            [console]::beep($C, $SIXTEENTH)
            Start-Sleep -m $SIXTEENTH
            [console]::beep($A, $SIXTEENTH)
            [console]::beep($C, $SIXTEENTH)
            [console]::beep($D, $SIXTEENTH)
            Start-Sleep -m $EIGHTH
            [console]::beep($Dsharp, $EIGHTH)
            Start-Sleep -m $SIXTEENTH
            [console]::beep($D, $EIGHTH)
            [console]::beep($C, $QUARTER)
        }

    }
    
    Process
    {    
        #Set Speed and Tones
        If ($CHigh -eq $null)
        {
            $WHOLE = 2200
            $HALF = $WHOLE / 2
            $QUARTER = $HALF / 2
            $EIGHTH = $QUARTER / 2
            $SIXTEENTH = $EIGHTH / 2
            $EIGHTHDOT = $EIGHTH + $SIXTEENTH
            $QUARTERDOT = $QUARTER + $EIGHTH
            $SIXTEENTHDOT = $SIXTEENTH + ($SIXTEENTH / 2)

            $REST = 37
            $EbelowG = 164
            $GbelowC = 196
            $GbelowCSharp = 207
            $A = 220
            $Asharp = 233
            $B = 247
            $C = 262
            $Csharp = 277
            $D = 294
            $Dsharp = 311
            $E = 330
            $F = 349
            $Fsharp = 370
            $G = 392
            $Gsharp = 415
            $AHigh = 440
            $CHigh = 523
        }

        Play-MarioIntro
        Play-MarioIntro2

    }

    End
    {
    }

}

<#######</Body>#######>
<#######</Script>#######>