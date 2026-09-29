# 🏢 Enterprise Active Directory Home Lab (KMU Simulation)

> **Projekt-Ziel:** Praxisnahe Simulation einer sicheren, gehärteten Microsoft Active Directory-Infrastruktur für ein virtuelles KMU (15+ Mitarbeiter) zur Demonstration von On-Premises-Systemadministration, GPO-Governance und Security-Hardening.

---

## 📐 1. Lab-Architektur & Netzwerk-Design

Die gesamte Infrastruktur läuft isoliert in **Oracle VirtualBox** über ein **NAT-Netzwerk**, um das Produktions- bzw. Heimnetzwerk zu schützen und gleichzeitig kontrollierten Internetzugang zu ermöglichen.

### Netzwerk-Spezifikation
* **VirtualBox Network Type:** NAT-Netzwerk (`KMU-LabNet`)
* **Subnetz:** `192.168.10.0/24`
* **Gateway:** `192.168.10.1`

### Virtuelle Maschinen (Nodes)
* **`DC01` (Domain Controller & Primary Services)**
  * **OS:** Windows Server 2022 / 2025 (Desktop Experience)
  * **IP-Adresse:** `192.168.10.10` (Statisch)
  * **DNS:** `127.0.0.1` (Self-Referencing)
  * **Rollen:** AD DS, DNS, DHCP
* **`CLI01` (Enterprise Client Workstation)**
  * **OS:** Windows 11 Enterprise
  * **IP-Adresse:** Dynamisch via DHCP (`DC01`) / Test-IP: `192.168.10.20`
  * **DNS:** `192.168.10.10` (`DC01`)

---

## 🏛️ 2. Active Directory – OU-Struktur & Objekte

Die Domäne **`kmu-corp.local`** wurde über den **Server Manager** initialisiert. Um das Standard-Container-Chaos zu vermeiden, wurde eine strukturierte **Organizational Unit (OU)**-Hierarchie zur sauberen Verwaltung von Benutzern, Gruppen und Gruppenrichtlinien (GPOs) implementiert.

### OU-Hierarchie
```text
kmu-corp.local/
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
    │   └── 🖥️️ Member_Servers
    └── 🔐 Admin_Accounts/
        ├── 👑 Tier_0
        ├── 🖥️ Tier_1
        └── 🛠️ Tier_2
