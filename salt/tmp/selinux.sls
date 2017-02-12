install_policycoreutils:
  pkg.installed:
    - name: policycoreutils-python

selinux_data_haw:
  module.run:
    - name: selinux.setsebool
    - boolean: httpd_anon_write 
    - value: On
    - persist: True

selinux_data_hssaw:
  module.run:
    - name: selinux.setsebool
    - boolean: httpd_sys_script_anon_write 
    - value: On
    - persist: True
