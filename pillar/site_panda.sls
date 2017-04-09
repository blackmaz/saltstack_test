# Site Configration
panda:
  pandamall:

# Physical Server 
    physical server:
      server1:
        hostname: vm83
        ip: 192.168.10.83
        eip: 192.168.10.83
      server2:
        hostname: vm84
        ip: 192.168.10.84
        eip: 192.168.10.84
# Logical Server
    logical server:
      db:
        physical server:
          - server1
      web:
        physical server:
          - server2
# Software
    software:
      mysql:
        deploy server: db
        root:
          pwd: 1q2w3e4r5t
        databases:
          pandamall:
            user: pandamall
            pwd: 1qazxsw2
      nginx:
        deploy server: web
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
      php:
        deploy server: web
        cfg:
          listen_addr: 127.0.0.1
          listen_port: 9000
          allowed_clients: any


