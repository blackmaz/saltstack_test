sample:
  petclinic:
    physical server:
      server1:
        hostname: ip-10-20-0-225
        ip: 13.112.153.34
        eip: 13.112.153.34
    logical server:
      db:
        physical server:
          - server1
      web:
        physical server:
          - server1
      was:
        physical server:
          - server1
    software:
      mysql:
        deploy server: db
        service_ip: server1
        service_port: 3306
        root:
          pwd: petclinic
      nginx:
        deploy server: web
        vhosts:
          localhost:
            ports:
              80:
                server_admin: webmaster
                use_modproxy: True
                proxy_ext:
                  /petclinic : http://localhost:8080
      tomcat:
        deploy server: web
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
    apps:
      petclinic:
        deploy server: was
        s3:
          keyid: xxx
          key: yyy
          region: ap-northeast-1
          bucket: my-bucket-for-fileserver
          downloadDir: /tmp
        deploy:
          type: war
          filename: petclinic.war
