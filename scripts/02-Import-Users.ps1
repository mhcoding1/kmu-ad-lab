<#
.SYNOPSIS
    Importiert Benutzer aus kmu_users.csv in die OUs, setzt Passwörter,
    Ablaufdaten für Contractors und fügt sie in Abteilungsgruppen ein.
.NOTES
    Voraussetzung: 01-Create-OUs.ps1 wurde vorher ausgeführt.
    Dateikodierung: UTF-8 mit BOM speichern.
#>

Import-Module ActiveDirectory
$ErrorActionPreference = "Continue"

# Pfade & Einstellungen
$csvPath    = "C:\LabSetup\kmu_users.csv"
$domainInfo = Get-ADDomain
$domain     = $domainInfo.DNSRoot
$domainDN   = $domainInfo.DistinguishedName
$baseOU     = "OU=Users,OU=KMU_Objects,$domainDN"   

# Standard-Initialpasswort (nur Lab!)
$defaultPassword = ConvertTo-SecureString "Start1234!2026" -AsPlainText -Force

function ConvertTo-SamPart {
    param([string]$Text)
    $t = $Text.Trim().ToLower()
    $t = $t -replace 'ä','ae' -replace 'ö','oe' -replace 'ü','ue' -replace 'ß','ss'
    # Akzente entfernen (é -> e) und alles außer a-z/0-9 verwerfen
    $t = $t.Normalize([Text.NormalizationForm]::FormD) -replace '\p{Mn}',''
    return ($t -replace '[^a-z0-9]','')
}

if (-not (Test-Path $csvPath)) {
    Write-Error "CSV-Datei unter '$csvPath' nicht gefunden! Bitte Pfad prüfen."
    return
}

Write-Host "==> Starte Import der Testbenutzer aus $csvPath..." -ForegroundColor Cyan
$users = Import-Csv -Path $csvPath -Encoding UTF8   # ggf. -Delimiter ';'

if (-not $users) {
    Write-Error "CSV enthält keine Datensätze."
    return
}

# Spaltencheck
$required = 'Firstname','Lastname','Department','JobTitle','IsContractor','AccountExpiration'
$columns  = $users[0].PSObject.Properties.Name
$missing  = $required | Where-Object { $_ -notin $columns }
if ($missing) {
    Write-Error "Fehlende Spalten in der CSV: $($missing -join ', ')"
    return
}

foreach ($user in $users) {
    $displayName = "$($user.Firstname) $($user.Lastname)".Trim()

    # 1. SamAccountName erzeugen
    $first = ConvertTo-SamPart $user.Firstname
    $last  = ConvertTo-SamPart $user.Lastname
    if (-not $first -or -not $last) {
        Write-Warning "Vor- oder Nachname leer/ungültig ($displayName). Überspringe."
        continue
    }
    $baseSam = ($first.Substring(0,1) + $last)
    if ($baseSam.Length -gt 20) { $baseSam = $baseSam.Substring(0,20) }

    # 2. Ziel-OU prüfen
    $targetOU = "OU=$($user.Department),$baseOU"
    if (-not (Get-ADOrganizationalUnit -Identity $targetOU -ErrorAction SilentlyContinue)) {
        Write-Warning "Ziel-OU '$targetOU' existiert nicht. Überspringe User $displayName."
        continue
    }

    # 3. Bestehenden User erkennen (Re-Run) bzw. Kollision auflösen
    $samAccountName = $baseSam
    $i = 1
    $alreadyExists = $false
    while ($existing = Get-ADUser -Filter "SamAccountName -eq '$samAccountName'" -Properties GivenName,Surname -ErrorAction SilentlyContinue) {
        if ($existing.GivenName -eq $user.Firstname -and $existing.Surname -eq $user.Lastname) {
            $alreadyExists = $true
            break
        }
        $i++
        $samAccountName = $baseSam.Substring(0, [Math]::Min($baseSam.Length, 20 - "$i".Length)) + $i
    }
    if ($alreadyExists) {
        Write-Host "[!] Benutzer '$samAccountName' ($displayName) existiert bereits. Überspringe..." -ForegroundColor Yellow
        continue
    }

    # 4. Parameter
    $userParams = @{
        SamAccountName        = $samAccountName
        UserPrincipalName     = "$samAccountName@$domain"
        Name                  = $displayName
        GivenName             = $user.Firstname
        Surname               = $user.Lastname
        DisplayName           = $displayName
        Department            = $user.Department
        Path                  = $targetOU
        AccountPassword       = $defaultPassword
        Enabled               = $true
        ChangePasswordAtLogon = $true
    }
    if ($user.JobTitle) { $userParams.Title = $user.JobTitle }

    # 5. Contractor: Ablaufdatum ist Pflicht
    if ($user.IsContractor -eq "True") {
        if (-not $user.AccountExpiration) {
            Write-Warning "Contractor $displayName hat kein Ablaufdatum. Überspringe."
            continue
        }
        try {
            $userParams.AccountExpirationDate = [DateTime]::Parse($user.AccountExpiration)
        }
        catch {
            Write-Warning "Ungültiges Ablaufdatum '$($user.AccountExpiration)' bei $displayName. Überspringe."
            continue
        }
    }

    # 6. Benutzer anlegen
    try {
        New-ADUser @userParams
        Write-Host "[+] Benutzer '$displayName' ($samAccountName) angelegt in: $targetOU" -ForegroundColor Green
    }
    catch {
        $errMsg = $_.Exception.Message
        Write-Host "[-] Fehler beim Anlegen von ${displayName}: ${errMsg}" -ForegroundColor Red
        continue
    }

    # 7. Gruppenmitgliedschaft
    $targetGroup = "gg_$($user.Department)_Users"
    try {
        Add-ADGroupMember -Identity $targetGroup -Members $samAccountName
        Write-Host "    └─> Zur Gruppe '$targetGroup' hinzugefügt." -ForegroundColor Gray
    }
    catch {
        $errMsg = $_.Exception.Message
        Write-Host "    [-] Gruppe '$targetGroup' für ${samAccountName}: ${errMsg}" -ForegroundColor Red
    }
}

Write-Host "==> Benutzer-Import abgeschlossen!" -ForegroundColor Yellow