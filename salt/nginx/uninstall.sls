{%- import 'common/firewall.sls' as firewall with context %}
{%- from 'nginx/map.jinja' import nginx with context %}
{%- set os = grains['os'] %}
{%- set selinux_enabled = salt['grains.get']('selinux:enabled') %}

nginx:
  service.dead:
    - enable: true
  pkg.purged:
    - name: {{ nginx.server }}
