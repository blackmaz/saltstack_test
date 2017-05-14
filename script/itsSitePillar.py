#!/usr/bin/python
# -*- coding: utf-8 -*-
import salt.client

# pillar에 정의된 physicalServer 정보를 읽는 클래스
class physicalServer:
    pSvrDic = {}

    def __init__(self, company_cd, system_cd):
        # salt-call을 이용해서 local pillar를 조회하기 위해 설정한다.
        __opts__ = salt.config.minion_config('/etc/salt/minion')
        __opts__['file_client'] = 'local'
        caller = salt.client.Caller(mopts=__opts__)
        self.pSvrDic = caller.cmd('pillar.get', company_cd+':'+system_cd+':physical server')
        if not (self.pSvrDic):
            self.pSvrDic = {}

    # 호스트 명의 리스트를 리턴
    def listHostName(self):
        ret = []
        try:
            for svr_id, svr in self.pSvrDic.items():
                ret.append(svr.get("hostname"))
            return ret
        except:
            return ret
    # IP의 리스트를 리턴
    def listIp(self):
        ret = []
        try:
            for svr_id, svr in self.pSvrDic.items():
                ret.append(svr.get("ip"))
            return ret
        except:
            return ret
    # Roster 파일 형태의 Dic을 리턴
    def listRoster(self):
        ret = {}
        for svr_id, svr in self.pSvrDic.items():
            hostname = svr.get("hostname")
            host = svr.get("ip")
            user = svr.get("user","root")
            if user != "root":
                sudo = True
            else:
                sudo = False
            ret[hostname] = {"host": host, "user": user, "sudo": sudo}
        return ret
    # IP로 호스트명을 찾아서 리턴(구현예정)
    def lookupHostByIp(self, ip):
        return "null"
    # 호스트명으로 IP를 찾아서 리턴(구현예정)
    def lookupIpByHost(self, hostname):
        return "null"
    # 서버id로 호스트명을 찾아서 리턴
    def lookupHostById(self, id):
        return self.pSvrDic[id]['hostname']
    # 서버id 리스트를 받아서 호스트명 리스트를 리턴
    def lookupHostsByIds(self, ids):
        ret = []
        for id in ids:
            ret.append(self.lookupHostById(id))
        return ret

class logicalServer:
    lSvrDic = {}
    p = ''

    def __init__(self, company_cd, system_cd):
        # salt-call을 이용해서 local pillar를 조회하기 위해 설정한다.
        __opts__ = salt.config.minion_config('/etc/salt/minion')
        __opts__['file_client'] = 'local'
        caller = salt.client.Caller(mopts=__opts__)
        self.lSvrDic = caller.cmd('pillar.get', company_cd+':'+system_cd+':logical server')
        if not (self.lSvrDic):
            self.lSvrDic = {}
        self.p = physicalServer(company_cd, system_cd)

    def lookUpPSvr(self, lSvr):
        return self.lSvrDic[lSvr]['physical server']
    def lookUpHost(self, lSvr):
        return self.ids2hosts(self.lookUpPSvr(lSvr))
    def ids2hosts(self, ids):
        return self.p.lookupHostsByIds(ids)

class software:
    sw = {}
    l = ''

    def __init__(self, company_cd, system_cd):
        # salt-call을 이용해서 local pillar를 조회하기 위해 설정한다.
        __opts__ = salt.config.minion_config('/etc/salt/minion')
        __opts__['file_client'] = 'local'
        caller = salt.client.Caller(mopts=__opts__)
        self.sw = caller.cmd('pillar.get', company_cd+':'+system_cd+':software')
        if not (self.sw):
            self.sw = {}
        self.l = logicalServer(company_cd, system_cd)

    def lookupLSvr(self, swName):
        return self.sw[swName]['deploy server']

    def lookupPSvrByLSvr(self, lSvr):
        return self.l.lookUpPSvr(lSvr)
    def lookupPSvrBySwName(self, swName):
        return self.l.lookUpPSvr(self.lookupLSvr(swName))
    def lookupHostBySwName(self, swName):
        return self.l.lookUpHost(self.lookupLSvr(swName))

if __name__ == "__main__":
    s = software('hwbc', 'ozr')
    print s.lookupPSvrByLSvr('db')
    print s.lookupHostBySwName('mysql')

