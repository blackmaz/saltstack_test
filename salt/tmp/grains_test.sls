{% if salt['grains.get']('selinux:enabled') == 'False' %}
grains_test:
  cmd.run:
    {% if salt['grains.get']('selinux:enabled') == 'True' %}
    - name : ls -al
    {% else %}
    - name : ps -ef 
    {% endif %}
{% endif %}
