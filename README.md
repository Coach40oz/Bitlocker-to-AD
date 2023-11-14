BitLocker Key to Active Directory
This PowerShell script retrieves the BitLocker recovery key for a specified drive and stores it in Active Directory.

Parameters
driveLetter: The drive letter for which to retrieve the BitLocker recovery key. Default is "C:".
domain: The domain name of your Active Directory. Replace "yourdomain" with your actual domain name.
tld: The top-level domain of your Active Directory. Default is "com".
overwriteExistingKey: A switch parameter. If used, the script will overwrite an existing BitLocker recovery key in Active Directory.
Checks
The script performs several checks:

It checks if the script is run with Administrator privileges. If not, it throws an error.
It checks if the specified drive letter exists. If not, it throws an error.
It checks if BitLocker is enabled on the specified drive. If not, it throws an error.
It checks if the domain is reachable. If not, it throws an error.
Retrieving and Storing the Key
The script retrieves the BitLocker recovery key for the specified drive using the Get-BitLockerVolume cmdlet. If no key is found, it throws an error.

It constructs the LDAP path to the computer object in Active Directory and attempts to connect to it. If it fails to connect, it throws an error.

If the -overwriteExistingKey switch is used or no existing key is found in Active Directory, the script stores the retrieved BitLocker key in Active Directory. If a key is already present and the overwrite switch is not used, it informs the user without overwriting.

Error Handling
The script includes a try-catch block for error handling. If any errors occur, it catches and displays the error message.
