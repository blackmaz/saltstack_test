import salt.client.ssh.client

s = salt.client.ssh.client.SSHClient()
r = s.cmd('*','test.ping')
for host in r.keys():
  if r[host]['retcode'] == 10:
    ret = s.cmd(host, 'sudo cat /etc/*release|grep DISTRIB_ID',raw_shell=True)
    if ret[host]['stdout'] == 'DISTRIB_ID=Ubuntu\n':
      ret = s.cmd(host,'sudo apt-get -y install python', raw_shell=True)

r = s.cmd('*','test.ping')
for host in r.keys():
  if r[host]['retcode'] == 0:
    ret = s.cmd(host,'state.apply',['salt_minion'])

import salt.config
import salt.wheel
o = salt.config.master_config('/etc/salt/master')
w = salt.wheel.WheelClient(o)

m = w.cmd('key.list',['all'])
w.cmd('key.accept',m['minions_pre'])
