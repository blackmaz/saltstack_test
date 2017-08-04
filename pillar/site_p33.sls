p33:
  petclinic:
    physical_server:
      server1:
        hostname: test1
        ip: 192.168.10.10
        eip: 192.168.10.10
        user: vagrant 
      server2:
        hostname: test2
        ip: 192.168.10.12
        eip: 192.168.10.12
        user: vagrant 
    logical_server:
      web:
        vip: 192.168.10.12
        physical_server:
          - server2
      was:
        physical_server:
          - server2
    software:
      mysql:
        install_type: replication
        deploy_server: db
        service_ip: 192.168.10.12
        service_port: 3306
        root:
          pwd: petclinic
        databases:
          petclinic:
            user: root
            pwd: petclinic
        replication:
          id: repl
          pw: 1q2w3e4r
      nginx:
        deploy_server: web
        vhosts:
          localhost:
            ports:
              80:
                server_admin: webmaster
                doc_root: /www/petclinic/htdocs
                log_root: /www/petclinic/logs/web
                use_modproxy: True
                proxy_pattern:
                  /petclinic : http://localhost:8080/petclinic
            enable: true
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
