# Site Configration
hwbc:
  replica:
    physical_server:
      server1:
        hostname: wrk1
        ip: 172.28.128.31
        eip: 172.28.128.31
        user: de2o
        role: 
          - mysql_master
      server2:
        hostname: wrk2
        ip: 172.28.128.32
        eip: 172.28.128.32
        user: de2o
        role: 
          - mysql_slave
    logical_server:
      db:
        physical_server:
          - server1
          - server2
    software:
      mysql:
        install_type: replication
        deploy_server: db
# A 미사용
        service_ip: ip
        service_port: 3306
#        data_dir:
#        log_dir:
        root:
          pwd: manager365
        databases:
          nest:
            user: nest
            pwd: manager365
        replication:
          id: repl
          pw: 1q2w3e4r
