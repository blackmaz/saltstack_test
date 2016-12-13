redis:
  pkg.installed:
    - pkgs:
      - redis
  service.running:
    - name: redis
    - enable: True
    - watch: 
      - pkg: redis

 add_port_6379:
   module.run:
     - name: firewalld.add_port
     - zone: public
     - port: 6379/tcp
     - require:
       - service: redis
       
 reload_firewall_rule:
   module.run:
     - name: firewalld.reload_rules
     - require:
         - module: add_port_6379
         
