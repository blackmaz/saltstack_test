{%- set a = salt['pillar.get']('software:apache', {}) %}
{%- from 'apache/map.jinja' import apache with context %}

include:
  - apache.install
{%- if a.get('vhosts') != {} %}
  - apache.vhost
{%- endif %}
{%- if a.get('modjk') != {} %}
  - apache.modjk
{%- endif %}
{%- if a.get('openssl') == True %}
  - apache.openssl
  - apache.pkikey
{%- endif %}

restart_{{ apache.service }}:
  module.run:
    - name: service.restart
    - m_name: {{ apache.service }}
