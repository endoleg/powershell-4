<#######<Script>#######>
<#######<Header>#######>
# Name: Set-OutlookAutodiscover
# Copyright: Gerry Williams (https://automationadmin.com)
# License: MIT License (https://opensource.org/licenses/mit)
# Script Modified from: n/a
<#######</Header>#######>
<#######<Body>#######>
Function Set-OutlookAutodiscover
{
    <#
    .Synopsis
    Configures autodiscover keys for MS Outlook so adding accounts takes 5 seconds instead of 5 minutes.
    .Description
    Configures autodiscover keys for MS Outlook so adding accounts takes 5 seconds instead of 5 minutes.
    .Parameter Logfile
    Specifies A Logfile. Default is $PSScriptRoot\..\Logs\Scriptname.Log and is created for every script automatically.
    .Example
    Set-OutlookAutodiscover
    #>
    
    [Cmdletbinding()]
    
    Param
    (
    )

    Begin
    {       
        ####################<Default Begin Block>####################
        # Force verbose because Write-Output doesn't look well in transcript files
        $VerbosePreference = "Continue"
        
        [String]$Logfile = $PSScriptRoot + '\PSLogs\' + (Get-Date -Format "yyyy-MM-dd") +
        "-" + $MyInvocation.MyCommand.Name + ".log"
        
        Function Write-Log
        {
            <#
            .Synopsis
            This writes objects to the logfile and to the screen with optional coloring.
            .Parameter InputObject
            This can be text or an object. The function will convert it to a string and verbose it out.
            Since the main function forces verbose output, everything passed here will be displayed on the screen and to the logfile.
            .Parameter Color
            Optional coloring of the input object.
            .Example
            Write-Log "hello" -Color "yellow"
            Will write the string "VERBOSE: YYYY-MM-DD HH: Hello" to the screen and the logfile.
            NOTE that Stop-Log will then remove the string 'VERBOSE :' from the logfile for simplicity.
            .Example
            Write-Log (cmd /c "ipconfig /all")
            Will write the string "VERBOSE: YYYY-MM-DD HH: ****ipconfig output***" to the screen and the logfile.
            NOTE that Stop-Log will then remove the string 'VERBOSE :' from the logfile for simplicity.
            .Notes
            2018-06-24: Initial script
            #>
            
            Param
            (
                [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 0)]
                [PSObject]$InputObject,
                
                # I usually set this to = "Green" since I use a black and green theme console
                [Parameter(Mandatory = $False, Position = 1)]
                [Validateset("Black", "Blue", "Cyan", "Darkblue", "Darkcyan", "Darkgray", "Darkgreen", "Darkmagenta", "Darkred", `
                        "Darkyellow", "Gray", "Green", "Magenta", "Red", "White", "Yellow")]
                [String]$Color = "Green"
            )
            
            $ConvertToString = Out-String -InputObject $InputObject -Width 100
            
            If ($($Color.Length -gt 0))
            {
                $previousForegroundColor = $Host.PrivateData.VerboseForegroundColor
                $Host.PrivateData.VerboseForegroundColor = $Color
                Write-Verbose -Message "$(Get-Date -Format "yyyy-MM-dd hh:mm:ss tt"): $ConvertToString"
                $Host.PrivateData.VerboseForegroundColor = $previousForegroundColor
            }
            Else
            {
                Write-Verbose -Message "$(Get-Date -Format "yyyy-MM-dd hh:mm:ss tt"): $ConvertToString"
            }
            
        }

        Function Start-Log
        {
            <#
            .Synopsis
            Creates the log file and starts transcribing the session.
            .Notes
            2018-06-24: Initial script
            #>
            
            # Create transcript file if it doesn't exist
            If (!(Test-Path $Logfile))
            {
                New-Item -Itemtype File -Path $Logfile -Force | Out-Null
            }
        
            # Clear it if it is over 10 MB
            [Double]$Sizemax = 10485760
            $Size = (Get-Childitem $Logfile | Measure-Object -Property Length -Sum) 
            If ($($Size.Sum -ge $SizeMax))
            {
                Get-Childitem $Logfile | Clear-Content
                Write-Verbose "Logfile has been cleared due to size"
            }
            Else
            {
                Write-Verbose "Logfile was less than 10 MB"   
            }
            Start-Transcript -Path $Logfile -Append 
            Write-Log "####################<Function>####################"
            Write-Log "Function started on $env:COMPUTERNAME"

        }
        
        Function Stop-Log
        {
            <#
            .Synopsis
            Stops transcribing the session and cleans the transcript file by removing the fluff.
            .Notes
            2018-06-24: Initial script
            #>
            
            Write-Log "Function completed on $env:COMPUTERNAME"
            Write-Log "####################</Function>####################"
            Stop-Transcript
       
            # Now we will clean up the transcript file as it contains filler info that needs to be removed...
            $Transcript = Get-Content $Logfile -raw

            # Create a tempfile
            $TempFile = $PSScriptRoot + "\PSLogs\temp.txt"
            New-Item -Path $TempFile -ItemType File | Out-Null
			
            # Get all the matches for PS Headers and dump to a file
            $Transcript | 
                Select-String '(?smi)\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*([\S\s]*?)\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*' -AllMatches | 
                ForEach-Object {$_.Matches} | 
                ForEach-Object {$_.Value} | 
                Out-File -FilePath $TempFile -Append

            # Compare the two and put the differences in a third file
            $m1 = Get-Content -Path $Logfile
            $m2 = Get-Content -Path $TempFile
            $all = Compare-Object -ReferenceObject $m1 -DifferenceObject $m2 | Where-Object -Property Sideindicator -eq '<='
            $Array = [System.Collections.Generic.List[PSObject]]@()
            foreach ($a in $all)
            {
                [void]$Array.Add($($a.InputObject))
            }
            $Array = $Array -replace 'VERBOSE: ', ''

            Remove-Item -Path $Logfile -Force
            Remove-Item -Path $TempFile -Force
            # Finally, put the information we care about in the original file and discard the rest.
            $Array | Out-File $Logfile -Append -Encoding ASCII
            
        }
        
        Start-Log

        Function Set-Console
        {
            <# 
        .Synopsis
        Function to set console colors just for the session.
        .Description
        Function to set console colors just for the session.
        This function sets background to black and foreground to green.
        Verbose is DarkCyan which is what I use often with logging in scripts.
        I mainly did this because darkgreen does not look too good on blue (Powershell defaults).
        .Notes
        2017-10-19: v1.0 Initial script 
        #>
        
            Function Test-IsAdmin
            {
                <#
                .Synopsis
                Determines whether or not the user is a member of the local Administrators security group.
                .Outputs
                System.Bool
                #>

                [CmdletBinding()]
    
                $Identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
                $Principal = new-object System.Security.Principal.WindowsPrincipal(${Identity})
                $IsAdmin = $Principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
                Write-Output -InputObject $IsAdmin
            }

            $console = $host.UI.RawUI
            If (Test-IsAdmin)
            {
                $console.WindowTitle = "Administrator: Powershell"
            }
            Else
            {
                $console.WindowTitle = "Powershell"
            }
            $Background = "Black"
            $Foreground = "Green"
            $Messages = "DarkCyan"
            $Host.UI.RawUI.BackgroundColor = $Background
            $Host.UI.RawUI.ForegroundColor = $Foreground
            $Host.PrivateData.ErrorForegroundColor = $Messages
            $Host.PrivateData.ErrorBackgroundColor = $Background
            $Host.PrivateData.WarningForegroundColor = $Messages
            $Host.PrivateData.WarningBackgroundColor = $Background
            $Host.PrivateData.DebugForegroundColor = $Messages
            $Host.PrivateData.DebugBackgroundColor = $Background
            $Host.PrivateData.VerboseForegroundColor = $Messages
            $Host.PrivateData.VerboseBackgroundColor = $Background
            $Host.PrivateData.ProgressForegroundColor = $Messages
            $Host.PrivateData.ProgressBackgroundColor = $Background
            Clear-Host
        }
        Set-Console

        ####################</Default Begin Block>####################

        
        # Load the required module(s) 
        Try
        {
            Import-Module "$Psscriptroot\..\Private\helpers.psm1" -ErrorAction Stop
        }
        Catch
        {
            Write-Output "Module 'Helpers' was not found, stopping script"
            Exit 1
        }
        
        Function Set-2013Old
        {
            $registryPath = "HKCU:\SOFTWARE\Microsoft\Office\15.0\Outlook\AutoDiscover"
            $Name = "ExcludeHttpsRootDomain"
            $value = "1"
            IF (!(Test-Path $registryPath))
            {
                New-Item -Path $registryPath -Force | Out-Null
            }
            New-ItemProperty -Path $registryPath -Name $name -Value $value -PropertyType DWORD -Force | Out-Null

            $registryPath = "HKCU:\SOFTWARE\Microsoft\Office\15.0\Outlook\AutoDiscover"
            $Name = "ExcludeHttpsAutoDiscoverDomain"
            $value = "1"
            IF (!(Test-Path $registryPath))
            {
                New-Item -Path $registryPath -Force | Out-Null
            }
            New-ItemProperty -Path $registryPath -Name $name -Value $value -PropertyType DWORD -Force | Out-Null

            # Allow adding up to 14 accounts, can adjust to 99 I believe
            $registryPath = "HKCU:\SOFTWARE\Microsoft\Exchange"
            $Name = "MaxNumExchange"
            $value = "19"
            IF (!(Test-Path $registryPath))
            {
                New-Item -Path $registryPath -Force | Out-Null
            }
            New-ItemProperty -Path $registryPath -Name $name -Value $value -PropertyType DWORD -Force | Out-Null

            $registryPath = "HKCU:\Software\Policies\Microsoft\Exchange"
            $Name = "MaxNumExchange"
            $value = "19"
            IF (!(Test-Path $registryPath))
            {
                New-Item -Path $registryPath -Force | Out-Null
            }
            New-ItemProperty -Path $registryPath -Name $name -Value $value -PropertyType DWORD -Force | Out-Null
        }

        Function Set-2016Old
        {
            $registryPath = "HKCU:\SOFTWARE\Microsoft\Office\16.0\Outlook\AutoDiscover"
            $Name = "ExcludeHttpsRootDomain"
            $value = "1"
            IF (!(Test-Path $registryPath))
            {
                New-Item -Path $registryPath -Force | Out-Null
            }
            New-ItemProperty -Path $registryPath -Name $name -Value $value -PropertyType DWORD -Force | Out-Null


            $registryPath = "HKCU:\SOFTWARE\Microsoft\Office\16.0\Outlook\AutoDiscover"
            $Name = "ExcludeHttpsAutoDiscoverDomain"
            $value = "1"
            IF (!(Test-Path $registryPath))
            {
                New-Item -Path $registryPath -Force | Out-Null
            }
            New-ItemProperty -Path $registryPath -Name $name -Value $value -PropertyType DWORD -Force | Out-Null

            # Allow adding up to 14 accounts, can adjust to 99 I believe
            $registryPath = "HKCU:\SOFTWARE\Microsoft\Exchange"
            $Name = "MaxNumExchange"
            $value = "19"
            IF (!(Test-Path $registryPath))
            {
                New-Item -Path $registryPath -Force | Out-Null
            }
            New-ItemProperty -Path $registryPath -Name $name -Value $value -PropertyType DWORD -Force | Out-Null

            $registryPath = "HKCU:\Software\Policies\Microsoft\Exchange"
            $Name = "MaxNumExchange"
            $value = "19"
            IF (!(Test-Path $registryPath))
            {
                New-Item -Path $registryPath -Force | Out-Null
            }
            New-ItemProperty -Path $registryPath -Name $name -Value $value -PropertyType DWORD -Force | Out-Null
        }

        Function Set-2013
        {
            SetReg -Path "HKCU:\SOFTWARE\Microsoft\Office\15.0\Outlook\AutoDiscover" -Name "ExcludeHttpsRootDomain" -Value "1"
            SetReg -Path "HKCU:\SOFTWARE\Microsoft\Office\15.0\Outlook\AutoDiscover" -Name "ExcludeHttpsAutoDiscoverDomain" -Value "1"
            # Allow adding up to 14 accounts, can adjust to 99 I believe
            SetReg -Path "HKCU:\SOFTWARE\Microsoft\Exchange" -Name "MaxNumExchange" -Value "14"
            SetReg -Path "HKCU:\Software\Policies\Microsoft\Exchange" -Name "MaxNumExchange" -Value "14"
        }

        Function Set-2016
        {
            SetReg -Path "HKCU:\SOFTWARE\Microsoft\Office\16.0\Outlook\AutoDiscover" -Name "ExcludeHttpsRootDomain" -Value "1"
            SetReg -Path "HKCU:\SOFTWARE\Microsoft\Office\16.0\Outlook\AutoDiscover" -Name "ExcludeHttpsAutoDiscoverDomain" -Value "1"
            # Allow adding up to 14 accounts, can adjust to 99 I believe
            SetReg -Path "HKCU:\SOFTWARE\Microsoft\Exchange" -Name "MaxNumExchange" -Value "14"
            SetReg -Path "HKCU:\Software\Policies\Microsoft\Exchange" -Name "MaxNumExchange" -Value "14"
        }

    }
    
    Process
    {
        Write-Log "Getting the version of Operating System"
        $WMI = Get-WmiObject -Class win32_operatingsystem | Select-Object -Property Version
        $String = $WMI.Version.tostring()
        $OS = $String.Substring(0, 4)

        Write-Log "Getting the version of Office"
        $Version = 0
        $Reg = [Microsoft.Win32.Registrykey]::Openremotebasekey('Localmachine', $Env:Computername)
        $Reg.Opensubkey('Software\Microsoft\Office').Getsubkeynames() |Foreach-Object {
            If ($_ -Match '(\d+)\.') 
            {
                If ([Int]$Matches[1] -Gt $Version) 
                {
                    $Version = $Matches[1] 
                }
            }   
        }
        
        If ($OS -match "10.0" -and $Version -match "15")
        {
            Write-Log "Creating settings for Windows 10 and Office 2013"
            Set-2013
        }

        ElseIf ($OS -match "10.0" -and $Version -match "16")
        {
            Write-Log "Creating settings for Windows 10 and Office 2016"
            Set-2016
        }

        ElseIf ($OS -match "6.3." -and $Version -match "15")
        {
            Write-Log "Creating settings for Windows 8.1 and Office 2013"
            Set-2013Old
        }

        ElseIf ($OS -match "6.3." -and $Version -match "16")
        {
            Write-Log "Creating settings for Windows 8.1 and Office 2016"
            Set-2016Old
        }

        ElseIf ($OS -match "6.1." -and $Version -match "15")
        {
            Write-Log "Creating settings for Windows 7 and Office 2013"
            Set-2013Old
        }
    
        ElseIf ($OS -match "6.1." -and $Version -match "16")
        {
            Write-Log "Creating settings for Windows 7 and Office 2016"
            Set-2016Old
        }

        Else
        {
            Write-Log "Either the OS is unsupported or Office is not installed/ unsupported."
        }
    
        Write-Log "Sending OWA Link to Desktop"
        # Send OWA Link to desktop
        $TargetFile = "https://your.owa.com"
        $ShortcutFile = "$env:userprofile\Desktop\OWA.url"
        $WScriptShell = New-Object -ComObject WScript.Shell
        $Shortcut = $WScriptShell.CreateShortcut($ShortcutFile)
        $Shortcut.TargetPath = $TargetFile
        $Shortcut.Save()

        # Clear Credential Manager manually (pick and choose)
        rundll32.exe keymgr.dll, KRShowKeyMgr

        <# 
        To Clear Completely (untested but should work):
        $creds = cmd /c "cmdkey /list"
        foreach ($c in $creds)
        {
            if ($c -like "*Target:*")
            {
                cmdkey /del:($c -replace " ", "" -replace "Target:", "")
            }
        }
        #> 
    }

    End
    {
        Stop-log
        
    }

}

<#######</Body>#######>
<#######</Script>#######>