# Site Configration
panda:
  pandamall:

# Physical Server 
    physical_server:
      server1:
        hostname: vm01
        ip: 172.28.128.3
        eip: 172.28.128.3
        user: vagrant
      server2:
        hostname: vm02
        ip: 172.28.128.4
        eip: 172.28.128.4
        user: vagrant
# Logical Server
    logical_server:
      db:
        physical_server:
          - server1
      web:
        physical_server:
          - server2
# Software
    software:
      mysql:
        deploy_server: db
        root:
          pwd: 1q2w3e4r5t
        databases:
          pandamall:
            user: pandamall
            pwd: 1qazxsw2
      apache:
        deploy_server: web
        vhosts:
          www.pandamall.kr:  
            ports: 
              80:  
                server_admin: webmaster
                doc_root: /www/pandamall
                log_root: /logs/pandamall
                use_php: True
                php_ip: 127.0.0.1
                php_port: 9000
            enable: True
        openssl: False
        modphp: True
      php:
        deploy_server: web
        cfg:
          listen_addr: 127.0.0.1
          listen_port: 9000
          allowed_clients: any
