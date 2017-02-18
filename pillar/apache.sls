workers:
  worker: 
    worker1: 
      port: 8009
      host: localhost
    worker2: 
      port: 9009
      host: localhost 
  lb: 
    loadbalancer: 
      balance_workers: 
        - worker1
        - worker2 
  list: 
    - loadbalancer
sites:
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
          /*.go: worker2
    enable: True
