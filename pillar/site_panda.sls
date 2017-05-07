# Site Configration
panda:
  pandamall:

# Physical Server 
    physical server:
      server1:
        hostname: pandadb02
        ip: 192.168.10.83
        eip: 192.168.10.83
        user: sungsic
      server2:
        hostname: pandaweb02
        ip: 192.168.10.84
        eip: 192.168.10.84
        user: sungsic
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
      apache:
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
        modphp: True
      php:
        deploy server: web
        cfg:
          listen_addr: 127.0.0.1
          listen_port: 9000
          allowed_clients: any


