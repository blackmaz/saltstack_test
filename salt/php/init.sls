{%- set company = salt['pillar.get']('company','default') %}
{%- set system = salt['pillar.get']('system','default') %}
{%- set p = salt['pillar.get'](company+':'+system+':software:php',{}) %}

{%- from 'php/map.jinja' import php with context %}
{%- import 'common/service.sls' as service with context %}

include:
  - base.repo
  - php.install

{{ service.service_restart(php.service) }}

# restart webserver를 해줘야 정상 동작함
# 어떤 web서버와 연관있는지 설정에서 표현해줘야 함

