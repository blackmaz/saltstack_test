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
    - require:
      - pkg: nagios_pre_install

reload_rules:
  module.run:
    - name: firewalld.reload_rules
    - require:
      - module: add_service_http

httpd_service_running:
  service.running:
    - name: httpd
    - enable: True
    - require:
      - pkg: nagios_pre_install
