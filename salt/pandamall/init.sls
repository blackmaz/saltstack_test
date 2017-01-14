php_gd:
  pkg.installed:
    - name: php56-php-gd
  
/www_root:
  archive.extracted:
    - name: /www_root
    - source: salt://pandamall/pandamall.tar.gz
    - skip_verify: True
    - require:
      - pkg: php_gd

/etc/nginx/conf.d/pandamall.com.conf:
  file.managed:
    - source: salt://pandamall/pandamall.com.conf
    - require:
      - archive: /www_root

nginx_restart_panda:
  service.running:
    - name: nginx
    - watch:
      - file: /etc/nginx/conf.d/pandamall.com.conf

fpm_restart_panda:
  service.running:
    - name: php56-php-fpm
    - watch:
      - pkg: php_gd
      - file: /etc/nginx/conf.d/pandamall.com.conf

{% if salt['grains.get']('selinux:enabled') == True %}
selinux_http_context:
  cmd.run:
    - name: chcon -R -t httpd_sys_content_t /www_root/pandamall
    - require:
      - archive: /www_root

selinux_data_context:
  cmd.run:
    - name: chcon -R -t public_content_rw_t /www_root/pandamall/data
    - require:
      - archive: /www_root

selinux_data_haw:
  module.run:
    - name: selinux.setsebool
    - boolean: httpd_anon_write 
    - value: On
    - persist: True
    - require:
      - cmd: selinux_data_context

selinux_data_hssaw:
  module.run:
    - name: selinux.setsebool
    - boolean: httpd_sys_script_anon_write 
    - value: On
    - persist: True
    - require:
      - cmd: selinux_data_context
{% endif %}

/www_root/pandamall/data:
  file.directory:
    - mode: 777
    - require:
      - archive: /www_root
