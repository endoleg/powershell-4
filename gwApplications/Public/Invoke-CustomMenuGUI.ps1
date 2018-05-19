<#######<Script>#######>
<#######<Header>#######>
# Name: Invoke-CustomMenuGUI
# Copyright: Gerry Williams (https://www.gerrywilliams.net)
# License: MIT License (https://opensource.org/licenses/mit)
# Script Modified from: n/a
<#######</Header>#######>
<#######<Body>#######>

Function Invoke-CustomMenuGUI
{
    <#
.Synopsis
Creates a form that is used to launch pre-defined scripts from.
.Description
Creates a form that is used to launch pre-defined scripts from.
.Parameter Logfile
Specifies A Logfile. Default is $PSScriptRoot\..\Logs\Scriptname.Log and is created for every script automatically.
NOTE: If you wish to delete the logfile, I have updated my scripts to where they should still run fine with no logging.
.Example
Invoke-CustomMenuGUI
Creates a form that is used to launch pre-defined scripts from.
.Notes
2017-09-08: v1.0 Initial script 
.Functionality
Please see https://www.gerrywilliams.net/2017/09/running-ps-scripts-against-multiple-computers/ on how to run against multiple computers.

#>    
    [Cmdletbinding()]

    Param
    (
        [String]$Logfile = "$PSScriptRoot\..\Logs\Invoke-CustomMenuGUI.Log"
    )

    Begin
    {
    		
        Function Initialize-Window
        {
            $t = '[DllImport("user32.dll")] public static extern bool ShowWindow(int handle, int state);'
            Add-Type -Name Win -Member $t -Namespace native
            [native.win]::ShowWindow(([System.Diagnostics.Process]::GetCurrentProcess() | Get-Process).MainWindowHandle, 0)
        }
        Initialize-Window

        $StartPowershell = 
        { 
            Powershell.exe Start-Process Powershell -Verb runas 
        }

        $StartPowershellISE = 
        { 
            Powershell.exe Start-Process "Powershell_ise" -Verb runas 
        }

        $RunMyScript = 
        { 
            Start-Process Powershell -Argument "C:\_ill\google\_myprogs\ill\resources\invokepassword.ps1"
        }

        $EndForm = 
        { 
            Stop-Process -id $pid
        }

        If ($($Logfile.Length) -gt 1)
        {
            $EnabledLogging = $True
        }
        Else
        {
            $EnabledLogging = $False
        }
    
        Filter Timestamp
        {
            "$(Get-Date -Format "yyyy-MM-dd hh:mm:ss tt"): $_"
        }

        If ($EnabledLogging)
        {
            # Create parent path and logfile if it doesn't exist
            $Regex = '([^\\]*)$'
            $Logparent = $Logfile -Replace $Regex
            If (!(Test-Path $Logparent))
            {
                New-Item -Itemtype Directory -Path $Logparent -Force | Out-Null
            }
            If (!(Test-Path $Logfile))
            {
                New-Item -Itemtype File -Path $Logfile -Force | Out-Null
            }
    
            # Clear it if it is over 10 MB
            $Sizemax = 10
            $Size = (Get-Childitem $Logfile | Measure-Object -Property Length -Sum) 
            $Sizemb = "{0:N2}" -F ($Size.Sum / 1mb) + "Mb"
            If ($Sizemb -Ge $Sizemax)
            {
                Get-Childitem $Logfile | Clear-Content
                Write-Verbose "Logfile has been cleared due to size"
            }
            # Start writing to logfile
            Start-Transcript -Path $Logfile -Append 
            Write-Output "####################<Script>####################"
            Write-Output "Script Started on $env:COMPUTERNAME" | TimeStamp
        }
    }
    
    Process
    {   
        Add-Type -AssemblyName System.Windows.Forms
        $Form = New-Object system.Windows.Forms.Form 
        $Form.Text = "GerrysScripts"
        $Form.TopMost = $true
        $Form.BackColor = "#0b0b0b"
        $Form.Width = 256
        $Form.Height = 410

        $label = New-Object system.windows.Forms.Label 
        $label.Text = "Select A Task `r`nTo Run:"
        $label.AutoSize = $true
        $label.ForeColor = "#0CF110"
        $label.Width = 217
        $label.Height = 10
        $label.location = new-object system.drawing.point(5, 19)
        $label.Font = "Verdana,12"
        $Form.controls.Add($label) 

        $button = New-Object system.windows.Forms.Button 
        $button.Text = "StartPS"
        $button.ForeColor = "#0CF110"
        $button.Width = 159
        $button.Height = 23
        $button.location = new-object system.drawing.point(4, 70)
        $button.Font = "Verdana,10"
        $button.Add_Click($StartPowershell)
        $Form.controls.Add($button)
 
        $button2 = New-Object system.windows.Forms.Button 
        $button2.Text = "StartISE"
        $button2.ForeColor = "#0CF110"
        $button2.Width = 159
        $button2.Height = 23
        $button2.location = new-object system.drawing.point(4, 100)
        $button2.Font = "Verdana,10"
        $button2.Add_Click($StartPowershellISE)
        $Form.controls.Add($button2)

        $button3 = New-Object system.windows.Forms.Button 
        $button3.Text = "button"
        $button3.ForeColor = "#0CF110"
        $button3.Width = 159
        $button3.Height = 23
        $button3.location = new-object system.drawing.point(4, 130)
        $button3.Font = "Verdana,10"
        $button3.Add_Click($RunMyScript)
        $Form.controls.Add($button3) 

        $button4 = New-Object system.windows.Forms.Button 
        $button4.Text = "button"
        $button4.ForeColor = "#0CF110"
        $button4.Width = 159
        $button4.Height = 23
        $button4.location = new-object system.drawing.point(4, 160)
        $button4.Font = "Verdana,10"
        $button4.Add_Click($StartPowershellISE)
        $Form.controls.Add($button4)

        $button5 = New-Object system.windows.Forms.Button 
        $button5.Text = "button"
        $button5.ForeColor = "#0CF110"
        $button5.Width = 159
        $button5.Height = 23
        $button5.location = new-object system.drawing.point(4, 190)
        $button5.Font = "Verdana,10"
        $button5.Add_Click($StartPowershellISE)
        $Form.controls.Add($button5) 

        $button6 = New-Object system.windows.Forms.Button 
        $button6.Text = "button"
        $button6.ForeColor = "#0CF110"
        $button6.Width = 159
        $button6.Height = 23
        $button6.location = new-object system.drawing.point(4, 220)
        $button6.Font = "Verdana,10"
        $button6.Add_Click($StartPowershellISE)
        $Form.controls.Add($button6) 

        $button7 = New-Object system.windows.Forms.Button 
        $button7.Text = "button"
        $button7.ForeColor = "#0CF110"
        $button7.Width = 159
        $button7.Height = 23
        $button7.location = new-object system.drawing.point(4, 250)
        $button7.Font = "Verdana,10"
        $button7.Add_Click($StartPowershellISE)
        $Form.controls.Add($button7) 

        $button8 = New-Object system.windows.Forms.Button 
        $button8.Text = "button"
        $button8.ForeColor = "#0CF110"
        $button8.Width = 159
        $button8.Height = 23
        $button8.location = new-object system.drawing.point(4, 280)
        $button8.Font = "Verdana,10"
        $button8.Add_Click($StartPowershellISE)
        $Form.controls.Add($button8)

        $button9 = New-Object system.windows.Forms.Button 
        $button9.Text = "button"
        $button9.ForeColor = "#0CF110"
        $button9.Width = 159
        $button9.Height = 23
        $button9.location = new-object system.drawing.point(4, 310)
        $button9.Font = "Verdana,10"
        $button9.Add_Click($StartPowershellISE)
        $Form.controls.Add($button9)

        $button10 = New-Object system.windows.Forms.Button 
        $button10.Text = "Close Form"
        $button10.ForeColor = "#0CF110"
        $button10.Width = 159
        $button10.Height = 23
        $button10.location = new-object system.drawing.point(4, 340)
        $button10.Font = "Verdana,10"
        $button10.Add_Click($EndForm)
        $Form.controls.Add($button10) 

        $Form.ShowDialog() | out-null   
    }

    End
    {
        If ($EnabledLogging)
        {
            Write-Output "Script Completed on $env:COMPUTERNAME" | TimeStamp
            Write-Output "####################</Script>####################"
            Stop-Transcript
        }
    }

}   

# Invoke-CustomMenuGUI

<#######</Body>#######>
<#######</Script>#######>