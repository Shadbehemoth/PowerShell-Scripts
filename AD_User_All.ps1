Import-Module ActiveDirectory
Get-ADUser -Filter * -Properties * | 
Select-Object AccountExpirationDate,AccountLockoutTime,AccountNotDelegated,AllowReversiblePasswordEncryption,`
BadLogonCount,CannotChangePassword,CanonicalName,Certificates,ChangePasswordAtLogon,City,CN,Company,Country,`
Created,Deleted,Department,Description,DisplayName,DistinguishedName,Division,DoesNotRequirePreAuth,EmailAddress,`
EmployeeID,EmployeeNumber,Enabled,Fax,GivenName,HomeDirectory,HomedirRequired,HomeDrive,HomePage,HomePhone,Initials,`
LastBadPasswordAttempt,LastKnownParent,LastLogonDate,LockedOut,LogonWorkstations,Manager,MemberOf,MNSLogonAccount,`
MobilePhone,Modified,Name,ObjectCategory,ObjectClass,ObjectGUID,Office,OfficePhone,Organization,OtherName,PasswordExpired,`
PasswordLastSet,PasswordNeverExpires,PasswordNotRequired,POBox,PostalCode,PrimaryGroup,ProfilePath,`
ProtectedFromAccidentalDeletion,SamAccountName,ScriptPath,ServicePrincipalNames,SID,SIDHistory,SmartcardLogonRequired,`
State,StreetAddress,Surname,Title,TrustedForDelegation,TrustedToAuthForDelegation,UseDESKeyOnly,UserPrincipalName | 
export-csv c:\ADusers.csv
