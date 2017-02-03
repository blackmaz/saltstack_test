{% import 'common/firewall.sls' as firewall with context %}

nagios_pre_install:
  pkg.installed:
    - pkgs:
      - wget
      - httpd
      - php

{{ firewall.firewall_open('80', require='pkg: nagios_pre_install') }}

httpd_service_running:
  service.running:
    - name: httpd
    - enable: True
    - require:
      - pkg: nagios_pre_install
