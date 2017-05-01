#!/usr/bin/python
# -*- coding: utf-8 -*-
import salt.client.ssh.client
import sys
import getopt
import salt.client
import salt.config

# salt-call을 이용해서 local pillar를 조회하기 위해 설정한다.
__opts__ = salt.config.minion_config('/etc/salt/minion')
__opts__['file_client'] = 'local'

ssh_key = ''
company_cd=''
system_cd=''

# 옵션을 주지 않고 실행했을때 도움말 표시후 중단한다.
def help():
    print "itsInit.py -p private key -c company -s system"
    return

def option():
    # 함수 밖에서 참조 할수있도록 글로벌로 선언해 준다.
    global ssh_key
    global company_cd
    global system_cd

    if(len(sys.argv) is 1) and ((company_cd == '')):
        help()
        sys.exit(1)
    try:
        options, args = getopt.getopt(sys.argv[1:], "p:c:s:h", ["priv=","company=","system=","help"])
    except getopt.GetoptError as err:
        print str(err)
        help()
        sys.exit(1)

    # 옵션에 따라서 변수에 값을 담아준다.
    for opt, arg in options:
        if (opt == '-p') or (opt == '--priv'):
            ssh_key = arg
        elif (opt == '-c') or (opt == '--company'):
            company_cd = arg
        elif (opt == '-s') or (opt == '--system'):
            system_cd = arg
        elif (opt == '-h') or (opt == '--help'):
            help()
            sys.exit(1)

    # 필수 항목이 입력되었는지 검사한다.
    if (ssh_key == '' or company_cd == '' or system_cd == ''):
        help()
        sys.exit(1)

    return
    
#ssh_key='/home/ubuntu/aws/test_key_pair'
ssh_key='/home/sungsic/.ssh/id_rsa'
company_cd = "hwbc"
system_cd  = "ozr"

option()

# pillar에 정의된 physical server 정보를 읽어 온다.
caller = salt.client.Caller(mopts=__opts__)
servers = caller.cmd('pillar.get',company_cd+':'+system_cd+':physical server')

# pillar에 정의된 physical server의 hostname을 list에 추가한다.
phySvr = []
for svr_id, svr in servers.items():
    phySvr.append(svr.get("hostname"))

# 대상 host에 ping을 해보고, python이 설치되지 않은 host를 찾아서 raw 명령으로 python을 설치한다.
s = salt.client.ssh.client.SSHClient()
r = s.cmd(phySvr,'test.ping',expr_form='list',ssh_priv=ssh_key,ssh_identities_only=True)
hosts = []
for host in r.keys():
    if r[host]['retcode'] == 10:
        ret = s.cmd(host, 'sudo cat /etc/*release|grep DISTRIB_ID', raw_shell=True, ssh_priv=ssh_key, ssh_identities_only=True)
        if ret[host]['stdout'] == 'DISTRIB_ID=Ubuntu\n':
            hosts.append(host)

ret = s.cmd(hosts, 'sudo apt-get -y install python', expr_form='list', raw_shell=True, ssh_priv=ssh_key, ssh_identities_only=True)

# 대상 host에 ping을 해보고, ping이 성공한 서버에 대해서 salt minion을 설치한다. 
hosts = []
r = s.cmd(phySvr, 'test.ping', expr_form='list', ssh_priv=ssh_key, ssh_identities_only=True)
for host in r.keys():
    if r[host]['retcode'] == 0:
        hosts.append(host)

# pillar에 등록된 서버가 전부 ping에 응답해야지 다음 단계로 넘어간다. 
if phySvr != hosts:
    print "You have a server that is not responding."
    exit()

# pillar에 등록된 hostname과 실제 hostname을 비교해서 서로 다르면 hostname을 변경한다.
r = s.cmd(phySvr,'grains.get', ['host'], expr_form='list', ssh_priv=ssh_key, ssh_identities_only=True)
for host, val in r.items():
    if host != val.get('return'):
        # hostname 변경
        #print 'change hostname'
        ret = s.cmd(host, 'state.apply', ['common.hostname', 'pillar={"hostname": "'+host+'"}'], expr_form='list', ssh_priv=ssh_key, ssh_identities_only=True)
        #print ret[host]['retcode']

#print '------------------'
#exit()
#print '------------------'
# minion 설치 전에 동일한 id로 등록된 key가 있는지 확인하고, 중복되면 삭제한다.
# 동일한 key가 존재하면 dup이 나서 deny로 빠지게 된다.
import salt.config
import salt.wheel
o = salt.config.master_config('/etc/salt/master')
w = salt.wheel.WheelClient(o)

for host in phySvr:
    r = w.cmd('key.name_match',[host])
    #print r
    if len(r) > 0 :
        a = w.cmd('key.delete',[host])

#exit()

# pillar에 등록된 서버에 salt-minion을 설치한다. 
ret = s.cmd(hosts, 'state.apply', ['salt.minion'], expr_form='list', ssh_priv=ssh_key, ssh_identities_only=True)

# minion key를 master에 등록한다.
for host in phySvr:
    #print host
    r = w.cmd('key.name_match',[host])
    #print r
    if len(r) == 1 :
        if r.keys()[0] == 'minions_pre':
            # key를 accept 한다.
            a = w.cmd('key.accept',[host])
        elif r.keys()[0] == 'minions':
            print "Already accepted key. (" + host + ")"
    elif len(r) == 0 :
        print "Not install salt-minion (" + host + ")"
    else:
        print "Error. (" + host + ")"

#m = w.cmd('key.list',['all'])
#if len(m['minions_pre']) > 0:
#    for host in m['minions_pre']:
#        w.cmd('key.accept',[host])
