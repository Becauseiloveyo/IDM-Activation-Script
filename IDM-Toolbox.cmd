@echo off
setlocal EnableExtensions
set "toolboxver=2.0.0"
set "repo=https://github.com/Becauseiloveyo/IDM-Activation-Script"
set "idmhome=https://www.internetdownloadmanager.com"
set "newsurl=https://www.internetdownloadmanager.com/news.html"
set "downloadurl=https://www.internetdownloadmanager.com/transfer/download.html"
set "PS=powershell.exe"

if /i "%~1"=="/selftest" goto :SelfTest
for %%# in (powershell.exe) do if "%%~$PATH:#"=="" (
  echo [ERROR] Windows PowerShell was not found.
  exit /b 1
)
if /i "%~1"=="/check" goto :Status
if /i "%~1"=="/diag" goto :Report
if /i "%~1"=="/download" goto :Download
if /i "%~1"=="/help" goto :Help

:Menu
cls
title IDM Toolbox %toolboxver%
echo.
echo ===============================================================
echo                     IDM Toolbox %toolboxver%
echo ===============================================================
echo   Maintained diagnostics, update checks, and official repair tools.
echo   Legacy activation logic remains in IAS.cmd and is untouched.
echo.
echo   [1] IDM / Windows status
echo   [2] Check latest official IDM version
echo   [3] Verify IDM file signatures
echo   [4] Network / proxy diagnostics
echo   [5] Browser integration diagnostics
echo   [6] Generate diagnostic report
echo   [7] Download official IDM installer
echo   [8] Open legacy IAS.cmd
echo   [9] Official IDM / project links
echo   [0] Exit
echo.
choice /C 1234567890 /N /M "Select [1-9,0]: "
set "opt=%errorlevel%"
if "%opt%"=="10" exit /b 0
if "%opt%"=="9" goto :Links
if "%opt%"=="8" goto :Legacy
if "%opt%"=="7" goto :Download
if "%opt%"=="6" goto :Report
if "%opt%"=="5" goto :Browser
if "%opt%"=="4" goto :Network
if "%opt%"=="3" goto :Signatures
if "%opt%"=="2" goto :Latest
if "%opt%"=="1" goto :Status
goto :Menu

:DetectIDM
set "IDMan="
set "IDMDir="
set "IDMRegistryVersion="
set "IDMFileVersion="
for /f "tokens=1,2,*" %%A in ('reg query "HKCU\Software\DownloadManager" /v ExePath 2^>nul') do if /i "%%A"=="ExePath" set "IDMan=%%C"
if not defined IDMan if not "%ProgramFiles(x86)%"=="" if exist "%ProgramFiles(x86)%\Internet Download Manager\IDMan.exe" set "IDMan=%ProgramFiles(x86)%\Internet Download Manager\IDMan.exe"
if not defined IDMan if exist "%ProgramFiles%\Internet Download Manager\IDMan.exe" set "IDMan=%ProgramFiles%\Internet Download Manager\IDMan.exe"
if defined IDMan if exist "%IDMan%" (
  for %%I in ("%IDMan%") do set "IDMDir=%%~dpI"
  set "IAS_IDM_EXE=%IDMan%"
  for /f "delims=" %%A in ('%PS% -NoProfile -Command "$p=$env:IAS_IDM_EXE; try {(Get-Item -LiteralPath $p).VersionInfo.ProductVersion} catch {}" 2^>nul') do set "IDMFileVersion=%%A"
)
for /f "tokens=1,2,*" %%A in ('reg query "HKCU\Software\DownloadManager" /v idmvers 2^>nul') do if /i "%%A"=="idmvers" set "IDMRegistryVersion=%%C"
exit /b

:GetWindows
set "WinCaption="
set "WinVersion="
set "WinBuild="
set "WinArch=%PROCESSOR_ARCHITECTURE%"
for /f "delims=" %%A in ('%PS% -NoProfile -Command "$o=Get-CimInstance Win32_OperatingSystem -ErrorAction SilentlyContinue; if(-not $o){$o=Get-WmiObject Win32_OperatingSystem -ErrorAction SilentlyContinue}; if($o){$o.Caption}" 2^>nul') do set "WinCaption=%%A"
for /f "tokens=3" %%A in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v DisplayVersion 2^>nul ^| find /i "DisplayVersion"') do set "WinVersion=%%A"
if not defined WinVersion for /f "tokens=3" %%A in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v ReleaseId 2^>nul ^| find /i "ReleaseId"') do set "WinVersion=%%A"
for /f "tokens=3" %%A in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v CurrentBuildNumber 2^>nul ^| find /i "CurrentBuildNumber"') do set "WinBuild=%%A"
exit /b

:GetLatest
set "LatestIDM="
for /f "delims=" %%A in ('%PS% -NoProfile -Command "$ProgressPreference='SilentlyContinue'; try {$h=(Invoke-WebRequest -UseBasicParsing -Uri '%newsurl%' -TimeoutSec 15).Content; $m=[regex]::Match($h, 'What''s new in version\s+([0-9.]+(?:\s+Build\s+\d+)?)', 'IgnoreCase'); if($m.Success){$m.Groups[1].Value}} catch {}" 2^>nul') do if not defined LatestIDM set "LatestIDM=%%A"
exit /b

:Status
call :DetectIDM
call :GetWindows
cls
echo.
echo ==================== IDM / Windows status ====================
echo Windows       : %WinCaption%
echo Release       : %WinVersion%
echo Build         : %WinBuild%
echo Architecture  : %WinArch%
echo PowerShell    :
%PS% -NoProfile -Command "$PSVersionTable.PSVersion.ToString()"
echo.
if defined IDMan (
  echo IDM executable : %IDMan%
  echo File version   : %IDMFileVersion%
  echo Registry ver.  : %IDMRegistryVersion%
  tasklist /fi "imagename eq idman.exe" 2>nul | findstr /i "idman.exe" >nul && (echo Process        : Running) || (echo Process        : Not running)
) else (
  echo IDM            : Not detected
)
echo.
call :PauseReturn

:Latest
call :DetectIDM
call :GetLatest
cls
echo.
echo ================= Latest official IDM version ================
if defined LatestIDM (
  echo Latest official: %LatestIDM%
) else (
  echo Latest official: Unable to retrieve from %newsurl%
)
if defined IDMan (
  echo Installed file : %IDMFileVersion%
  echo Installed reg. : %IDMRegistryVersion%
) else (
  echo Installed      : IDM not detected
)
if defined LatestIDM if defined IDMFileVersion (
  set "IAS_LATEST=%LatestIDM%"
  set "IAS_CURRENT=%IDMFileVersion%"
  %PS% -NoProfile -Command "function V([string]$s){$a=[regex]::Match($s,'^(\d+)\.(\d+)'); if(-not $a.Success){return $null}; $b=[regex]::Match($s,'(?i)Build\s+(\d+)'); if($b.Success){$build=$b.Groups[1].Value}else{$c=[regex]::Match($s,'^\d+\.\d+\.(\d+)'); if($c.Success){$build=$c.Groups[1].Value}else{$build='0'}}; return [version]($a.Groups[1].Value+'.'+$a.Groups[2].Value+'.'+$build)}; $c=V $env:IAS_CURRENT; $l=V $env:IAS_LATEST; if($c -and $l){if($c -lt $l){Write-Host 'Comparison     : UPDATE AVAILABLE'}else{Write-Host 'Comparison     : Current/newer'}}else{Write-Host 'Comparison     : Unknown'}"
)
echo.
echo Source: %newsurl%
echo.
call :PauseReturn

:Signatures
call :DetectIDM
cls
echo.
echo ================= IDM signature verification ==================
if not defined IDMan (
  echo IDM is not installed or its path could not be detected.
  echo.
  call :PauseReturn
)
set "IAS_IDM_DIR=%IDMDir%"
%PS% -NoProfile -Command "$d=$env:IAS_IDM_DIR; $names='IDMan.exe','IDMGrHlp.exe','IDMMsgHost.exe','IDMIECC.dll','IDMGetAll.dll'; $results=foreach($n in $names){$p=Join-Path $d $n; if(Test-Path -LiteralPath $p){$s=Get-AuthenticodeSignature -LiteralPath $p; $v=(Get-Item -LiteralPath $p).VersionInfo.FileVersion; [pscustomobject]@{File=$n;Version=$v;Signature=$s.Status;Signer=if($s.SignerCertificate){$s.SignerCertificate.Subject}else{'-'}}}else{[pscustomobject]@{File=$n;Version='-';Signature='Missing';Signer='-'}}}; $results | Format-Table -AutoSize"
echo.
echo Any Invalid, HashMismatch, UnknownError, or unexpected Missing result
echo should be repaired by reinstalling IDM from the official installer.
echo.
call :PauseReturn

:Network
cls
echo.
echo ================= Network / proxy diagnostics =================
echo DNS resolution:
%PS% -NoProfile -Command "try {[Net.Dns]::GetHostAddresses('www.internetdownloadmanager.com') | ForEach-Object {$_.IPAddressToString}} catch {Write-Host ('FAILED: ' + $_.Exception.Message)}"
echo.
echo HTTPS TCP/443:
%PS% -NoProfile -Command "$c=New-Object Net.Sockets.TcpClient; try {$r=$c.BeginConnect('www.internetdownloadmanager.com',443,$null,$null); if(-not $r.AsyncWaitHandle.WaitOne(5000)){throw 'timeout'}; $c.EndConnect($r); Write-Host 'OK'} catch {Write-Host ('FAILED: ' + $_.Exception.Message)} finally {$c.Close()}"
echo.
echo HTTPS request:
%PS% -NoProfile -Command "$ProgressPreference='SilentlyContinue'; try {$r=Invoke-WebRequest -UseBasicParsing -Uri '%newsurl%' -TimeoutSec 15; Write-Host ('HTTP ' + [int]$r.StatusCode)} catch {Write-Host ('FAILED: ' + $_.Exception.Message)}"
echo.
echo WinHTTP proxy:
netsh winhttp show proxy
echo.
echo User proxy settings:
reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable 2>nul
reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyServer 2>nul
reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v AutoConfigURL 2>nul
echo.
echo Process proxy environment:
if defined HTTP_PROXY echo HTTP_PROXY=%HTTP_PROXY%
if defined HTTPS_PROXY echo HTTPS_PROXY=%HTTPS_PROXY%
if not defined HTTP_PROXY if not defined HTTPS_PROXY echo No HTTP_PROXY / HTTPS_PROXY variables set.
echo.
call :PauseReturn

:Browser
call :DetectIDM
cls
echo.
echo ================ Browser integration diagnostics ==============
if defined IDMan (
  echo IDM path: %IDMan%
  for %%F in (IDMMsgHost.exe IDMIECC.dll IDMGetAll.dll) do (
    if exist "%IDMDir%%%F" (echo [OK]      %%F) else (echo [MISSING] %%F)
  )
) else (
  echo [MISSING] IDM installation
)
echo.
call :FindBrowser "Chrome" "%ProgramFiles%\Google\Chrome\Application\chrome.exe" "%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe" "%LocalAppData%\Google\Chrome\Application\chrome.exe"
call :FindBrowser "Edge" "%ProgramFiles(x86)%\Microsoft\Edge\Application\msedge.exe" "%ProgramFiles%\Microsoft\Edge\Application\msedge.exe" "%LocalAppData%\Microsoft\Edge\Application\msedge.exe"
call :FindBrowser "Firefox" "%ProgramFiles%\Mozilla Firefox\firefox.exe" "%ProgramFiles(x86)%\Mozilla Firefox\firefox.exe" ""
echo.
echo Native-messaging / integration registry entries containing IDM:
%PS% -NoProfile -Command "$roots='HKCU:\Software\Google\Chrome\NativeMessagingHosts','HKLM:\Software\Google\Chrome\NativeMessagingHosts','HKLM:\Software\WOW6432Node\Google\Chrome\NativeMessagingHosts','HKCU:\Software\Microsoft\Edge\NativeMessagingHosts','HKLM:\Software\Microsoft\Edge\NativeMessagingHosts','HKLM:\Software\WOW6432Node\Microsoft\Edge\NativeMessagingHosts','HKCU:\Software\Mozilla\NativeMessagingHosts','HKLM:\Software\Mozilla\NativeMessagingHosts','HKLM:\Software\WOW6432Node\Mozilla\NativeMessagingHosts'; $found=$false; foreach($r in $roots){if(Test-Path $r){Get-ChildItem $r -ErrorAction SilentlyContinue | Where-Object {$_.PSChildName -match 'idm|internetdownload'} | ForEach-Object {$found=$true; $_.Name}}}; if(-not $found){Write-Host 'No matching native-messaging entries found.'}"
echo.
echo IDM browser-related registry values:
reg query "HKCU\Software\DownloadManager" 2>nul | findstr /I "Browser Chrome Edge Firefox Integration" 
echo.
echo Official browser integration help:
echo %idmhome%/register/new_faq/bi9.html
choice /C YN /N /M "Open the official integration help page? [Y/N]: "
if errorlevel 2 goto :Menu
start "" "%idmhome%/register/new_faq/bi9.html"
goto :Menu

:FindBrowser
set "bname=%~1"
set "found="
for %%P in ("%~2" "%~3" "%~4") do if not "%%~P"=="" if exist "%%~P" set "found=%%~P"
if defined found (echo [OK]      %bname% - %found%) else (echo [NOT FOUND] %bname%)
exit /b

:Report
call :DetectIDM
set "IAS_IDM_EXE=%IDMan%"
set "IAS_IDM_DIR=%IDMDir%"
for /f "delims=" %%A in ('%PS% -NoProfile -Command "[Environment]::GetFolderPath('Desktop')"') do set "DesktopPath=%%A"
if not defined DesktopPath set "DesktopPath=%USERPROFILE%\Desktop"
for /f "delims=" %%A in ('%PS% -NoProfile -Command "Get-Date -Format yyyyMMdd-HHmmss"') do set "stamp=%%A"
set "ReportFile=%DesktopPath%\IDM-Diagnostic-%stamp%.txt"
%PS% -NoProfile -Command "$ErrorActionPreference='SilentlyContinue'; $out=$env:ReportFile; $lines=New-Object Collections.Generic.List[string]; function A([string]$s){$lines.Add($s)}; A('IDM Toolbox diagnostic report'); A('Generated: '+(Get-Date)); A('Toolbox: %toolboxver%'); A(''); $os=Get-CimInstance Win32_OperatingSystem -ErrorAction SilentlyContinue; if(-not $os){$os=Get-WmiObject Win32_OperatingSystem -ErrorAction SilentlyContinue}; if($os){A('Windows: '+$os.Caption+' '+$os.Version+' build '+$os.BuildNumber)}; A('Architecture: '+$env:PROCESSOR_ARCHITECTURE); A('PowerShell: '+$PSVersionTable.PSVersion); A(''); $p=$env:IAS_IDM_EXE; if($p -and (Test-Path -LiteralPath $p)){A('IDM path: '+$p); $f=Get-Item -LiteralPath $p; A('IDM product version: '+$f.VersionInfo.ProductVersion); $s=Get-AuthenticodeSignature -LiteralPath $p; A('IDM signature: '+$s.Status); if($s.SignerCertificate){A('IDM signer: '+$s.SignerCertificate.Subject)}; A('IDM SHA256: '+(Get-FileHash -LiteralPath $p -Algorithm SHA256).Hash)} else {A('IDM: not detected')}; A(''); try {$ips=[Net.Dns]::GetHostAddresses('www.internetdownloadmanager.com') | ForEach-Object {$_.IPAddressToString}; A('DNS: '+($ips -join ', '))} catch {A('DNS: FAILED')}; try {$r=Invoke-WebRequest -UseBasicParsing -Uri '%newsurl%' -TimeoutSec 15; A('Official HTTPS: HTTP '+[int]$r.StatusCode)} catch {A('Official HTTPS: FAILED - '+$_.Exception.Message)}; A(''); A('WinHTTP proxy:'); $proxy=(netsh winhttp show proxy 2>&1); foreach($x in $proxy){A([string]$x)}; A(''); if($env:HTTP_PROXY){A('HTTP_PROXY: set')}; if($env:HTTPS_PROXY){A('HTTPS_PROXY: set')}; A(''); A('NOTE: serial/license values are intentionally excluded.'); $lines | Set-Content -LiteralPath $out -Encoding UTF8"
if exist "%ReportFile%" (
  echo.
  echo Report created:
  echo %ReportFile%
  start "" notepad.exe "%ReportFile%"
) else (
  echo.
  echo [ERROR] Failed to create diagnostic report.
)
echo.
call :PauseReturn

:Download
cls
echo.
echo ================= Official IDM installer ======================
set "DownloadDir=%USERPROFILE%\Downloads"
if not exist "%DownloadDir%" set "DownloadDir=%TEMP%"
set "Installer=%DownloadDir%\idman-latest.exe"
set "IAS_INSTALLER=%Installer%"
echo Downloading from:
echo %downloadurl%
echo To:
echo %Installer%
echo.
%PS% -NoProfile -Command "$ProgressPreference='SilentlyContinue'; try {Invoke-WebRequest -UseBasicParsing -Uri '%downloadurl%' -OutFile $env:IAS_INSTALLER -TimeoutSec 60; exit 0} catch {Write-Host $_.Exception.Message; exit 1}"
if errorlevel 1 (
  echo [ERROR] Download failed.
  echo.
  call :PauseReturn
)
if not exist "%Installer%" (
  echo [ERROR] Installer file was not created.
  echo.
  call :PauseReturn
)
echo.
echo Verifying Authenticode signature and publisher...
%PS% -NoProfile -Command "$s=Get-AuthenticodeSignature -LiteralPath $env:IAS_INSTALLER; Write-Host ('Status: '+$s.Status); if($s.SignerCertificate){Write-Host ('Signer: '+$s.SignerCertificate.Subject)}; Write-Host ('SHA256: '+(Get-FileHash -LiteralPath $env:IAS_INSTALLER -Algorithm SHA256).Hash); if($s.Status -ne 'Valid' -or -not $s.SignerCertificate -or $s.SignerCertificate.Subject -notmatch 'Tonec'){exit 2}"
if errorlevel 2 (
  echo [WARNING] Signature or publisher verification failed.
  echo The installer will NOT be launched automatically.
  echo File kept at: %Installer%
  echo.
  call :PauseReturn
)
choice /C YN /N /M "Verified official publisher. Run the installer now? [Y/N]: "
if errorlevel 2 goto :Menu
start "" "%Installer%"
goto :Menu

:Legacy
if not exist "%~dp0IAS.cmd" (
  echo IAS.cmd was not found next to this toolbox.
  echo.
  call :PauseReturn
)
start "" "%~dp0IAS.cmd"
goto :Menu

:Links
cls
echo.
echo ========================= Links ================================
echo [1] Official IDM home
echo [2] Official IDM news
echo [3] Official IDM download
echo [4] Project repository
echo [0] Back
choice /C 12340 /N /M "Select [1-4,0]: "
set "linkopt=%errorlevel%"
if "%linkopt%"=="5" goto :Menu
if "%linkopt%"=="4" start "" "%repo%"
if "%linkopt%"=="3" start "" "%idmhome%/download.html"
if "%linkopt%"=="2" start "" "%newsurl%"
if "%linkopt%"=="1" start "" "%idmhome%"
goto :Links

:Help
echo IDM Toolbox %toolboxver%
echo.
echo Usage:
echo   IDM-Toolbox.cmd              Interactive menu
echo   IDM-Toolbox.cmd /check       Show IDM and Windows status
echo   IDM-Toolbox.cmd /diag        Generate a diagnostic report
echo   IDM-Toolbox.cmd /download    Download and verify official IDM installer
echo   IDM-Toolbox.cmd /selftest    Non-destructive script self-test
echo   IDM-Toolbox.cmd /help        Show this help
exit /b 0

:SelfTest
set "fail=0"
for %%L in (Menu DetectIDM GetWindows GetLatest Status Latest Signatures Network Browser FindBrowser Report Download Legacy Links Help PauseReturn) do (
  findstr /B /C:":%%L" "%~f0" >nul || (echo [FAIL] Missing label :%%L&set "fail=1")
)
for %%# in (powershell.exe reg.exe choice.exe findstr.exe) do if "%%~$PATH:#"=="" (echo [FAIL] Missing %%#&set "fail=1")
if "%fail%"=="0" echo [PASS] IDM Toolbox self-test passed.
exit /b %fail%

:PauseReturn
pause
goto :Menu
