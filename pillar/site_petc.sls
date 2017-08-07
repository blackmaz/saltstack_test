sample:
  petclinic:
    physical_server:
      server1:
        hostname: petdb
        ip: 172.28.128.13
        eip: 172.28.128.13
        user: ubuntu
      server2:
        hostname: petwas
        ip: 172.28.128.14
        eip: 172.28.128.14
        user: ubuntu
    logical_server:
      db:
        physical_server:
          - server1
      web:
        physical_server:
          - server2
      was:
        physical_server:
          - server2
    software:
      mysql:
        deploy_server: db
        service_ip: server1
        service_port: 3306
        root:
          pwd: petclinic
      nginx:
        deploy_server: web
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
            enable: True
      tomcat:
        deploy_server: was
        jdk: openjdk
        install:
          insthome: /www/petclinic
          home: /www/petclinic/apache-tomcat-7.0.77
          java_opts: -server -Xms512m -Xmx512m -XX:PermSize=128m -XX:MaxPermSize=128m -XX:+DisableExplicitGC
        server:
          http_port: 8080
          ajp_port: 8009
          app_base: webapps
          name: petclinic
          contexts:
            /:
              doc_base: petclinic
            test:
              doc_base: test
    apps:
      petclinic:
        source:
          s3:
            keyid: changeme-1
            key: changeme-2
            region: ap-northeast-2
            bucket: itsbox
            filepath: apps/petclinic
            filename: petclinic.war
        target:
          tomcat:
            home: /www/petclinic/apache-tomcat-7.0.77
            appBase: webapps
            docBase: petclinic
        tmp: /tmp
