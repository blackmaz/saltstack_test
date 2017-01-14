{% import 'common/firewall.sls' as firewall with context %}

redis:
  pkg.installed:
    - pkgs:
      - redis
  service.running:
    - name: redis
    - enable: True
    - watch: 
      - pkg: redis

{{ firewall.firewall_open('6379', require='service: redis') }}

