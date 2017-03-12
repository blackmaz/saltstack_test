{%- import 'common/firewall.sls' as firewall with context %}
{%- from "nginx/map.jinja" import nginx with context %}

{%- if grains['os_family']=="Debian" %}
m2crypto:
  pkg.installed:
    - name: m2crypto
{%- set req = "pkg: m2crypto" %}
{%- elif grains['os_family']=='RedHat' %}
python-pip:
  pkg.installed:
    - pkgs:
      - python2-pip
      - gcc
      - python-devel
      - openssl-devel

m2crypto:
  pip.installed:
    - name: m2crypto
    - require:
      - pkg: python-pip
{%- set req = "pip: m2crypto" %}
{%- endif %}

{{ firewall.firewall_open('443', require=req) }}

