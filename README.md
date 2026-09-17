# Oracle APEX Enterprise Docker (Windows VM)

This repository automates the installation of **Oracle Database 19c**, **Oracle APEX 24.2**, and **Oracle REST Data Services (ORDS) 25.4** inside a Windows 11 Virtual Machine running inside a Docker Container.

> **Note on Licensing (Oracle Enterprise vs. Free Tier):** This project uses the **Oracle Database 19c Enterprise Edition** installer. The required binaries are `.gitignore`d because they are proprietary. 
> * Can I use this for free? You can legally use the Enterprise Edition for free *only* for development, testing, and prototyping under the Oracle Technology Network (OTN) license. If you want a completely free tier for production use, you would need to modify this setup to use **Oracle Database XE (Express Edition)** instead.
> 
> **Network ACL Whitelisting included:** The automated APEX setup script automatically configures the Oracle Network ACL (Access Control List) to whitelist outbound network connections. This allows your APEX applications to immediately use `APEX_WEB_SERVICE` (REST APIs) and `APEX_MAIL` without manual configuration.

---

## 📥 Required Oracle Binaries

Before starting the Docker container, you must download the following three components from Oracle and extract them into the `APEX/` directory with specific folder names. 

The `APEX/` directory acts as our "OEM" drive, which the Docker container automatically copies into the Windows machine during the initial boot.

### 1. Oracle Database 19c
1. Download **Oracle Database 19c (Windows x64)** from the [Oracle Database Downloads page](https://www.oracle.com/database/technologies/oracle19c-windows-downloads.html).
2. Extract the downloaded `.zip` file into the following directory:
   ```text
   APEX/ORACLE19C/
   ```
   *(Ensure `setup.exe` is located at `APEX/ORACLE19C/setup.exe`)*

### 2. Oracle REST Data Services (ORDS)
1. Download the latest version of ORDS (e.g., 25.4) from the [Oracle Developer Downloads page](https://www.oracle.com/database/sqldeveloper/technologies/db-actions/download/).
2. Extract the `.zip` file into the following directory:
   ```text
   APEX/ORDS 25.4/
   ```
   *(Ensure `ords.war` is located at `APEX/ORDS 25.4/ords.war`)*

### 3. Oracle APEX
1. Download Oracle APEX (e.g., 24.2) from the [Oracle APEX Downloads page](http://www.oracle.com/tools/downloads/apex-downloads/).
2. Extract the `.zip` file into the following directory:
   ```text
   APEX/Oracle APEX 24.2/
   ```
   *(Ensure `apexins.sql` is located at `APEX/Oracle APEX 24.2/apex/apexins.sql`)*

---

## ⚙️ Configuration (.env)

You must create a `.env` file in the root of the repository to configure your master Oracle password. This password will be used automatically for the database `SYS`/`SYSTEM` users, the APEX `ADMIN` user, and all ORDS configurations.

Create a `.env` file with the following content:
```env
# Password must contain at least 1 uppercase, 1 lowercase, and 1 number
ORACLE_PASSWORD=YourSecurePassword123!
```

---

## 🚀 How to Run (Automated Setup)

1. **Verify your files:** Ensure all three Oracle components are extracted correctly in the `APEX/` folder and your `.env` is configured.
2. **Start the Container:**
   ```bash
   docker compose up -d
   ```
3. **Wait for Automation:** The `dockurr/windows` container will download a Windows 11 ISO, install Windows, and reboot. Upon its final boot to the desktop, it will automatically execute `install.bat`, silently installing Oracle DB, APEX, and ORDS without any human intervention.
4. **Access APEX:** Once the installation finishes (this can take 30+ minutes), you can access APEX from your host machine browser:
   * **Oracle APEX:** `http://localhost:8080/ords/apex`
   * **Oracle Database (Port):** `1521`
   * **Windows VM Viewer:** `http://localhost:8006`
