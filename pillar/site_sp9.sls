sp9:
  petclinic:
    physical_server:
      server1:
        hostname: de2o_test
        ip: 47.89.21.165
        eip: 47.89.21.165
        user: root
    logical_server:
      web:
        vip: 47.52.55.60
        physical_server:
          - server1
      was:
        physical_server:
          - server1
    software:
      mysql:
        install_type: replication
        deploy_server: db
        service_ip: 47.91.159.62
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
          www.petclinic.kr:
            ports:
              80:
                server_admin: webmaster
                doc_root: /www/petc/htdocs
                log_root: /www/petc/logs/web
                use_modproxy: True
                proxy_pattern:
                  /petclinic : http://localhost:8080
            enable: False
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
