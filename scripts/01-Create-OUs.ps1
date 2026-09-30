<#
.SYNOPSIS
    Erstellt die OU-Struktur und die globalen Abteilungsgruppen für das KMU-Lab.
.NOTES
    Ausführen auf DC01 in der PowerShell als Administrator.
#>

Import-Module ActiveDirectory
$ErrorActionPreference = "Stop"

$domainDN   = (Get-ADDomain).DistinguishedName
$baseOUName = "KMU_Objects"

Write-Host "==> Starte Erstellung der OU-Struktur in $domainDN..." -ForegroundColor Cyan

# 1. Haupt-OU
if (-not (Get-ADOrganizationalUnit -Filter "Name -eq '$baseOUName'" -SearchBase $domainDN -SearchScope OneLevel -ErrorAction SilentlyContinue)) {
    New-ADOrganizationalUnit -Name $baseOUName -Path $domainDN -ProtectedFromAccidentalDeletion $true
    Write-Host "[+] Haupt-OU '$baseOUName' erstellt." -ForegroundColor Green
}

$kmuOU = "OU=$baseOUName,$domainDN"

# 2. Unter-OUs
$subOUs = @("Users", "Devices", "Admin_Accounts")
foreach ($ou in $subOUs) {
    if (-not (Get-ADOrganizationalUnit -Filter "Name -eq '$ou'" -SearchBase $kmuOU -SearchScope OneLevel -ErrorAction SilentlyContinue)) {
        New-ADOrganizationalUnit -Name $ou -Path $kmuOU -ProtectedFromAccidentalDeletion $true
        Write-Host "[+] Unter-OU '$ou' unter '$baseOUName' erstellt." -ForegroundColor Green
    }
}

# 3. Abteilungs-OUs
$usersOU = "OU=Users,$kmuOU"
$deptOUs = @("Execs", "IT", "HR", "Finance", "Sales", "Contractors")

foreach ($dept in $deptOUs) {
    if (-not (Get-ADOrganizationalUnit -Filter "Name -eq '$dept'" -SearchBase $usersOU -SearchScope OneLevel -ErrorAction SilentlyContinue)) {
        New-ADOrganizationalUnit -Name $dept -Path $usersOU -ProtectedFromAccidentalDeletion $true
        Write-Host "  [+] Abteilungs-OU '$dept' unter 'Users' erstellt." -ForegroundColor Gray
    }
}

# 4. Globale Gruppen (G-Teil von AGDLP)
Write-Host "==> Erstelle globale Gruppen für Abteilungen..." -ForegroundColor Cyan

foreach ($dept in $deptOUs) {
    $groupName = "gg_$($dept)_Users"
    $deptPath  = "OU=$dept,$usersOU"

    if (-not (Get-ADGroup -Filter "Name -eq '$groupName'" -ErrorAction SilentlyContinue)) {
        New-ADGroup -Name $groupName `
                    -SamAccountName $groupName `
                    -GroupScope Global `
                    -GroupCategory Security `
                    -Path $deptPath `
                    -Description "Globale Gruppe für alle Mitarbeiter der Abteilung $dept"
        Write-Host "[+] Globale Gruppe '$groupName' in '$dept' erstellt." -ForegroundColor Green
    }
}

Write-Host "==> OU-Struktur und Gruppen wurden erfolgreich eingerichtet!" -ForegroundColor Yellow