{% import 'common/firewall.sls' as firewall with context %}
{% set os = grains['os'] %}

nginx:
  pkg.installed:
    - name: nginx
  service.running:
    - name: nginx
    - enable: True
    - watch:
      - pkg: nginx

{{ firewall.firewall_open('80', require='service: nginx') }}

/etc/nginx/nginx.conf:
  file.managed:
    - source: salt://nginx/nginx.conf.{{ os }}
    - require:
      - pkg: nginx

/etc/nginx/sites-available:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 755
    - require:
      - pkg: nginx

/etc/nginx/sites-enabled:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 755
    - require:
      - pkg: nginx

/etc/nginx/sites-available/default:
  file.managed:
    - source: salt://nginx/default.{{ os }}
    - require:
      - file: /etc/nginx/sites-available

/etc/nginx/sites-enabled/default:
  file.symlink:
    - target: /etc/nginx/sites-available/default
    - require:
      - file: /etc/nginx/sites-enabled
