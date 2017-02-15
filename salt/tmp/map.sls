{% from "tmp/map.jinja" import apache with context %}

{% for id, site in apache.items() %}
{% set aa = site.get('a', 'a000') %}
{{ aa }}:
  cmd.run:
    - name: id 
{% endfor %}

