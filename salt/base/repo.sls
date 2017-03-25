{%- if grains['os_family'] == 'RedHat'-%}
install_epel:
  pkg.installed:
    - name: epel-release

install_remi_repo:
  cmd.run:
    - name: rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm
    - require:
      - pkg: install_epel
{%- endif %}

{%- if salt['grains.get']('selinux:enabled') == True %}
install_policycoreutils:
  pkg.installed:
    - name: policycoreutils-python
{%- endif %}
