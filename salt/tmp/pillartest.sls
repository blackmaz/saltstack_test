{% set company = salt['pillar.get']('company','') %}
{% set system = salt['pillar.get']('system','') %}
{% set software = salt['pillar.get'](company+':'+system+':software','') %}

{% for id, val in software.items() %}

{{ id }}:
  cmd.run: 
    - name: id 

{% endfor %}
