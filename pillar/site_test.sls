de2o:
  test:
    physical_server:
      server1:
        hostname: test1
        ip: 172.28.128.100
        eip: 172.28.128.100
        user: sungsic
      server2:
        hostname: test2
        ip: 172.28.128.101
        eip: 172.28.128.101
        user: sungsic
    logical_server:
      db:
        physical_server:
          - server1
      web:
        physical-server:
          - server2

