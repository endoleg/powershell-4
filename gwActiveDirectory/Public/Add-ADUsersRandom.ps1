<#######<Script>#######>
<#######<Header>#######>
# Name: Add-ADUsersRandom
# Copyright: Gerry Williams (https://www.gerrywilliams.net)
# License: MIT License (https://opensource.org/licenses/mit)
# Script Modified from: n/a
<#######</Header>#######>
<#######<Body>#######>

Function Add-ADUsersRandom
{
    <#
.Synopsis
Creates a number of AD users retrieved from https://randomuser.me/api/
.Description
Creates a number of AD users retrieved from https://randomuser.me/api/ . Good for test lab user creation.
.Parameter Password
Madatory. Parameter stores a password as a string and then gets converted to a secure string in the Begin block.
.Parameter Fqdn
Madatory. Parameter that specifies the FQDN of the domain. Ex= "example.com".
.Parameter Ou
Madatory. Parameter that specifies the OU to create the users in. Ex = "OU=Users,DC=Domain,DC=com"
.Parameter Numberofusers
Madatory. Parameter that specifies the number of users to create.
.Parameter Logfile
Specifies A Logfile. Default is $PSScriptRoot\..\Logs\Scriptname.Log and is created for every script automatically.
NOTE: If you wish to delete the logfile, I have updated my scripts to where they should still run fine with no logging.
Note: If you don't like my scripts forcing logging, I wrote a post on how to fix this at https://www.gerrywilliams.net/2018/02/ps-forcing-preferences/
.Example
Add-ADUsersRandom -Password "#Tacos99!" -Fqdn "domain.net" -Ou "Ou=DomainUsers,Dc=domain,Dc=net" -NumberofUsers 3
Creates 3 users in the "domain users" OU for domain.net. They will be enabled with the password of "#Tacos99!" 
.Notes
2017-09-08: v1.0 Initial script 
.Functionality
Please see https://www.gerrywilliams.net/2017/09/running-ps-scripts-against-multiple-computers/ on how to run against multiple computers.   
  
#>

    [Cmdletbinding()]

    Param
    (
        [Parameter(Mandatory = $True)][String]$Password,
        [Parameter(Mandatory = $True)][String]$Fqdn,
        [Parameter(Mandatory = $True)][String]$Ou,
        [Parameter(Mandatory = $True)][Int]$Numberofusers, 
        [String]$Logfile = "$PSScriptRoot\..\Logs\Add-ADUsersRandom.Log"
    )

    Begin
    {
    
        <#######<Default Begin Block>#######>
        # Set logging globally if it has any value in the parameter so helper functions can access it.
        If ($($Logfile.Length) -gt 1)
        {
            $Global:EnabledLogging = $True
            New-Variable -Scope Global -Name Logfile -Value $Logfile
        }
        Else
        {
            $Global:EnabledLogging = $False
        }
        
        # If logging is enabled, create functions to start the log and stop the log.
        If ($Global:EnabledLogging)
        {
            Function Start-Log
            {
                <#
                .Synopsis
                Function to write the opening part of the logfile.
                .Description
                Function to write the opening part of the logfil.
                It creates the directory if it doesn't exists and then the log file automatically.
                It checks the size of the file if it already exists and clears it if it is over 10 MB.
                If it exists, it creates a header. This function is best placed in the "Begin" block of a script.
                .Notes
                NOTE: The function requires the Write-ToString function.
                2018-06-13: v1.1 Brought back from previous helper.psm1 files.
                2017-10-19: v1.0 Initial function
                #>
                [CmdletBinding()]
                Param
                (
                    [Parameter(Mandatory = $True)]
                    [String]$Logfile
                )
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
                # Start writing to logfile
                Start-Transcript -Path $Logfile -Append 
                Write-ToString "####################<Script>####################"
                Write-ToString "Script Started on $env:COMPUTERNAME"
            }
            Start-Log

            Function Stop-Log
            {
                <# 
                    .Synopsis
                    Function to write the closing part of the logfile.
                    .Description
                    Function to write the closing part of the logfile.
                    This function is best placed in the "End" block of a script.
                    .Notes
                    NOTE: The function requires the Write-ToString function.
                    2018-06-13: v1.1 Brought back from previous helper.psm1 files.
                    2017-10-19: v1.0 Initial function 
                    #>
                [CmdletBinding()]
                Param
                (
                    [Parameter(Mandatory = $True)]
                    [String]$Logfile
                )
                Write-ToString "Script Completed on $env:COMPUTERNAME"
                Write-ToString "####################</Script>####################"
                Stop-Transcript
            }
        }

        # Declare a Write-ToString function that doesn't depend if logging is enabled or not.
        Function Write-ToString
        {
            <# 
        .Synopsis
        Function that takes an input object, converts it to text, and sends it to the screen, a logfile, or both depending on if logging is enabled.
        .Description
        Function that takes an input object, converts it to text, and sends it to the screen, a logfile, or both depending on if logging is enabled.
        .Parameter InputObject
        This can be any PSObject that will be converted to string.
        .Parameter Color
        The color in which to display the string on the screen.
        Valid options are: Black, Blue, Cyan, DarkBlue, DarkCyan, DarkGray, DarkGreen, DarkMagenta, DarkRed, DarkYellow, Gray, Green, Magenta, 
        Red, White, and Yellow.
        .Example 
        Write-ToString "Hello Hello"
        If $Global:EnabledLogging is set to true, this will create an entry on the screen and the logfile at the same time. 
        If $Global:EnabledLogging is set to false, it will just show up on the screen in default text colors.
        .Example 
        Write-ToString "Hello Hello" -Color "Yellow"
        If $Global:EnabledLogging is set to true, this will create an entry on the screen colored yellow and to the logfile at the same time. 
        If $Global:EnabledLogging is set to false, it will just show up on the screen colored yellow.
        .Example 
        Write-ToString (cmd /c "ipconfig /all") -Color "Yellow"
        If $Global:EnabledLogging is set to true, this will create an entry on the screen colored yellow that shows the computer's IP information.
        The same copy will be in the logfile. 
        The whole point of converting to strings is this works best with tables and such that usually distort in logfiles.
        If $Global:EnabledLogging is set to false, it will just show up on the screen colored yellow.
        .Notes
        2018-06-13: v1.0 Initial function
        #>
            Param
            (
                [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 0)]
                [PSObject]$InputObject,
                
                [Parameter(Mandatory = $False, Position = 1)]
                [Validateset("Black", "Blue", "Cyan", "Darkblue", "Darkcyan", "Darkgray", "Darkgreen", "Darkmagenta", "Darkred", `
                        "Darkyellow", "Gray", "Green", "Magenta", "Red", "White", "Yellow")]
                [String]$Color,

                [Parameter(Mandatory = $False, Position = 2)]
                [String]$Logfile
            )
            
            $ConvertToString = Out-String -InputObject $InputObject -Width 100
            If ($Global:EnabledLogging)
            {
                # If logging is enabled and a color is defined, send to screen and logfile.
                If ($($Color.Length -gt 0))
                {
                    $previousForegroundColor = $Host.PrivateData.VerboseForegroundColor
                    $Host.PrivateData.VerboseForegroundColor = $Color
                    Write-Verbose -Message "$(Get-Date -Format "yyyy-MM-dd hh:mm:ss tt"): $ConvertToString"
                    Write-Output "$(Get-Date -Format "yyyy-MM-dd hh:mm:ss tt"): $ConvertToString" | Out-File -Encoding ASCII -FilePath $Logfile -Append
                    $Host.PrivateData.VerboseForegroundColor = $previousForegroundColor
                }
                # If not, still send to logfile, but use default colors.
                Else
                {
                    Write-Verbose -Message "$(Get-Date -Format "yyyy-MM-dd hh:mm:ss tt"): $ConvertToString"
                    Write-Output "$(Get-Date -Format "yyyy-MM-dd hh:mm:ss tt"): $ConvertToString" | Out-File -Encoding ASCII -FilePath $Logfile -Append
                }
            }
            # If logging isn't enabled, just send the string to the screen.
            Else
            {
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
        }
        <#######</Default Begin Block>#######>

        $Pass = $Password | ConvertTo-SecureString -AsPlainText -Force

        # Load the required module(s) 
        Try
        {
            Import-Module ActiveDirectory -ErrorAction Stop
        }
        Catch
        {
            Write-ToString "Module 'ActiveDirectory' was not found, stopping script"
            Exit 1
        }

    }
    
    Process
    {   
        For ($I = 0; $I -Lt $Numberofusers; $I++)
        {
            $Data = Invoke-Webrequest -Uri "https://randomuser.me/api/"
            $User = $Data.Content | Convertfrom-Json
            $Email = $User.Results.Email
            $FirstName = $User.Results.Name.First
            $LastName = $User.Results.Name.Last
            $Together = ($FirstName + "." + $LastName)  
            $Upn = $Together + "@" + $Fqdn
            New-Aduser -Name $Together `
                -Accountpassword $Pass `
                -Changepasswordatlogon $False `
                -Postalcode $User.Results.Location.PostCode `
                -Country "US" `
                -State $User.Results.Location.State `
                -City $User.Results.Location.City `
                -Streetaddress $User.Results.Location.Street `
                -Givenname $FirstName `
                -Surname $LastName `
                -Displayname "$FirstName $LastName" `
                -Emailaddress $Email `
                -Enabled $True `
                -Userprincipalname $Upn `
                -Path $Ou
            Write-ToString "User account created: $Together in $Ou"
        }
    }

    End
    {
        If ($EnabledLogging)
        {
            Stop-Log
        }
    }

}   

# Add-ADUsersRandom -Password "#Tacos99!" -Fqdn "domain.net" -Ou "Ou=DomainUsers,Dc=domain,Dc=net" -NumberofUsers 3

<#######</Body>#######>
<#######</Script>#######>