{%- import 'common/firewall.sls' as firewall with context %}

{%- if grains['os']=="Ubuntu" %}
mod_ssl:
  cmd.run:
    - name: a2enmod ssl

m2crypto:
  pkg.installed:
    - name: m2crypto
    - require: 
      - cmd: mod_ssl
{%- set req = "pkg: m2crypto" %}
{%- else %}
mod_ssl:
  pkg.installed:
    - name: mod_ssl

python-pip:
  pkg.installed:
    - pkgs:
      - python2-pip
      - gcc
      - python-devel
      - openssl-devel
    - require:
      - pkg: mod_ssl

m2crypto:
  pip.installed:
    - name: m2crypto
    - require:
      - pkg: python-pip
{%- set req = "pip: m2crypto" %}
{%- endif %}

{{ firewall.firewall_open('443', require=req) }}

