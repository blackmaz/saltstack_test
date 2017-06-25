{%- set company = salt['pillar.get']('company','default') %}
{%- set system     = salt['pillar.get']('system','default') %}
{%- from 'mysql/map.jinja' import mysql with context %}
{%- set m = salt['pillar.get'](company+':'+system, {}) %}
{%- set cfg = {
      'root_pwd'    : salt['pillar.get'](company+':'+system+':software:mysql:root:pwd','')
    , 'rid'         : salt['pillar.get'](company+':'+system+':software:mysql:replication:id','')
    , 'rpw'         : salt['pillar.get'](company+':'+system+':software:mysql:replication:pw','')
    , 'port'        : salt['pillar.get'](company+':'+system+':software:mysql:service_port','3306')
    , 'iptype'      : salt['pillar.get'](company+':'+system+':software:mysql:service_ip','ip')
} %}
{%- set mip = {'val':''} %}
{%- set dsvr = m.get('software').get('mysql').get('deploy_server','') %}
{%- for psvr in m.get('logical_server').get(dsvr).get('physical_server',[]) %}
{%- if "mysql_master" in m.get('physical_server').get(psvr).get('role',[]) %}
{%- do mip.update({'val':m.get('physical_server').get(psvr).get(cfg.iptype)}) %}
{%- endif %}
{%- endfor %}
{%- set mst = salt['mysql.get_master_status'](connection_pass=cfg.rpw,connection_user=cfg.rid,connection_host=mip.val) %}
CHANGE MASTER TO MASTER_HOST='{{mip.val}}'
     , MASTER_USER='{{cfg.rid}}'
     , MASTER_PORT={{cfg.port}}
     , MASTER_PASSWORD='{{cfg.rpw}}'
     , MASTER_LOG_FILE='{{mst.File}}'
     , MASTER_LOG_POS={{mst.Position}}
;
start slave;

