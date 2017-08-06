{#
fred:
  user.present:
    - fullname: Fred Jones
    - shell: /bin/zsh
    - home: /home/fred
    - uid: 4000
    - gid: 4000
    - groups:
      - wheel
      - storage
      - games

#}

# user.sls
{%- macro create_user(user, require='') %}
{%- if grains['os_family'] == 'RedHat' %}
{{ user }}:
  user.present:
    - shell: /bin/bash
    - home: /home/{{user}}
{%-   if require != '' %}
    - require:
      - {{require}}
{%-   endif %}
{%- elif grains['os'] == 'Debian' %}
  user.present:
    - shell: /bin/bash
    - home: /home/{{user}}
{%-   if require != '' %}
    - require:
      - {{require}}
{%-   endif %}
{%- endif %}
{%- endmacro %}

