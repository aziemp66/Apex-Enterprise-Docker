@echo off
echo ===================================================
echo Starting Oracle Database 19c, APEX, and ORDS Setup
echo ===================================================

echo [0/7] Loading environment variables from .env...
for /F "eol=# tokens=1,* delims==" %%A in (C:\OEM\.env) do (
    set "%%A=%%B"
)
if "%ORACLE_PASSWORD%"=="" (
    echo ERROR: ORACLE_PASSWORD not found in C:\OEM\.env!
    exit /b 1
)

echo [1/7] Opening Firewall ports for Oracle DB and APEX...
netsh advfirewall firewall add rule name="Oracle DB 1521" dir=in action=allow protocol=TCP localport=1521
netsh advfirewall firewall add rule name="Oracle APEX ORDS 8080" dir=in action=allow protocol=TCP localport=8080

echo [2/7] Copying installation files to C:\19c_24.2...
mkdir C:\19c_24.2
xcopy C:\OEM C:\19c_24.2 /E /H /C /I /Q
cd /d C:\19c_24.2

echo [3/7] Installing Oracle Database 19c (Silent Mode)...
cd /d C:\19c_24.2\ORACLE19C
setup.exe -silent -responseFile C:\19c_24.2\ORACLE19C\install\response\db_2026-04-02_11-29-08AM.rsp oracle.install.db.config.starterdb.password.ALL="%ORACLE_PASSWORD%" oracle.install.db.config.starterdb.password.SYS="%ORACLE_PASSWORD%" oracle.install.db.config.starterdb.password.SYSTEM="%ORACLE_PASSWORD%" oracle.install.db.config.starterdb.password.DBSNMP="%ORACLE_PASSWORD%" oracle.install.db.config.starterdb.password.PDBADMIN="%ORACLE_PASSWORD%" -waitforcompletion
echo Database installation completed.

echo [4/7] Starting Listener (if not started)...
lsnrctl start LISTENER

echo [5/7] Installing Oracle APEX...
cd /d C:\19c_24.2
echo Running APEX installation scripts with dynamically injected password...
sqlplus /nolog @C:\19c_24.2\apex_install_silent.sql "%ORACLE_PASSWORD%"

echo [6/7] Copying APEX images to ORDS directory...
xcopy "C:\19c_24.2\Oracle APEX 24.2\apex\images" "C:\19c_24.2\ords\images" /E /H /C /I /Q

echo [7/7] Generating ORDS configuration and Installing (Silent Mode)...
echo db.hostname=localhost> C:\19c_24.2\ords_params.properties
echo db.port=1521>> C:\19c_24.2\ords_params.properties
echo db.servicename=ORCL>> C:\19c_24.2\ords_params.properties
echo db.username=SYS>> C:\19c_24.2\ords_params.properties
echo db.password=%ORACLE_PASSWORD%>> C:\19c_24.2\ords_params.properties
echo db.adminUser=SYS>> C:\19c_24.2\ords_params.properties
echo db.adminUser.password=%ORACLE_PASSWORD%>> C:\19c_24.2\ords_params.properties
echo migrate.apex.rest=false>> C:\19c_24.2\ords_params.properties
echo rest.services.apex.add=true>> C:\19c_24.2\ords_params.properties
echo rest.services.ords.add=true>> C:\19c_24.2\ords_params.properties
echo schema.tablespace.default=SYSAUX>> C:\19c_24.2\ords_params.properties
echo schema.tablespace.temp=TEMP>> C:\19c_24.2\ords_params.properties
echo standalone.mode=true>> C:\19c_24.2\ords_params.properties
echo standalone.use.https=false>> C:\19c_24.2\ords_params.properties
echo standalone.http.port=8080>> C:\19c_24.2\ords_params.properties
echo standalone.static.context.path=/i>> C:\19c_24.2\ords_params.properties
echo standalone.static.path=C:/19c_24.2/ords/images>> C:\19c_24.2\ords_params.properties
echo user.apex.listener.password=%ORACLE_PASSWORD%>> C:\19c_24.2\ords_params.properties
echo user.apex.restpublic.password=%ORACLE_PASSWORD%>> C:\19c_24.2\ords_params.properties
echo user.public.password=%ORACLE_PASSWORD%>> C:\19c_24.2\ords_params.properties
echo sys.user=SYS>> C:\19c_24.2\ords_params.properties
echo sys.password=%ORACLE_PASSWORD%>> C:\19c_24.2\ords_params.properties

cd /d "C:\19c_24.2\ORDS 25.4\bin"
ords.exe --config C:\19c_24.2\ordsconf\config install --silent --parameterFile C:\19c_24.2\ords_params.properties

echo Setting static paths for ORDS...
ords.exe --config C:\19c_24.2\ordsconf\config config set standalone.static.path "C:\19c_24.2\ords\images"
ords.exe --config C:\19c_24.2\ordsconf\config config set standalone.static.context.path /i/

echo Starting ORDS Server as a background task...
start "" ords.exe --config C:\19c_24.2\ordsconf\config serve

echo ===================================================
echo Setup Complete! Oracle APEX is now available.
echo ===================================================
