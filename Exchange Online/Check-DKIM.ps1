# Import the installed module
Import-Module ExchangeOnlineManagement -Force

# Connect to Exchange Online
Connect-ExchangeOnline -ErrorAction SilentlyContinue

# Find all domains in the tenant
$domains = Get-AcceptedDomain -ErrorAction SilentlyContinue | Where-Object {$_.DomainName -notlike "*.onmicrosoft.com"} | Select-Object -ExpandProperty DomainName

foreach ($domain in $domains) {
    try {
        # Check if DKIM is enabled
        if ((Get-DkimSigningConfig -Identity $domain -ErrorAction Stop).Enabled -eq $true) {
            
            Write-Host "DKIM is enabled for $domain"

            # Get the subdomains for the DKIM selectors
            $selector1 = "selector1._domainkey.$domain"
            $selector2 = "selector2._domainkey.$domain"

            # Do an nslookup on the txt records
            $lookupSelector1 = (Resolve-DnsName -Type TXT -Name $selector1 -ErrorAction SilentlyContinue | Select-Object Strings | foreach {$_.Strings}) -join ''
            $lookupSelector2 = (Resolve-DnsName -Type TXT -Name $selector2 -ErrorAction SilentlyContinue | Select-Object Strings | foreach {$_.Strings}) -join ''

            # Get the DKIM signing config
            $dkimConfigSelector1 = Get-DkimSigningConfig -Identity $domain -ErrorAction SilentlyContinue | foreach {$_.Selector1publickey}
            $dkimConfigSelector2 = Get-DkimSigningConfig -Identity $domain -ErrorAction SilentlyContinue | foreach {$_.Selector2publickey}

            # Compare the values with the ones in Exchange Online
            if ($lookupSelector1 -eq $dkimConfigSelector1) {
                Write-Host "Correct for $domain"
            } else {
                Write-Host "Incorrect for $domain"
            }

        } else {
            Write-Host "DKIM is NOT enabled for $domain"
        }
    }
    catch {
        # Handle the error
        Write-Host "An error occurred: $_" -foregroundcolor red # Uncomment this line if you want to print the errors
    }
}

# Disconnect from the Exchange Online session
Disconnect-ExchangeOnline -ErrorAction SilentlyContinue

$domains = Get-AcceptedDomain -ErrorAction SilentlyContinue | Select-Object -ExpandProperty DomainName
