#bitlocker_key_to_ad.ps1

param (
    [string]$driveLetter = "C:",
    [string]$domain = "yourdomain",
    [string]$tld = "com",
    [switch]$overwriteExistingKey
)

try {
    # Check if the user has the necessary permissions
    if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        throw "You must run this script as an Administrator."
    }

    # Check if the drive letter exists
    if (-not (Test-Path $driveLetter)) {
        throw "Drive $driveLetter does not exist."
    }

    # Check if BitLocker is enabled on the drive
    if ((Get-BitLockerVolume -MountPoint $driveLetter).EncryptionMethod -eq 'None') {
        throw "BitLocker is not enabled on drive $driveLetter."
    }

    # Check if the domain is reachable
    if (-not (Resolve-DnsName -Name $domain -Type SOA -ErrorAction SilentlyContinue)) {
        throw "Domain $domain is not reachable."
    }

    # Retrieve the BitLocker recovery key
    $recoveryKey = (Get-BitLockerVolume -MountPoint $driveLetter).KeyProtector | Where-Object {$_.KeyProtectorType -eq 'RecoveryPassword'} | Select-Object -ExpandProperty RecoveryPassword

    if ($null -eq $recoveryKey) {
        throw "Failed to retrieve BitLocker recovery key for drive $driveLetter"
    }

    # Store the recovery key in Active Directory
    $computerName = $env:COMPUTERNAME
    $adPath = "LDAP://CN=$computerName,CN=Computers,DC=$domain,DC=$tld"
    $adObject = [ADSI]$adPath

    # Check if we can connect to the AD object
    if ($null -eq $adObject) {
        throw "Failed to connect to the AD object at $adPath"
    }

    # Check if we should overwrite the existing key
    if ($overwriteExistingKey -or $null -eq $adObject.msFVE-RecoveryInformation) {
        $adObject.msFVE-RecoveryInformation = $recoveryKey
        $adObject.SetInfo()
        Write-Host "Successfully stored the BitLocker recovery key in Active Directory"
    } else {
        Write-Host "A BitLocker recovery key is already stored in Active Directory for this computer. Use the -overwriteExistingKey switch to overwrite it."
    }
} catch {
    Write-Error $_.Exception.Message
}
