param(
    [Parameter(Mandatory=$true)]
    [string]$AppStoreConnectKeyPath,

    [Parameter(Mandatory=$true)]
    [string]$ProvisioningProfilePath,

    [Parameter(Mandatory=$true)]
    [string]$DistributionCertificateP12Path,

    [Parameter(Mandatory=$true)]
    [string]$CertificatePassword,

    [Parameter(Mandatory=$true)]
    [string]$AppleTeamId,

    [Parameter(Mandatory=$true)]
    [string]$ProvisioningProfileName,

    [Parameter(Mandatory=$true)]
    [string]$AppStoreConnectIssuerId,

    [Parameter(Mandatory=$true)]
    [string]$KeychainPassword
)

$ErrorActionPreference = "Stop"

foreach ($path in @($AppStoreConnectKeyPath, $ProvisioningProfilePath, $DistributionCertificateP12Path)) {
    if (-not (Test-Path -LiteralPath $path)) {
        throw "Missing file: $path"
    }
}

$keyFileName = Split-Path -Leaf $AppStoreConnectKeyPath
if ($keyFileName -notmatch "AuthKey_(.+)\.p8$") {
    throw "App Store Connect key file must be named like AuthKey_KEYID.p8"
}
$keyId = $Matches[1]

$secrets = [ordered]@{
    APPLE_TEAM_ID = $AppleTeamId
    IOS_PROVISIONING_PROFILE_NAME = $ProvisioningProfileName
    IOS_PROVISIONING_PROFILE_BASE64 = [Convert]::ToBase64String([IO.File]::ReadAllBytes((Resolve-Path -LiteralPath $ProvisioningProfilePath)))
    IOS_DISTRIBUTION_CERTIFICATE_BASE64 = [Convert]::ToBase64String([IO.File]::ReadAllBytes((Resolve-Path -LiteralPath $DistributionCertificateP12Path)))
    IOS_DISTRIBUTION_CERTIFICATE_PASSWORD = $CertificatePassword
    KEYCHAIN_PASSWORD = $KeychainPassword
    APP_STORE_CONNECT_API_KEY_ID = $keyId
    APP_STORE_CONNECT_API_ISSUER_ID = $AppStoreConnectIssuerId
    APP_STORE_CONNECT_API_PRIVATE_KEY = Get-Content -LiteralPath $AppStoreConnectKeyPath -Raw
}

Write-Host "Set these GitHub Actions secrets for lanray07/NextSelf-AI:"
foreach ($name in $secrets.Keys) {
    $value = $secrets[$name]
    $length = if ($null -eq $value) { 0 } else { $value.Length }
    Write-Host "- $name ($length chars)"
}

Write-Host ""
Write-Host "If GitHub CLI is authenticated, run:"
foreach ($name in $secrets.Keys) {
    Write-Host "  `$env:NEXTSELF_SECRET = '<value omitted>'; gh secret set $name --repo lanray07/NextSelf-AI --body `$env:NEXTSELF_SECRET"
}

Write-Host ""
Write-Host "This script intentionally does not print secret values."
