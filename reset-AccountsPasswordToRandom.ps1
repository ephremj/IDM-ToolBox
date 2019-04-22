<#
.Synopsis
   Generate a random password
.DESCRIPTION
   Generate a random password. If length not specified, it will changeret 50 characters long.
.EXAMPLE
   get-RandomPassword
.EXAMPLE
   get-RandomPassword -length 10
.Notes
   Auther:  Ephrem Woldesemaite
   Version: 0.0.1
#>
function get-RandomPassword
{
    [CmdletBinding()]
    [Alias()]
    [OutputType([int])]
    Param
    (
        # length help description
        [int]$length = 50 #set defult password lenght to 50
    )

    Begin
    {
        $punc = 46..46
        $digits = 48..57
        $letters = 65..90 + 97..122
    }
    Process
    {
        $password = get-random -count $length -input ($punc + $digits + $letters) | % -begin { $aa = $null } -process { $aa += [char]$_ }  -end { $aa }
    }
    End
    {
        return $password
    }
}

<#
.Synopsis
   Reset account's password  to a radmon password
.DESCRIPTION
   Reset account's password  to a radmon password.
.EXAMPLE
   reset-AccountsPasswordToRandom -userName alias -domain contoso.local
.EXAMPLE
   reset-AccountsPasswordToRandom -userName alias
.Notes
   Auther:  Ephrem Woldesemaite
   Version: 0.0.1
#>
function reset-AccountsPasswordToRandom
{
    [CmdletBinding()]
    [Alias()]
    [OutputType([int])]
    Param
    (
        # userName help description
        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0)]
        [string]$userName,

        # Param2 help description
        [string]$domain = $null
    )

    Begin
    {
        $pwdTxt = get-RandomPassword
    }
    Process
    {
        try
        {
            if ($null -eq $domain)
            {
                Set-ADAccountPassword -Identity $userName -Reset -NewPassword (ConvertTo-SecureString -AsPlainText $pwdTxt -Force) 
            }
            else
            {
                Set-ADAccountPassword -Identity $userName -Reset -NewPassword (ConvertTo-SecureString -AsPlainText $pwdTxt -Force) -Server $domain 
            }
        }
        catch
        {
            Write-Host $_.
        }    
    }
    End
    {
    }
}
