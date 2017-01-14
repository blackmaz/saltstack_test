{% import 'common/firewall.sls' as firewall with context %}

nginx:
  pkg.installed:
    - name: nginx
  service.running:
    - name: nginx
    - enable: True
    - watch:
      - pkg: nginx

{{ firewall.firewall_open('80', require='service: nginx') }}
{{ firewall.firewall_open('8080', require='service: nginx') }}
      
