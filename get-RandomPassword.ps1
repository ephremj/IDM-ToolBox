<#
.Synopsis
   Generate a random password
.DESCRIPTION
   Generate a random password. If length not specified, it will changeret 50 characters long.
.EXAMPLE
   get-RandomPassword
.EXAMPLE
   get-RandomPassword -length 10
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
