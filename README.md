# 🏢 Enterprise Active Directory Home Lab

> **Projekt-Ziel:** Praxisnahe Simulation einer sicheren, gehärteten Microsoft Active Directory-Infrastruktur für ein virtuelles KMU (15+ Mitarbeiter) zur Demonstration von On-Premises-Systemadministration, GPO-Governance und Security-Hardening.

---

## 📐 1. Lab-Architektur & Netzwerk-Design

Die gesamte Infrastruktur läuft in einem isolierten VirtualBox NAT-Netzwerk. Das Lab ist strikt vom privaten Heimnetzwerk getrennt und ohne externe DNS-Weiterleiter vollständig vom Internet isoliert, um eine sichere Umgebung für Tests und Governance-Regeln zu gewährleisten.

### Netzwerk-Spezifikation
* **VirtualBox Network Type:** NAT / NAT-Netzwerk `AD_Netzwerk`
* **Subnetz:** `10.0.2.0/24`
* **Gateway:** `10.0.2.1`

### Virtuelle Maschinen (Nodes)
* **`DC01` (Domain Controller & Primary Services)**
  * **OS:** Windows Server 2022
  * **IP-Adresse:** `10.0.2.15` (Statisch)
  * **DNS:** `127.0.0.1` (Self-Referencing)
  * **Rollen:** AD DS, DNS, DHCP
* **`CLI01` (Enterprise Client Workstation)**
  * **OS:** Windows 11 Enterprise
  * **IP-Adresse:** Dynamisch via DHCP (`DC01`) / Subnetz `10.0.2.x`
  * **DNS:** `10.0.2.15` (`DC01`)

---

## 🏛️ 2. Active Directory – OU-Struktur & Objekte

Die Domäne **`LAB.local`** wurde über den **Server Manager** initialisiert. Um das Standard-Container-Chaos zu vermeiden, wurde eine strukturierte **Organizational Unit (OU)**-Hierarchie zur sauberen Verwaltung von Benutzern, Gruppen und Gruppenrichtlinien (GPOs) implementiert.

### OU-Hierarchie
```text
LAB.local/
└── 🏢 KMU_Objects/
    ├── 👥 Users/
    │   ├── 👔 Execs
    │   ├── 💻 IT
    │   ├── 📋 HR
    │   ├── 💰 Finance
    │   ├── 📈 Sales
    │   └── ⏳ Contractors
    ├── 🖥️ Devices/
    │   ├── 🛠️ Workstations
    │   └── 🖥️ Member_Servers
    └── 🔐 Admin_Accounts/
        ├── 👑 Tier_0
        ├── 🖥️ Tier_1
        └── 🛠️ Tier_2

