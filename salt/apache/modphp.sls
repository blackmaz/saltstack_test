{%- from "apache/map.jinja" import apache with context %}

{%- if grains['os_family']=="Debian" %}
mod_php:
  pkg.installed:
    - name: libapache2-mod-php7.0
{%- endif %}

