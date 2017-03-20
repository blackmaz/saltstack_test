
{% macro service_restart(service, require='') -%}

restart_{{ service }}:
  module.run:
    - name: service.restart
    - m_name: {{ service }}
  {% if require != '' %}
    - require:
      - {{ require }}
  {% endif %}    

{%- endmacro %}
