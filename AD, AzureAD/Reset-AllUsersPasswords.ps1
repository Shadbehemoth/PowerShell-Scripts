# Import the necessary modules
Import-Module MSOnline

# Connect to the O365 service
$O365Credential = Get-Credential
Connect-MsolService -Credential $O365Credential

# Get all licensed users in the tenant
$LicensedUsers = Get-MsolUser -All | Where-Object { $_.IsLicensed -eq $true }

# Initialize an array to store the userprincipalnames and passwords
$ResetPasswordResults = @()

# Loop through each licensed user and reset their password
foreach ($User in $LicensedUsers) {
    $UserPrincipalName = $User.UserPrincipalName

    # Generate a random password
    $NewPassword = [System.Web.Security.Membership]::GeneratePassword(12, 3)

    # Reset the user's password and force them to change it on next login
    Set-MsolUserPassword -UserPrincipalName $UserPrincipalName -NewPassword $NewPassword -ForceChangePassword $true

    # Add the userprincipalname and new password to the array
    $ResetPasswordResults += [PSCustomObject]@{
        UserPrincipalName = $UserPrincipalName
        Password = $NewPassword
    }
}

# Export the results to a CSV file
$ResetPasswordResults | Export-Csv -Path "C:\ResetPasswordResults.csv" -NoTypeInformation