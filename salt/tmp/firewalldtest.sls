add_port_8080:
  module.run:
    - name: firewalld.add_port
    - zone: public
    - port: 8080/tcp
add_service_http:
  module.run:
    - name: firewalld.add_service
    - zone: public
    - service: http
reload_firewall_rule:
  module.run:
    - name: firewalld.reload_rules
