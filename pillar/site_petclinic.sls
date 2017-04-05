# Site Configration

# 이 파일은 특정한 사이트를 구성하기 위한 설정 정보의 집합임
# ItsBox UI에서 Site를 설계한 결과 중 물리적인 서버와 각 서버에 설치될 S/W의 정보를 추출하여 생성함
# Physical Server 절은 Cloud Provisioning의 결과를 전달 받음

# 회사와 시스템의 구분
# ItsBox를 여러개의 회사가 동시에 사용하고, 한 회사에 다수의 시스템이 존재할수 있으므로 
# 이런 구조에 대응하기 위해 company, system명을 제일 위에 둠
sample:
  petclinic:
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
        hostname: ip-10-20-0-225
        ip: 10.20.0.225
        eip: 13.112.153.34
      server2:
        hostname: ip-10-20-0-226
        ip: 10.20.0.226
        eip: 54.92.70.34
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
          - server2
      web:
        physical server:
          - server1
      was:
        physical server:
          - server1
# Software
# 설치될 소프트웨어의 정보와 솔트스택 포뮬러에 입력으로 사용될 변수의 집합
#
# sofeware식별자: 소프트웨어명칭 saltstack formula 명
# deploy server: S/W가 설치될 Logical Server의 식별자
    software:
      apps:
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
          petclinic:
            user: pandamall
            pwd: 1qazxsw2
      nginx:
        deploy server: web
        vhosts:
          localhost:  
            ports: 
              80:  
                server_admin: webmaster
                use_modproxy: True
                proxy_pass:
                  jsp: http://10.20.0.225:8080
            enable: True
        openssl: True
      tomcat:
        deploy server: web
        jdk: openjdk
        install:
          insthome: /www/petclinic
          home: /www/petclinic/apache-tomcat-7.0.76
          java_opts: -server -Xms512m -Xmx512m -XX:PermSize=128m -XX:MaxPermSize=128m -XX:+DisableExplicitGC
        server:
          http_port: 8080
          ajp_port: 8009
          appBase: webapps
          name: petclinic
          Contexts:
            /:
              docBase: petclinic
            test:
              docBase: test
