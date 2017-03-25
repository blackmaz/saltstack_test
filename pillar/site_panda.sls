# Site Configration

# 이 파일은 특정한 사이트를 구성하기 위한 설정 정보의 집합임
# ItsBox UI에서 Site를 설계한 결과 중 물리적인 서버와 각 서버에 설치될 S/W의 정보를 추출하여 생성함
# Physical Server 절은 Cloud Provisioning의 결과를 전달 받음

# 회사와 시스템의 구분
# ItsBox를 여러개의 회사가 동시에 사용하고, 한 회사에 다수의 시스템이 존재할수 있으므로 
# 이런 구조에 대응하기 위해 company, system명을 제일 위에 둠
panda:
  pandamall:

# Physical Server 
# Cloud에 생성된 서버(인스턴스)의 정보
#
# Server식별자 : ItsBox UI에서 부여된 Physical Server의 Unique ID
#                             이후 S/W의 설치시 물리적인 서버 매핑 key로 사용됨
# hostname: 서버에 할당된 hostname
# ip: 서버에 할당된 사설 ip address, vpc 내부의 서버간 통신에 사용
# eip: 서버에 할당된 공인 ip address, 외부 서비스를 위해 사용
    physical server:
      server1:
        hostname: vm83
        ip: 192.168.10.83
        eip: 192.168.10.83
      server2:
        hostname: vm84
        ip: 192.168.10.84
        eip: 192.168.10.84
      server3:
        hostname: vm93
        ip: 192.168.10.93
        eip: 192.168.10.93
      server4:
        hostname: vm94
        ip: 192.168.10.94
        eip: 192.168.10.94
# Logical Server
# ItsBox에서 PS와 S/W를 연결하기 위한 가상의 서버
#
# Server식별자: ItsBox UI에서 부여된 Logical Server의 Unique ID
#                            서버의 기능에 따라서 의미있게 부여함
# physical server: Logical Server의 구성원
#                            여러개의 PS가 입력될수 있고, 한개의 PS는 여러개의 LS의 멤버가 될 수 있음
# 기타 : Master-Slave 구조의 서버 그룹에서 Master ip의 정보와 같이 여러 물리 서버를 묶었을때
# 그것을 대표하는 속성은 앞으로함 이 부분에 추가 정의
    logical server:
      db:
        physical server:
          - server3
      web:
        physical server:
          - server4
      sms_man:
        physical server:
          - server1
      sms_agt:
        physical server:
          - server2
          - server3
          - server4
# Software
# 설치될 소프트웨어의 정보와 솔트스택 포뮬러에 입력으로 사용될 변수의 집합
#
# sofeware식별자: 소프트웨어명칭 saltstack formula 명
# deploy server: S/W가 설치될 Logical Server의 식별자
    software:
      common:
        s3:
          keyid: xxxx
          key: xxxx
          region: ap-northeast-1
          bucket: my-bucket-for-fileserver
      mysql:
        deploy server: db
        # A 미사용
        service_ip: server3
        service_port: 3306
        # mysql.root Action
        # mysql의 root password를 설정
        # issue: ubuntu에서 mysql 설치 직후에 연결하여 수행하면 에러 발생
        root:
          pwd: manager365
        # mysql.databases Action
        # mysql의 user와 database를 생성하고 grant를 설정
        databases:
          nest:
            user: root
            pwd: manager365
          pandamall:
            user: pandamall
            pwd: 1qazxsw2
      apache:
        deploy server: web
        vhosts:
          5giraffe.com:  
            ports: 
              80:
                use_redir: True 
                redirect_from: / 
                redirect_to: https://www.ozr.kr/
              443: 
                use_redir: True 
                redirect_from: / 
                redirect_to: https://www.ozr.kr/
            enable: True 
          www.5giraffe.com:  
            ports: 
              443: 
                use_redir: True 
                redirect_from: / 
                redirect_to: https://www.ozr.kr/
            enable: True 
          ozr.kr:  
            ports: 
              80: 
                use_redir: True 
                redirect_from: / 
                redirect_to: https://www.ozr.kr/
              443: 
                use_redir: True 
                redirect_from: / 
                redirect_to: https://www.ozr.kr/
            enable: True 
          www.ozr.kr:  
            ports: 
              443:  
                server_admin: webmaster
                doc_root: /www/nest/tomcat7/webapps
                log_root: /www/nest/logs/web
                use_ssl: True
                use_modjk: True
                jk_pattern: 
                  /*.jsp: worker2
                  /*.do: worker2 
                  /*.act: worker2
            enable: True
          www.oops.kr:  
            ports: 
              80:  
                server_admin: webmaster
                doc_root: /www/nest/oops
                log_root: /www/nest/logs/web
                use_modproxy: True
                proxy_pattern:
                  /: http://192.168.10.85:8080/
                  /test: http://192.168.10.85:8080/test/
# 특정 확장자는 proxy로 보내지 않는 설정 필요
#              jepg, gif 등 이미지, html, css같은 정적 컨텐츠는 web서버에서 처리토록
# 확장자를 지정하여 proxy로 보내는 설정-- 현재 에러나서 막아둠
#            proxy_ext:
#              jsp: http://192.168.10.85:8080/
#              do: http://192.168.10.85:8080/
            enable: True
        modjk:
          worker: 
            worker1: 
              port: 7009
              host: localhost
            worker2: 
              port: 8009
              host: localhost 
          lb: 
            loadbalancer: 
              balance_workers: 
                - worker1
                - worker2 
          list: 
            - worker1
            - worker2
        openssl: True
      nginx:
        deploy server: web
        vhosts:
          5giraffe.com:  
            ports: 
              80:
                use_redir: True 
                redirect_from: / 
                redirect_to: https://www.ozr.kr
            enable: True 
          www.5giraffe.com:  
            ports: 
              80: 
                use_redir: True 
                redirect_from: / 
                redirect_to: https://www.ozr.kr
            enable: True 
          ozr.kr:  
            ports: 
              80: 
                use_redir: True 
                redirect_from: / 
                redirect_to: https://www.ozr.kr
            enable: True 
          www.ozr.kr:  
            ports: 
              80:  
                server_admin: webmaster
                doc_root: /www/nest/tomcat7/webapps
                log_root: /www/nest/logs/web
#                use_ssl: True
                use_modproxy: True
# context 전체를 보낼때 / 가 중복되는 경우 에러가 나서 그 부분 해결 필요
# nginx는 컨텍스트 보다는 확장자 설정이 편리하게 되어 있음
                proxy_ext:
                  jsp: http://192.168.10.85:8080
                  do : http://192.168.10.85:8080
            enable: True
        openssl: True
      tomcat:
        deploy server: web
        jdk: openjdk
        install:
          insthome: /www/nest
          home: /www/nest/apache-tomcat-7.0.76
          java_opts: -server -Xms512m -Xmx512m -XX:PermSize=128m -XX:MaxPermSize=128m -XX:+DisableExplicitGC
        server:
          http_port: 8080
          ajp_port: 8009
          appBase: webapps
          name: www.nestfunding.kr
          Contexts:
            /:
              docBase: ozr
            test:
              docBase: test
