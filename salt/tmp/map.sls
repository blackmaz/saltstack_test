{% set aa = salt['pillar.get']('kkk','a1') %}
{{ aa }}:
  cmd.run:
    - name: id 

