{%- set company = salt['pillar.get']('company','default') %}
{%- set system = salt['pillar.get']('system','default') %}
{%- set p = salt['pillar.get'](company+':'+system+':software:php',{}) %}

{%- from 'php/map.jinja' import php with context %}
{%- import 'common/service.sls' as service with context %}

include:
  - base.repo
  - php.install

{{ service.service_restart(php.service) }}


