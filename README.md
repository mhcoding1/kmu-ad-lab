# Enterprise Active Directory Home Lab (Windows Server 2022)

>  Praxisnahe Simulation einer sicheren, gehärteten Microsoft Active Directory-Infrastruktur für ein virtuelles KMU (15+ Mitarbeiter) zur Demonstration von On-Premises-Systemadministration, GPO-Governance und Security-Hardening.



![Lab-Architektur Übersicht](screenshots/01-aduc-structure.png)

---

## Umgebungsübersicht

- **Domäne:** `LAB.local`
- **Domain Controller:** `DC01` (10.0.2.15) unter Windows Server 2022
- **Mitglieds-Client:** `CLI01` unter Windows 10/11 Enterprise
- **Netzwerk-Isolierung:** Isoliertes VirtualBox NAT-Netzwerk (`10.0.2.0/24`) ohne externe DNS-Weiterleitungen
- **Verwaltungsmodell:** AGDLP-Prinzip mit vorbereiteter Struktur für gestaffelte Administration (Tiering-Modell)

---

## OU- & Identitäten-Struktur (Organizational Units)

Die Active Directory-Umgebung nutzt eine strukturierte OU-Hierarchie auf Enterprise-Niveau (`KMU_Objects`), unterteilt in Identitäten, administrative Grenzen und verwaltete Geräte.

### Active Directory Topologie
- `KMU_Objects`
  - `Admin_Accounts` *(Vorbereitete OU für zukünftiges Tiered Administration Model)*
  - `Devices`
    - `Servers`
    - `Workstations`
  - `Users`
    - `Execs`
    - `IT`
    - `HR`
    - `Finance`
    - `Sales`
    - `Contractors` *(Inklusive automatischem Ablaufdatum für externe Mitarbeiter)*

![ADUC-Struktur & Abteilungsbenutzer](screenshots/01-aduc-structure.png)

---

## Automatisierung & Skript-Deployment

Alle OUs, globalen Sicherheitsgruppen für die Abteilungen und Benutzerkonten wurden mithilfe von PowerShell-Skripten und einer strukturierten CSV-Datei vollautomatisch angelegt.

### 1. Erzeugung der Testdaten (`scripts/00-Create-KMU-Users`)
- Generiert automatisiert die Quelldatei `kmu_users.csv` inklusive UTF-8-Codierung.
- Legt alle 17 Test-Mitarbeiter mit Vor-/Nachnamen, Abteilungen, Rollen, Vorgesetzten und Ablaufdaten für externe Contractors fest.

### 2. Erstellung der OU- & Gruppenstruktur (`scripts/01-Create-OUs.ps1`)
- Erstellt die Haupt-OU `KMU_Objects` sowie alle benötigten Unter-OUs.
- Aktiviert den Schutz vor versehentlicher Löschung (`-ProtectedFromAccidentalDeletion $true`).
- Erstellt automatisch globale Abteilungsgruppen (z. B. `gg_IT_Users`, `gg_HR_Users`) nach der **AGDLP**-Namenskonvention.

### 3. Automatisierter Benutzer-Import (`scripts/02-Import-Users.ps1`)
- Liest alle Benutzerattribute aus `scripts/kmu_users.csv` ein.
- Generiert standardisierte Anmeldenamen (`hmueller`, `fschmid`) inklusive Ersetzung deutscher Umlaute.
- Setzt sichere Initialpasswörter, fordert eine Passwortänderung bei der ersten Anmeldung und weist Benutzer direkt ihren Abteilungsgruppen zu.
- Steuert den Lebenszyklus externer Dienstleister (Contractors) durch automatisches Setzen von Konto-Ablaufdaten.

---

## Sicherheits-Härtung & Gruppenrichtlinien (GPO)

Die Sicherheitseinstellungen der Domäne basieren auf Microsoft Security Best Practices:

1. **Vorbereitung Tiered Administration:** Die OU-Struktur (`Admin_Accounts`) ist für die zukünftige Trennung von administrativen Ebenen (Tier 0 / Tier 1 / Tier 2) vorkonfiguriert.
2. **Gehärtete Default Domain Policy:** Erzwingt komplexe Passwörter, Kontosperrungsrichtlinien und begrenzte Kerberos-Ticket-Laufzeiten.
3. **Ausblick / Next Steps:** Implementierung von Windows LAPS (Local Administrator Password Solution) sowie Zuordnung dedizierter Tier-Admins inkl. Authentication Policies & User Rights Assignment GPOs.

![Gruppenrichtlinienverwaltung Übersicht](screenshots/02-gpo-overview.png)

![Windows LAPS Attribut-Überprüfung](screenshots/03-laps-functional.png)

---

## Repository-Struktur

```text
Enterprise-AD-HomeLab/
├── README.md
├── LICENSE
├── scripts/
│   ├── 00-Generate-UsersCSV.ps1
│   ├── 01-Create-OUs.ps1
│   ├── 02-Import-Users.ps1
│   └── kmu_users.csv
└── screenshots/
    ├── 01-aduc-structure.png
    ├── 02-gpo-overview.png
    └── 03-laps-functional.png