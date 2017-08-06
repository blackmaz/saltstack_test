{%- set company = salt['pillar.get']('company','default') %}
{%- set system = salt['pillar.get']('system','default') %}

{%- set continent = 'Asia' %}
{%- set city = 'Seoul' %}
{%- set timezone = 'KST' %}

time_zone:
  file.symlink:
    - name: /etc/localtime
    - target: /usr/share/zoneinfo/{{ continent }}/{{ city }}
    - target: /usr/share/zoneinfo/{{ timezone }}

