nagios_pre_install:
  pkg.installed:
    - pkgs:
      - wget
      - httpd
      - php

add_service_http:
  module.run:
    - name: firewalld.add_service
    - zone: public
    - service: http

reload_rules:
  module.run:
    - name: firewalld.reload_rules

httpd_service_running:
  service.running:
    - name: httpd
    - enable: True

