Its Box Server Side Script
==========================
# itsInit.py
roster 파일에 정의된 host에 salt-minion을 설치 
+ 로그인
  - rsa key를 이용해서 로그인   
    - --priv=/path/rsa/private/key or -p /path/rsa/private/key 
  - [to-do] password를 이용해서 로그인   
    - 구현 예정 
+ Salt Master
  - salt master의 IP는 pillar에 정의되어 있어야 함   
    - [to-do] 미 정의 되어 있는 경우는 에러를 발생시키면 중지   
    - [to-do] 실행시 입력 받을수 있음 
+ Roster
  - /etc/salt/roster   
    - ip  
    - user : 
      - root가 아닌 유저로 설정하는 경우 minion에 sudoers에 NOPASSWD가 설정되어 있어야 함 ([to-do]설정방법 추가)
      - root로 설정하는 경우, ssh root login이 허용되어 있어야 함   
    - Sudo : root가 아닌 유저로 설정하는 경우 설치시에 sudo를 이용해야 하므로 True로 설정해야 함  
  - salt의 기능으로 제어되는 것이 아니라 minion이 설치된 서버의 보안정책에 따라 달라지므로 다양한 변종이 생길수 있음 
    - CSP의 정책에 따라 대응 설정 확인후 추가 필요   
         - 확인 완료 : amazon, alyun - ssh 최초 접속시 known host 등록 
+ SSH 설정
  - ssh 최초 접속시 known host 등록여부를 확인하는 경우에 응답을 기다리므로  salt master의 ssh 설정(/etc/ssh/ssh_config)에 StrictHostKeyChecking no를 추가
  
# itsSvr.py
site configuration 파일을 이용해서 정의된 salt state를 수행
+ site config
  - yaml 형식의 파일로 pillar 정의 파일과 동일한 형태  
  - -i /path/site/config/file or --input=/path/site/config/file

# site configuration
사이트 구성 정보를 저장한 파일, pillar로 이동예정
+ physical server
+ logical server
+ software

