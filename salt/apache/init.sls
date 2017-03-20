{%- set a = salt['pillar.get']('software:apache', {}) %}
{%- from 'apache/map.jinja' import apache with context %}
{%- import 'common/service.sls' as service with context %}

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
{%- endif %}

{{ service.service_restart(apache.service) }}


