# 호스트 파일에 site_config의 물리 서버 IP를 등록한다. 
{%- set company = salt['pillar.get']('company','default') %}
{%- set system  = salt['pillar.get']('system','default') %}
{%- set psvrs = salt['pillar.get'](company+':'+system+':physical server',{}) %}

{%- for id, psvr in psvrs.items() %}
add_host_{{ id }}:
  host.present:
    - name: {{ psvr.hostname }}
    - ip: {{ psvr.ip }}
{%- endfor %}

{%- set lsvrs = salt['pillar.get'](company+':'+system+':logical server',{}) %}

{%- for id, lsvr in lsvrs.items() %}
{%- if lsvr.get('hostname','') != '' and lsvr.get('vip','') != '' %}
add_host_{{ id }}:
  host.present:
    - name: {{ lsvr.hostname }}
    - ip: {{ lsvr.vip }}
{%- endif %}
{%- endfor %}
