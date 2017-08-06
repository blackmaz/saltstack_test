de2o:
  hadoop:
    physical_server:
      server1:
        hostname: hdmaster
        ip: 172.28.128.100
        eip: 172.28.128.100
        user: sungsic
        role:
          - hadoop_master
      server2:
        hostname: hdslave1
        ip: 172.28.128.101
        eip: 172.28.128.101
        user: sungsic
        role:
          - hadoop_slave
      server3:
        hostname: hdslave2
        ip: 172.28.128.102
        eip: 172.28.128.102
        user: sungsic
        role:
          - hadoop_slave
      server4:
        hostname: hdslave3
        ip: 172.28.128.103
        eip: 172.28.128.103
        user: sungsic
        role:
          - hadoop_slave
    logical_server:
      hadoop:
        physical_server:
          - server1
          - server2
          - server3
          - server4
    software:
      hadoop:
        deploy_server: hadoop
        jdk: sunjdk
        ntp: 
