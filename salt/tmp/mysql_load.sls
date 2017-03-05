{%- if database.get('import',False) %}
dmpfile_dn_{{ id }}:
  file.managed:
    - name: /tmp/dbdump_{{id}}.sql
    - source: {{ database.data }} 
    - user: root
    - group: root
    - mode: 644

dmpfile_imp_{{ id }}:
  cmd.run:
    - name: mysql -u root -p'{{ root_pwd|replace("'", "'\"'\"'") }}' < /tmp/dbdump_{{id}}.sql
    - require:
      - file: dmpfile_dn_{{ id }}
{%- endif %}
