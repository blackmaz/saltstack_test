
{% if os == 'Ubuntu' %}
install_mod_jk:
  pkg.installed:
    - name: libapache2-mod-jk

{% endif %}


