sp1:
  petclinic:
    physical server:
      server1:
        hostname: sp1web01
        ip: 192.168.10.11
        eip: 192.168.10.11
        user: ubuntu
      server2:
        hostname: sp1web02
        ip: 192.168.10.12
        eip: 192.168.10.12
        user: ubuntu
      server3:
        hostname: sp1db01
        ip: 192.168.10.13
        eip: 192.168.10.13
        user: ubuntu
        role:
          - mysql_master
      server4:
        hostname: sp1db02
        ip: 192.168.10.14
        eip: 192.168.10.14
        user: ubuntu
        role:
          - mysql_slave
    logical server:
      db:
        hostname: sp1db
        physical server:
          - server3
          - server4
      web:
        hostname: sp1was
        vip: 192.168.10.15
        physical server:
          - server1
          - server2
      was:
        hostname: sp1was
        physical server:
          - server1
          - server2
    software:
      mysql:
        install type: master/slave
        deploy server: db
        service_ip: server1
        service_port: 3306
        root:
          pwd: petclinic
      nginx:
        deploy server: web
        vhosts:
          www.petclinic.kr:
            ports:
              80:
                server_admin: webmaster
                doc_root: /www/petc/htdocs
                log_root: /www/petc/logs/web
                use_modproxy: True
# 패턴에 맞는 url을 백엔드로 보내려면 proxy_pattern을 사용
# 확장자를 백엔드로 보내려면 proxy_ext를 사용
                proxy_pattern:
                  /petclinic : http://localhost:8080
#               proxy_ext:
#                 jsp : http://localhost:8080
# enable: False --> 컨피그 파일을 생성하지만 실제 적용은 하지 않음(default)
# enable: True  --> 컨피그 파일을 생성하고 web 서버에 적용함
            enable: False
      tomcat:
        deploy server: was
        jdk: openjdk
        install:
          insthome: /www/petclinic
          home: /www/petclinic/apache-tomcat-7.0.77
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
