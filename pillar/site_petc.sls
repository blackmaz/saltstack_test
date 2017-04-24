sample:
  petclinic:
    physical server:
      server1:
        hostname: vm93
        ip: 192.168.10.93
        eip: 192.168.10.93
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
      tomcat:
        deploy server: web
        jdk: openjdk
        install:
          insthome: /www/petclinic
          home: /www/petclinic/apache-tomcat-7.0.77
          java_opts: -server -Xms512m -Xmx512m -XX:PermSize=128m -XX:MaxPermSize=128m -XX:+DisableExplicitGC
        server:
          http_port: 8080
          ajp_port: 8009
          appBase: webapps
          name: petclinic
          Contexts:
            /:
              docBase: petclinic
            test:
              docBase: test
    apps:
      petclinic:
        source:
          s3: 
            keyid: xxxx 
            key: yyyy
            region: ap-northeast-1
            bucket: my-bucket-for-fileserver
            filename: petclinic.war
        target:
          tomcat:
            home: /www/petclinic/apache-tomcat-7.0.77
            appBase: webapps
            docBase: petclinic
        tmp: /tmp  

