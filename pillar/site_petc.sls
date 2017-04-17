sample:
  petclinic:
    physical server:
      server1:
        hostname: ip-10-20-0-225
        ip: 13.112.153.34
        eip: 13.112.153.34
    logical server:
      db:
        physical server:
          - server1
      web:
        physical server:
          - server1
      was:
        physical server:
          - server1
    software:
      mysql:
        deploy server: db
        service_ip: server1
        service_port: 3306
        root:
          pwd: manager365
        databases:
          petclinic:
            user: petclinic
            pwd: 1q2w3e

