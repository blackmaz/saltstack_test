#!/usr/bin/python
# -*- coding: utf-8 -*-
import salt.client.ssh.client
import sys
import getopt
import salt.client
import salt.config
import salt.wheel
from operator import xor

from itsSitePillar import physicalServer

# salt ssh를 사용하기 위한 클래스
class saltSSH:
    sshClient = ''

    def __init__(self):
        self.sshClient = salt.client.ssh.client.SSHClient()

    # 패스워드 인증인지 ssh key 인증인지 구분해서 salt-ssh를 수행, 서버 리스트에 명령을 전달할 때 사용
    # p : 패스워드 인증 , k : ssh key 인증
    # 패스워드인증일 경우 authStr에 패스워드를 key 인증일 경우 key의 경로를 넘긴다.
    def cmdListByAuthType(self, hosts, cmd, authType, authStr, argList=[], rawType=False ):
        if authType == 'k':
            return self.cmdList(hosts, cmd, args=argList, passwd='', priv=authStr, raw=rawType)
        elif authType == 'p':
            return self.cmdList(hosts, cmd, args=argList, passwd=authStr, priv='', raw=rawType)
        else:
            # 모르는 구분자가 들어오는 경우 에러처리 한다. 
            return Null

    # host를 list에 담아서 동일한 명령을 여러개의 호스트에 전달할때 사용함
    def cmdList(self, hosts, cmd, args=[], passwd='', priv='', raw=False):
        if passwd != '':
            return self.sshClient.cmd(hosts, cmd, args, expr_form='list', raw_shell=raw, ssh_passwd=passwd)
        elif priv != '':
            return self.sshClient.cmd(hosts, cmd, args, expr_form='list', raw_shell=raw, ssh_priv=priv)
        else:
            return self.sshClient.cmd(hosts, cmd, args, expr_form='list', raw_shell=raw)

    # 패스워드 인증인지 ssh key 인증인지 구분해서 salt-ssh를 수행, 1개의 서버에 명령을 전달할때 사용
    # p : 패스워드 인증 , k : ssh key 인증
    # 패스워드인증일 경우 authStr에 패스워드를 key 인증일 경우 key의 경로를 넘긴다.
    def cmdSvrByAuthType(self, host, cmd, authType, authStr, argList=[], rawType=False ):
        if authType == 'k':
            return self.cmdSvr(host, cmd, args=argList, passwd='', priv=authStr, raw=rawType)
        elif authType == 'p':
            return self.cmdSvr(host, cmd, args=argList, passwd=authStr, priv='', raw=rawType)
        else:
            # 모르는 구분자가 들어오는 경우 에러처리 한다. 
            return Null

    # host를 str변수에 담아서 1개의 서버에 1개의 명령을 전달할때 사용함 
    def cmdSvr(self, host, cmd, args=[], passwd='', priv='', raw=False):
        if passwd != '':
            return self.sshClient.cmd(host, cmd, args, raw_shell=raw, ssh_passwd=passwd)
        elif priv != '':
            return self.sshClient.cmd(host, cmd, args, raw_shell=raw, ssh_priv=priv)
        else:
            return self.sshClient.cmd(host, cmd, args, raw_shell=raw)

    # Ping 결과를 정상/파이선미설치/응답없음으로 구분하여 리턴함
    def pingCheckHosts(self, phySvrs, authType, authStr):
        pingResult = {'Alive': [], 'NotReady': [], 'Die': []}
        r = self.cmdListByAuthType(phySvrs, 'test.ping', authType, authStr)

        for host in r.keys():
            if r[host]['retcode'] == 0:
                pingResult['Alive'].append(host)
            elif r[host]['retcode'] == 10:
                pingResult['NotReady'].append(host)
            elif r[host]['retcode'] == 255:
                pingResult['Die'].append(host)

        print pingResult
        return pingResult

    # 호스트의 응답여부를 확인한다.
    def checkHosts(self, phySvrs, authType, authStr):
        r = self.pingCheckHosts(phySvrs, authType, authStr)
        aliveHosts = r['Alive']
        phySvrs.sort()
        aliveHosts.sort()
        if phySvrs == aliveHosts:
            return True
        else:
            return False

    # 서버에 python이 설치되어 있는지 여부를 확인하고 미 설치 서버를 대상으로 설치한다. 
    def pythonInst(self, phySvrs, authType, authStr):
        ret = []
        hostsNoPy = {'ubuntu': [], 'centos': [], 'unknown': []}
        pyInstCmd = {'ubuntu': 'sudo apt-get -y install python', 'centos': 'who', 'unknown': 'who'}
        r = self.pingCheckHosts(phySvrs, authType, authStr)
        notReadyHosts = r['NotReady']

        if len(notReadyHosts) == 0:
            return ret

#        print "not ready hosts :" + str(notReadyHosts)
        for host in notReadyHosts:
            linuxRel = self.cmdSvrByAuthType(host, 'sudo cat /etc/*release|grep ^ID\=', authType, authStr, rawType=True)
            if linuxRel[host]['stdout'].find('ubuntu') >= 0: 
                hostsNoPy['ubuntu'].append(host)
            elif linuxRel[host]['stdout'].find('centos') >= 0: 
                hostsNoPy['centos'].append(host)
            else:
                hostsNoPy['unknown'].append(host)

#        print "hosts not install python :" + str(hostsNoPy)
        for os, hostList in hostsNoPy.items():
            if len(hostList) > 0:
                self.cmdListByAuthType(hostList, pyInstCmd[os], authType, authStr, rawType=True)
                ret = ret + hostList

        return ret

    # 서버의 hostname과 pillar에 등록된 서버명이 다른 경우에 hostname을 변경한다.
    def changeHostname(self, phySvrs, authType, authStr):
        ret = []
        r = self.cmdListByAuthType(phySvrs, 'grains.get', authType, authStr, argList=['host'])

        for phySvr, host in r.items():
            if phySvr != host.get('return'):
                args = ['salt.hostname', 'pillar={"hostname": "'+ phySvr +'"}']
                self.cmdSvrByAuthType(phySvr, 'state.apply', authType, authStr, argList=args )
                ret.append(phySvr)

        return ret

#salt key를 관리하기 위한 클래스
class saltKEY:
    w = ''
    def __init__(self):
        o = salt.config.master_config('/etc/salt/master')
        self.w = salt.wheel.WheelClient(o)

    def deleteKey(self, hostName):
        if self.matchKey(hostName):
            ret = self.w.cmd('key.delete',[hostName])
            return True
        else:
            return False

    def acceptKey(self, hostName):
        if self.matchKey(hostName):
            ret = self.w.cmd('key.accept',[hostName])
            if len(ret) == 0:
                return False
            else:
                return True
        else:
            return False

    def matchKey(self, hostName):
        ret = self.w.cmd('key.name_match',[hostName])
        if len(ret) == 0:
            return False
        else:
            return True

    def deleteKeyList(self, hostList):
        ret = {}
        for host in hostList:
            ret[host] = self.deleteKey(host)
        return ret

    def acceptKeyList(self, hostList):
        ret = {}
        for host in hostList:
            ret[host] = self.acceptKey(host)
        return ret

def itsInit(company_cd, system_cd, authType, authStr):
    # pillar에 정의된 physical server 정보를 읽어 온다.
    p = physicalServer(company_cd, system_cd)
    # pillar에 정의된 physical server의 hostname을 list에 추가한다.
    phySvrs = p.listHostName()

    print "Get physical server list" + str(phySvrs)
    # physical server가 정의되어 있지 않으면 중단한다.
    if not(phySvrs):
        print "[Error] Undefine physical server list"
        return False

    # 대상 host에 ping을 해보고, python이 설치되지 않은 host를 찾아서 raw 명령으로 python을 설치한다.
    # ubuntu는 설치시 python이 기본적으로 설치되어 있지 않음, centos는 설치 되어 있음.
    s = saltSSH()
    ret = s.pythonInst(phySvrs, authType, authStr)
    print "Install python" + str(ret)

    # pillar에 등록된 hostname과 실제 hostname을 비교해서 서로 다르면 hostname을 변경한다.
    ret = s.changeHostname(phySvrs, authType, authStr)
    print "Change Hostname " + str(ret)

    # physical server가 모두 응답하지 않으면 중단한다. 
    if not(s.checkHosts(phySvrs, authType, authStr)):
        print "[Error] Not Respose physical server"
        return False

    # minion 설치 전에 동일한 id로 등록된 key가 있는지 확인하고, 중복되면 삭제한다.
    # 동일한 key가 존재하면 dup이 나서 deny로 빠지게 된다.
    k = saltKEY()
    k.deleteKeyList(phySvrs)

    # pillar에 등록된 서버에 salt-minion을 설치한다.
    args=['salt.minion']
    ret = s.cmdListByAuthType(phySvrs, 'state.apply', authType, authStr, argList=args)
    print "Install Minion"

    # 미니언 설치된 서버에 host 파일에 서버를 등록한다. 
    args=['salt.addhost', 'pillar={"company": "'+company_cd+'", "system": "'+system_cd+'"}']
    ret = s.cmdListByAuthType(phySvrs, 'state.apply', authType, authStr, argList=args)
    print "Regist hosts"

    # minion key를 master에 등록한다.
    k.acceptKeyList(phySvrs)

    return True

ssh_key = ''
ssh_pwd = ''
company_cd = ''
system_cd = ''

# 옵션을 주지 않고 실행했을때 도움말 표시후 중단한다.
def help():
    print "itsInit.py [-p passwd | -k sshkey] -c company -s system"
    return

def option():
    # 함수 밖에서 참조 할수있도록 글로벌로 선언해 준다.
    global ssh_key
    global ssh_pwd
    global company_cd
    global system_cd

    if(len(sys.argv) is 1) and ((company_cd == '')):
        help()
        sys.exit(1)
    try:
        options, args = getopt.getopt(sys.argv[1:], "p:k:c:s:h", ["passwd=","sshkey=","company=","system=","help"])
    except getopt.GetoptError as err:
        print str(err)
        help()
        sys.exit(1)

    # 옵션에 따라서 변수에 값을 담아준다.
    for opt, arg in options:
        if (opt == '-p') or (opt == '--passwd'):
            ssh_pwd = arg
        elif (opt == '-k') or (opt == '--sshkey'):
            ssh_key = arg
        elif (opt == '-c') or (opt == '--company'):
            company_cd = arg
        elif (opt == '-s') or (opt == '--system'):
            system_cd = arg
        elif (opt == '-h') or (opt == '--help'):
            help()
            sys.exit(1)

    # 필수 항목이 입력되었는지 검사한다.
    if (not(xor(bool(ssh_pwd == ''), bool(ssh_key == ''))) or company_cd == '' or system_cd == ''):
        help()
        sys.exit(1)

    return

if __name__ == "__main__":
    option()

    if ssh_key != '':
        authType = 'k'
        authStr = ssh_key
    elif ssh_pwd != '':
        authType = 'p'
        authStr = ssh_pwd
    else:
        help()
        sys.exit(1)

    itsInit(company_cd, system_cd, authType, authStr)


#ssh_key='/home/ubuntu/aws/test_key_pair'
#ssh_key='/home/sungsic/.ssh/id_rsa'
#authType = 'p'
#authStr='ehrtnfl5'
#company_cd = "hwbc"
#system_cd  = "ozr"

