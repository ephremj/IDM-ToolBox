<#
.Synopsis
   Removes SRV records of a Domain Controller
.DESCRIPTION
   Removes SRV records of a Domain Controller from domain, forest and AD site zones.   
.EXAMPLE
   Remove-DomainControllerSRVRecords -dcName "dc-01.corp.contoso.local" -forestFQDN "contoso.local" -domainFQDN "corp.contoso.local"
.EXAMPLE
   Remove-DomainControllerSRVRecords -dcName "testdc01.testdomain.local" -forestFQDN "testdomain.local" -domainFQDN "testdomain.local"
.Notes
   Auther:  Ephrem Woldesemaite
   Version: 0.0.1
#>
function Remove-DomainControllerSRVRecords
{
    [CmdletBinding()]
    [Alias()]
    [OutputType([int])]
    Param
    (
        # dcName help description
        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0)]
        $dcName,

        # forestFQDN help description
        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0)]
        $forestFQDN,

        # domainFQDN help description
        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0)]
        $domainFQDN        
    )

    Begin
    {
        # Intialize forest and domain possible zones where the domain controller registger its SRV records
        $zonesToCheck = @()
        $zonesToCheck += "_gc._tcp." + $forestFQDN + "."
        $zonesToCheck += "_kerberos._tcp.dc._msdcs." + $domainFQDN + "."
        $zonesToCheck += "_kerberos._tcp." + $domainFQDN + "."
        $zonesToCheck += "_kerberos._udp." + $domainFQDN + "."
        $zonesToCheck += "_kpasswd._tcp." + $domainFQDN + "."
        $zonesToCheck += "_kpasswd._udp." + $domainFQDN + "."
        $zonesToCheck += "_ldap._tcp.dc._msdcs." + $domainFQDN + "."
        $zonesToCheck += "_ldap._tcp.DomainDnsZones." + $domainFQDN + "."
        $zonesToCheck += "_ldap._tcp.ForestDnsZones." + $forestFQDN + "."
        $zonesToCheck += "_ldap._tcp.gc._msdcs." + $forestFQDN + "."
        $zonesToCheck += "_ldap._tcp." + $domainFQDN + "."
        
    }
    Process
    {        
        try
        {
            # Add AD site based possible zones that the domain controller could have registred its SRV records 
            $sites = (Get-ADReplicationSite -filter * -Server $forestFQDN).Name            
            foreach ($site in $sites)
            {
                $zonesToCheck += "_kerberos._tcp." + $site + "._sites.dc._msdcs." + $domainFQDN + "."
                $zonesToCheck += "_kerberos._tcp." + $site + "._sites." + $domainFQDN + "."
                $zonesToCheck += "_ldap._tcp." + $site + "._sites.dc._msdcs." + $domainFQDN + "."
                $zonesToCheck += "_ldap._tcp." + $site + "._sites.DomainDnsZones." + $domainFQDN + "."
                $zonesToCheck += "_ldap._tcp." + $site + "._sites.ForestDnsZones." + $forestFQDN + "."
                $zonesToCheck += "_ldap._tcp." + $site + "._sites.gc._msdcs." + $forestFQDN + "."
                $zonesToCheck += "_ldap._tcp." + $site + "._sites." + $domainFQDN + "."
                $zonesToCheck += "_gc._tcp." + $site + "._sites." + $forestFQDN + "."
            }
        }
        catch 
        {
            Write-Host "No sites discover to remove AD Site based SRV records" -ForegroundColor Yellow
        }        

        try 
        {
            foreach ($zone in $zonesToCheck)
            {
                $srvRecordsinInZone = $null
                $srvRecordsinInZone = (Resolve-DnsName -Type SRV -Name $zone -Server $dc -ErrorAction SilentlyContinue).Name 
                if ($srvRecordsinInZone)
                {
                    if ($dcName -in $srvRecordsinInZone)
                    {
                        Write-Host "$dcName is in $zone" -ForegroundColor Green
                       # Remove-DnsServerResourceRecord  -Name $dc -ZoneName $zone -ComputerName $dc -RRType "SRV"
                    }
                }
            }  
        }
        catch 
        {
            Write-Host "Remove has failed " $_
        }
    } 
    End
    {
    }
}
