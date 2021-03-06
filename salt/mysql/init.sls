{%- set company = salt['pillar.get']('company','default') %}
{%- set system  = salt['pillar.get']('system','default') %}
{%- set tcfg    = salt['pillar.get'](company+':'+system, {}) %}
{%- set m       = salt['pillar.get'](company+':'+system+':software:mysql',{}) %}
{%- from 'mysql/map.jinja' import mysql with context %}
{%- import 'common/service.sls' as service with context %}

include:
  # 서버 설치
  - mysql.server

  # root password 변경 필요시 호출
{%- if m.get('root','null') != 'null' %}
  - mysql.root
{%- endif %}

  # database 생성 필요 시 호출
{%- if m.get('databases','null') != 'null' %}
  - mysql.databases
{%- endif %}

  # master / slave 구성 필요 시 호출
{%- if m.get('install_type','standalone') == 'replication' %}
{%-   set isMaster = {'val':false} %}
{%-   for psvr in tcfg.get('logical_server').get(m.get('deploy_server')).get('physical_server', []) %}
{%-     for id, info in tcfg.get('physical_server').items() %}
{%-       if info.hostname == salt['grains.get']('host') %}
{%-         if "mysql_master" in info.get('role',[]) %}
{%-           do isMaster.update({'val':true}) %}
{%-         endif %}
{%-       endif %}
{%-     endfor %}
{%-   endfor %}

{%-   if isMaster.val == true %}
  - mysql.master
{%-   else %}
  - mysql.slave
{%-   endif %}

{%- endif %}
