nginx:
  pkg.installed:
    - name: nginx
  service.running:
    - name: nginx
    - enable: True
    - watch:
      - pkg: nginx
      
add_service_http:
  module.run:
    - name: firewalld.add_service
    - zone: public
    - service: http
    - require:      
      - service: nginx
      
add_port_8080:
  module.run:
    - name: firewalld.add_port
    - zone: public
    - port: 8080/tcp
    - require:
      - service: nginx

reload_firewall_rule:
  module.run:
    - name: firewalld.reload_rules
    - require:
      - module: add_service_http

