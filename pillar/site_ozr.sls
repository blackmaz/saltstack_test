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
software:
  mysql:
    deploy server: db
    root_pwd: manager365
    service_ip: server3
    service_port: 3306
    databases:
      nest:
        user: root
        pwd: manager365
        import: True
        data: salt://ozr/ozr_dbdump.sql
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
  tomcat:
    deploy server: web
    jdk: openjdk
    install:
      insthome: /www/nest
      home: /www/nest/apache-tomcat-7.0.75
      java_opts: -server -Xms512m -Xmx512m -XX:PermSize=128m -XX:MaxPermSize=128m -XX:+DisableExplicitGC
    server:
      http_port: 8080
      ajp_port: 8009
      appBase: webapps
      name: www.nestfunding.kr
      Contexts:
        /:
          docBase: ozr
          downloadurl: salt://apps/ozr/ozr.tar.gz
          filename: ozr
          service_ip: server4
          use_database: 
            software: mysql
            database: nest
        test:
          docBase: test
          downloadurl: salt://apps/ozr/ozr.tar.gz
          filename: ozr
          service_ip: server4
          use_database: pandamall
          datasource_url: jdbc:mysql://localhost:3306/nest
          db_user: root
          db_password: manager365


