php_gd:
  pkg.installed:
    - name: php56-php-gd
  
/www_root:
  file.recurse:
    - source: salt://pandamall/application
    - include_empty: True
    - require:
      - pkg: php_gd

/etc/nginx/conf.d/pandamall.com.conf:
  file.managed:
    - source: salt://pandamall/pandamall.com.conf
    - require:
      - file: /www_root

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

selinux_http_context:
  cmd.run:
    - name: chcon -R -t httpd_sys_content_t /www_root
    - require:
      - file: /www_root

selinux_data_context:
  cmd.run:
    - name: chcon -R -t public_content_rw_t /www_root/data
    - require:
      - file: /www_root

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

/www_root/data:
  file.directory:
    - mode: 777
    - require:
      - file: /www_root
