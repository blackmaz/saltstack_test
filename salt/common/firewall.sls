# firewall.sls
{% macro firewall_open(port, prot='tcp', require='') -%}
{%- if grains['os'] == 'CentOS' -%}
firewall-add-port-{{port}}:
  module.run:
    - name: firewalld.add_port
    - zone: public
    - port: {{port}}/{{prot}}
  {% if require != '' %}
    - require:
      - {{require}}
  {% endif %}
firewall-reload-{{port}}:
  module.run:
    - name: firewalld.reload_rules
    - require:
      - module: firewall-add-port-{{port}}
{%- elif grains['os'] == 'Ubuntu' -%}
iptables-add-port-{{port}}:
  iptables.append:
    - table: filter
    - chain: INPUT
    - jump: ACCEPT
    - match: state
    - connstate: NEW
    - dport: {{port}}
    - proto: {{prot}}
    - sport: 1025:65535
    - save: True
  {% if require != '' %}
    - require:
      - {{require}}
  {% endif %}
{%- endif -%}
{%- endmacro %}

{% macro firewall_open_service(service_nm, require='') -%}
{%- if grains['os'] == 'CentOS' -%}
firewall-add-server-{{service_nm}}:
  module.run:
    - name: firewalld.add_service
    - zone: public
    - service: {{service_nm}}
  {% if require != '' %}
    - require:
	  - {{require}}
  {% endif %}
{%- endif -%}
{%- endmacro %}