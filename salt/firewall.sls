# firewall.sls
{% macro firewall_open(port, prot='tcp') -%}
{%- if grains['os'] == 'CentOS' -%}
firewall-add-port-{{port}}:
  module.run:
    - name: firewall.add_port
    - zone: public
    - port: {{port}}/{{prot}}
{%- elif grains['os'] == 'Ubuntu' -%}
python-virtualenv:
  cmd.run:
    - name: python-{{ pkg }}
{%- endif -%}
{%- endmacro %}

