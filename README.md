# ping_wlan_check
윈도우용 ping 체크 , 무선연결상태 확인 스크립트
ping 체크 , 무선연결상태 확인시 timestamp 적용되어 로그 분석에 용이.

<사용법>
1. netsh_ping_test _both.bat 를 실행하고 ping 체크할 게이트웨이를 입력하면 됨.
2. 바탕화면\ping_check에 폴더를 생성하여 로그(ping 체크, netsh wlan show interface 체크를 1초마다 수행)를 저장.

<Rocky 8에서 페이지 설치 방법>
git clone https://github.com/cockcut/ping_wlan_check.git pingwlancheck
