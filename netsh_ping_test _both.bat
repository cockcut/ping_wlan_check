@echo off
chcp 65001 >nul
title 무선 모니터링 메인 컨트롤러

:: 현재 날짜와 시간을 yymmddhhmmss 포맷으로 가공 (PowerShell 활용)
for /f "usebackq delims=" %%A in (`powershell -NoProfile -Command "[DateTime]::Now.ToString('yyMMddHHmmss')"`) do (
    set "DATETIME_SUFFIX=%%A"
)

:: ============================================================
:: 바탕화면에 로그 저장 폴더 생성
:: ============================================================
set "LOG_DIR=%USERPROFILE%\Desktop\ping_check"

if not exist "%LOG_DIR%" (
    mkdir "%LOG_DIR%"
)

:: 저장할 로그 파일 이름 설정
set "PING_LOG=%LOG_DIR%\ping_record_log_%DATETIME_SUFFIX%.txt"
set "WLAN_LOG=%LOG_DIR%\wlan_diagnostic_log_%DATETIME_SUFFIX%.txt"

:INPUT_IP
cls
echo ============================================================
echo  [모니터링 대상 IP 입력]
echo ============================================================
set "TARGET_IP="
set /p "TARGET_IP=핑 테스트를 진행할 게이트웨이 IP를 입력하세요: "

:: 빈칸 입력 검사
if "%TARGET_IP%"=="" (
    echo [오류] IP 주소를 입력하지 않았습니다. 다시 입력해 주세요.
    timeout /t 2 >nul
    goto INPUT_IP
)

:: CMD의 괄호 분기 에러를 피하기 위해 PowerShell 검증을 변수로 받아 처리
set "IS_VALID_IP=false"
for /f "usebackq delims=" %%A in (`powershell -NoProfile -Command "if ('%TARGET_IP%' -match '^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$') { 'true' } else { 'false' }"`) do (
    set "IS_VALID_IP=%%A"
)

if "%IS_VALID_IP%"=="false" (
    echo [오류] 입력한 '%TARGET_IP%' 은 올바른 IP 주소 형식이 아닙니다.
    timeout /t 2 >nul
    goto INPUT_IP
)

:: 이전 기록과 구분하기 위한 시작선 추가 (UTF-8 인코딩 지정)
powershell -NoProfile -Command "Add-Content -Path '%PING_LOG%' -Value '============================================================' -Encoding utf8"
powershell -NoProfile -Command "Add-Content -Path '%PING_LOG%' -Value '[%DATE% %TIME%] 실시간 핑 모니터링 시작 (대상: %TARGET_IP%)' -Encoding utf8"
powershell -NoProfile -Command "Add-Content -Path '%PING_LOG%' -Value '============================================================' -Encoding utf8"

powershell -NoProfile -Command "Add-Content -Path '%WLAN_LOG%' -Value '============================================================' -Encoding utf8"
powershell -NoProfile -Command "Add-Content -Path '%WLAN_LOG%' -Value '[%DATE% %TIME%] 1초 주기 무선 상태 기록 시작' -Encoding utf8"
powershell -NoProfile -Command "Add-Content -Path '%WLAN_LOG%' -Value '============================================================' -Encoding utf8"

cls
echo ============================================================
echo  [모니터링 프로그램 관리자]
echo  * 모니터링 대상: %TARGET_IP%
echo  1. %TARGET_IP% 실시간 핑 모니터링 창을 실행합니다.
echo  2. 1초 주기 netsh wlan show int 화면 표시 및 수집 창을 실행합니다.
echo ============================================================
echo  * 핑 로그 저장 파일: %PING_LOG%
echo  * 무선 상태 저장 파일: %WLAN_LOG%
echo ============================================================
echo.

:: 1. 실시간 핑 모니터링 창 실행
start "실시간 Ping 모니터링 - %TARGET_IP%" powershell -NoProfile -Command "chcp 65001 >$null; Write-Host '%TARGET_IP% 실시간 핑 수집 중... (로그 파일: %PING_LOG%)' -ForegroundColor Cyan; ping.exe -t %TARGET_IP% | ForEach-Object { $line = $_; if ($line -match '\S') { $logLine = \"$([DateTime]::Now) - $line\"; Write-Host $logLine; Add-Content -Path '%PING_LOG%' -Value $logLine -Encoding utf8 } }"

:: 2. 1초 주기 무선 상태 수집 창 실행
start "1초 주기 무선 상태 수집" powershell -NoProfile -Command "chcp 65001 >$null; Write-Host '1초 주기 무선 상태 수집 및 화면 표시 중... (로그 파일: %WLAN_LOG%)' -ForegroundColor Green; while ($true) { $now = [DateTime]::Now.ToString('yyyy-MM-dd HH:mm:ss'); Write-Host '========================================' -ForegroundColor Yellow; Write-Host \"[수집 시각: $now]\" -ForegroundColor Yellow; Write-Host '========================================' -ForegroundColor Yellow; Add-Content -Path '%WLAN_LOG%' -Value '========================================' -Encoding utf8; Add-Content -Path '%WLAN_LOG%' -Value \"[수집 시각: $now]\" -Encoding utf8; Add-Content -Path '%WLAN_LOG%' -Value '========================================' -Encoding utf8; $netshOut = netsh wlan show interfaces; $netshOut | Out-String | ForEach-Object { Write-Host $_; Add-Content -Path '%WLAN_LOG%' -Value $_ -Encoding utf8 }; Start-Sleep -Seconds 1 }"

echo 1) 모니터링 창들이 성공적으로 활성화되었습니다. 이창은 닫으셔도 됩니다.
echo 2) 로그 파일은 바탕화면\ping_check 폴더에 저장됩니다. (xxxx_년월일시분초.txt)
echo 3) 수집을 중단하려면 새로 열린 창들을 닫아주시면 됩니다.
echo.
pause