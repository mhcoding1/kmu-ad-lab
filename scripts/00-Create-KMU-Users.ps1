# Ordner C:\LabSetup erstellen (falls noch nicht vorhanden)
if (-not (Test-Path "C:\LabSetup")) {
    New-Item -Path "C:\LabSetup" -ItemType Directory -Force
}

# CSV-Inhalt für die 17 KMU-Mitarbeiter definieren
$csvData = @"
Firstname,Lastname,Department,JobTitle,Manager,IsContractor,AccountExpiration
Hans,Mueller,Execs,Geschäftsführer,,False,
Sabine,Weber,Execs,Assistenz der Geschäftsführung,Hans Mueller,False,
Florian,Schmid,IT,IT Infrastructure Manager,Hans Mueller,False,
David,Becker,IT,System Administrator,Florian Schmid,False,
Laura,Wagner,IT,Helpdesk Specialist,David Becker,False,
Klaus,Hoffmann,HR,Head of HR,Hans Mueller,False,
Anja,Schaefer,HR,HR Manager,Klaus Hoffmann,False,
Stefanie,Koch,HR,Recruiter,Klaus Hoffmann,False,
Michael,Schneider,Finance,CFO & Leiter Finanzen,Hans Mueller,False,
Markus,Richter,Finance,Senior Buchhalter,Michael Schneider,False,
Julia,Klein,Finance,Controlling Specialist,Michael Schneider,False,
Thomas,Fischer,Sales,Head of Sales,Hans Mueller,False,
Christian,Wolf,Sales,Key Account Manager,Thomas Fischer,False,
Melanie,Neumann,Sales,Sales Representative,Thomas Fischer,False,
Alexander,Braun,Sales,Marketing Specialist,Thomas Fischer,False,
Jan,Zimmer,Contractors,External DevOps Consultant,Florian Schmid,True,2026-12-31
Sven,Krueger,Contractors,Freelance Recruiter,Klaus Hoffmann,True,2026-10-30
"@

# Als kmu_users.csv mit UTF8-Kodierung speichern
$csvData | Set-Content -Path "C:\LabSetup\kmu_users.csv" -Encoding UTF8

Write-Host "[+] kmu_users.csv wurde erfolgreich unter C:\LabSetup\kmu_users.csv erstellt!" -ForegroundColor Green