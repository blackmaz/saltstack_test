# firewall.sls
{% macro firewall_open(port, prot='tcp') -%}
{%- if grains['os'] == 'CentOS' -%}
firewall-add-port-{{port}}:
  module.run:
    - name: firewalld.add_port
    - zone: public
    - port: {{port}}/{{prot}}
firewall-reload:
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
{%- endif -%}
{%- endmacro %}

