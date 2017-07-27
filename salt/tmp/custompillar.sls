
{%- set company = salt['pillar.get']('company','default') %}
{%- set system  = salt['pillar.get']('system','default') %}

test_pillar:
  cmd.run:
    - name: ls -l {{ company }}

test_pillar_2:
  cmd.run:
    - name: ls -l {{ system }}
