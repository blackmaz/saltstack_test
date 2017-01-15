{% import 'common/firewall.sls' as firewall with context %}
{% set redis = salt['grains.filter_by'] ({
  'Ubuntu': {
    'server': 'redis-server'
  },
  'CentOS': {
    'server': 'redis'
  },
  'default': 'Ubuntu',
}, grain='os') %}

redis:
  pkg.installed:
    - pkgs:
      - {{ redis.server }}
  service.running:
    - name: redis
    - enable: True
    - watch: 
      - pkg: redis

{{ firewall.firewall_open('6379', require='service: redis') }}

