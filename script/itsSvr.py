#!/usr/bin/python
# -*- coding: utf-8 -*-
import salt.client
import yaml
import sys
import getopt
import pprint
from collections import OrderedDict

from itsSitePillar import software

class saltLocal():
    localClient = ''
    def __init__(self):
        self.localClient = salt.client.LocalClient()

    def cmdList(self, hosts, cmd, args):
        # deprecation warning으로 수정-expr_form->tgt_type -> 2016.11 버전으로 원복
        return self.localClient.cmd(hosts, cmd, args, expr_form='list',timeout=1800)
        #print "=======>debug:" + str(hosts) + "|||" + str(cmd) +"|||"+ str(args)
        #return self.localClient.cmd(hosts, cmd, args, tgt_type='list',timeout=1800)

    def cmdSvr(self, host, cmd, args):
        return self.localClient.cmd(host, cmd, args, timeout=1800)

# 로그 출력 함수
def printLog(ret):
    #print ret
    i#return

    for server, server_ret in ret.items():
        for command, command_ret in server_ret.items():
            if type(command_ret) != dict:
                print " ".join(command_ret)
            else:
                prt = {}
                for key, val in command_ret.items():
                    prt[val["__run_num__"]] = "[ "+ str(val.get("result",""))+ " ] " + server + " | " + val.get("__id__","null") + " | " + val.get("comment","")
                for key, val in prt.items():
                    print val

def itsSvr(company_cd, system_cd, swName, install_type="install"):
    runtime_pillar='pillar={"company": "'+company_cd+'", "system": "'+system_cd+'"}'
    sw = software(company_cd, system_cd)
    try:
        hosts = sw.lookupHostBySwName(swName)
    except:
        print "error-lookupHostBySwName"
        return False

    cmd = ['state.apply']
    if (install_type == "uninstall" ):
        swName = swName + ".uninstall"
    args = [[swName, runtime_pillar]]
    print str(hosts) + str(cmd) + str(args)

    s = saltLocal()
    ret = s.cmdList(hosts,cmd,args)

    printLog(ret)

    return True

# 호스트 목록에 대해 pillar를 리프레시 한다.
def itsRefPillar(hosts):
    cmd = ['saltutil.refresh_pillar']
    args = []
    print str(hosts) + str(cmd) + str(args)

    s = saltLocal()
    ret = s.cmdList(hosts,cmd,args)
    printLog(ret)

    return True

swName=''
install_type='install'
company_cd=''
system_cd=''

# 옵션을 주지 않고 실행했을때 도움말 표시후 중단한다.
def help():
    print "itsSvr.py -n swname -c company -s system [-t install|uninstall]"
    return

# 옵션을 파싱해서 글로벌 변수에 담는다.
def option():
    # 함수 밖에서 참조 할수있도록 글로벌로 선언해 준다.
    global swName
    global install_type
    global company_cd
    global system_cd

    if(len(sys.argv) is 1) and ((company_cd == '')):
        help()
        sys.exit(1)
    try:
        options, args =  getopt.getopt(sys.argv[1:], "n:t:c:s:h", ["swname=","install-type=","company=","system=","help"])
    except getopt.GetoptError as err:
        print str(err)
        help()
        sys.exit(1)

    # 옵션에 따라서 변수에 값을 담아준다.
    for opt, arg in options:
        if (opt == '-n') or (opt == '--swname'):
            swName = arg
        elif (opt == '-t') or (opt == '--install-type'):
            install_type = arg
        elif (opt == '-c') or (opt == '--company'):
            company_cd = arg
        elif (opt == '-s') or (opt == '--system'):
            system_cd = arg
        elif (opt == '-h') or (opt == '--help'):
            help()
            sys.exit(1)

    # 필수 항목이 입력되었는지 검사한다.
    if (swName == '' or company_cd == '' or system_cd == ''):
        help()
        sys.exit(1)

    return

if __name__ == "__main__":
    option()
    #print swName
    #print company_cd
    #print system_cd
    #print install_type
    itsSvr(company_cd, system_cd, swName, install_type)
