{%- set root_pwd = salt['pillar.get']('software:mysql:root_pwd','') %}
{%- set databases = salt['pillar.get']('software:mysql:databases',{}) %}

include:
  - mysql.server
{%- if root_pwd != '' %}
  - mysql.root
{%- endif %}
{%- if databases != {} %}
  - mysql.user
{%- endif %}
