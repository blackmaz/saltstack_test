# Site Configration
hwbc:
  ozr:
    physical_server:
      server1:
        hostname: hwbcdb01
        ip: 172.28.128.83
        eip: 172.28.128.83
        user: ubuntu
        role: 
          - mysql_master
      server2:
        hostname: hwbcwb01
        ip: 172.28.128.84
        eip: 172.28.128.84
        user: ubuntu
      server3:
        hostname: hwbcdb02
        ip: 172.28.128.93
        eip: 172.28.128.93
        user: ubuntu
        role: 
          - mysql_slave
      server4:
        hostname: hwbcwb02
        ip: 172.28.128.94
        eip: 172.28.128.94
        user: ubuntu
    logical_server:
      db:
        hostname: hwbcdb
        physical_server:
          - server1
          - server3
      web:
        hostname: hwbcwb
        vip: 172.28.128.74
        physical-server:
          - server2
          - server4
    software:
      mysql:
        deploy_server: db
        install_type: master/slave
        # A 미사용
        service_ip: ip
        service_port: 3306
        root:
          pwd: manager365
        databases:
          nest:
            user: root
            pwd: manager365
        replication:
          id: repl
          pw: 1q2w3e4r
      apache:
        deploy_server: web
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
                redirect_to: http://www.ozr.kr/
            enable: True
          ozr.kr:
            ports:
              80:
                use_redir: True
                redirect_from: /
                redirect_to: http://www.ozr.kr/
              443:
                use_redir: True
                redirect_from: /
                redirect_to: http://www.ozr.kr/
            enable: True
          www.ozr.kr:
            ports:
              80:
                server_admin: webmaster
                doc_root: /www/nest/htdocs
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
              host: 172.28.128.74
            worker2:
              port: 8009
              host: 172.28.128.74
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
        deploy_server: web
        jdk: openjdk
        install:
          insthome: /www/nest
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
    apps:
      ozr:
        source:
          s3:
            keyid: changeme-1
            key: changeme-2
            region: ap-northeast-2
            bucket: itsbox
            filepath: apps/ozr
            filename: webapps_ozr.zip
        target:
          tomcat:
            home: /www/nest/
            appBase: webapps
            docBase: ROOT
        tmp: /tmp
