{%- import 'common/firewall.sls' as firewall with context %}
{%- from "apache/map.jinja" import apache with context %}

{%- if grains['os_family']=="Debian" %}
mod_ssl:
  cmd.run:
    - name: a2enmod ssl

{%- set req = "cmd: mod_ssl" %}
{%- elif grains['os_family']=='RedHat' %}
mod_ssl:
  pkg.installed:
    - name: mod_ssl

{%- set req = "pkg: mod_ssl" %}
{%- endif %}

{{ firewall.firewall_open('443', require=req) }}

/etc/pki:
  file.directory: []

/etc/pki/www.key:
  x509.private_key_managed:
    - bits: 4096
    - backup: True
    - require:
      - file: /etc/pki

/etc/pki/www.crt:
  x509.certificate_managed:
    - signing_private_key: /etc/pki/www.key
    - CN: ca.example.com
    - C: KR
    - ST: Seoul
    - L: Jung-gu
    - basicConstraints: "critical CA:true"
    - keyUsage: "critical cRLSign, keyCertSign"
    - subjectKeyIdentifier: hash
    - authorityKeyIdentifier: keyid,issuer:always
    - days_valid: 3650
    - days_remaining: 0
    - backup: True
    - require:
      - x509: /etc/pki/www.key

