{%- set a = salt['pillar.get']('software:nginx', {}) %}
{%- from 'nginx/map.jinja' import nginx with context %}

include:
  - nginx.install
{%- if a.get('vhosts') != {} %}
  - nginx.vhost
{%- endif %}
#{%- if a.get('modjk') != {} %}
#  - nginx.modjk
#{%- endif %}
{%- if a.get('openssl') == True %}
  - nginx.openssl
  - nginx.pkikey
{%- endif %}

restart_{{ nginx.service }}:
  module.run:
    - name: service.restart
    - m_name: {{ nginx.service }}
