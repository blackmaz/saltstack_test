{%- import 'common/firewall.sls' as firewall with context %}
{%- from 'postgresql/map.jinja' import postgresql with context %}

# package install
postgresql:
  pkg.installed:
    - pkgs:
      - {{ postgresql.server }}
      - {{ postgresql.client }}
      - {{ postgresql.python }}

# postgresql user password 변경
postgres:
  user.present:
    - password: q1w2e3r4
    - hash_password: True

{%- if grains['os_family'] == "RedHat" %}
# postgresql db init
#    name : db data 생성할 디렉토리
#    auth : db인증방식 password / 
#    user : db super user
#    password : db super user password
#    encoding :
#    locale : 
#    runas : 실행할 os user
db_init:
  postgres_initdb.present:
    - name: /var/lib/pgsql/data
    - auth: password
    - password: q1w2e3r4
    - encoding: UTF8
    - locale: None
    - runas: postgres
    - require:
      - pkg: postgresql
      - user: postgres
{% endif %}

{%- if grains['os_family'] == "Debian" %}
# postgres password
# 현재 os 계정과 연동되어 접속 관리됨...
# 변경하는 방식 추가해야함
set_password:
  postgres_user.present:
    - name: postgres
    - password: q1w2e3r4
{% endif %}

postgresql_service:
  service.running:
    - name: {{ postgresql.service }}
    - enable: True
    - watch:
      - pkg: postgresql

{{ firewall.firewall_open('3306', require='service: postgresql_service') }}



