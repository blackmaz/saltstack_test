sp1:
  petclinic:
    physical_server:
      server1:
        hostname: de2o_1
        ip: 47.52.69.255
        eip: 47.52.69.255
        user: root
      server2:
        hostname: de2o_2
        ip: 47.52.21.80
        eip: 47.52.21.80
        user: root
      server3:
        hostname: de2o_3
        ip: 47.91.159.62
        eip: 47.91.159.62
        user: root
        role:
          - mysql_master
        role:
      server4:
        hostname: de2o_4
        ip: 47.91.159.30
        eip: 47.91.159.30
        user: root
        role:
          - mysql_slave
    logical_server:
      web:
        vip: 47.52.55.60
        physical_server:
          - server1
          - server2
      was:
        physical_server:
          - server1
          - server2
      db:
        physical_server:
          - server3
          - server4
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
