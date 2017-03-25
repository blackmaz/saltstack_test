#!/usr/bin/python
# -*- coding: utf-8 -*-
import salt.client
import yaml
import sys
import getopt
import pprint
import yaml
from collections import OrderedDict

# Dictionary에 데이터를 순서에 맞게 입력해줌
def ordered_load(stream, Loader=yaml.Loader, object_pairs_hook=OrderedDict):
    class OrderedLoader(Loader):
        pass
    def construct_mapping(loader, node):
        loader.flatten_mapping(node)
        return object_pairs_hook(loader.construct_pairs(node))
    OrderedLoader.add_constructor(
        yaml.resolver.BaseResolver.DEFAULT_MAPPING_TAG,
        construct_mapping)
    return yaml.load(stream, OrderedLoader)


input_file=''

def help():
    print "python statetest.py -i [site config file]"
    return

def option():
    global input_file
    if len(sys.argv) is 1:
        help()
        sys.exit(1)
    try:    
        options, args =  getopt.getopt(sys.argv[1:], "i:h", ["input=","help"])
    except getopt.GetoptError as err:
        print str(err)
        help()
        sys.exit(1)
        
    for opt, arg in options:
        if (opt == '-i') or (opt == '--input'):
            input_file = arg
        elif (opt == '-h') or (opt == '--help'):
            help()
            sys.exit(1)

    return

option()

print input_file
try:
    f = open(input_file, 'r')
except IOError as err:
    print str(err)
    sys.exit(1)

cfg = ordered_load(f, yaml.SafeLoader)

pSvrs = cfg.get('physical server')
lSvrs = cfg.get('logical server')
sws = cfg.get('software')

cmd_list = ['state.apply']

local = salt.client.LocalClient()

for id, sw in sws.items():
    lSvr = sw.get('deploy server')
    host_list = []
    arg_list = [[id]]
    for pSvr in lSvrs.get(lSvr).get('physical server'):
        host_list.append(pSvrs.get(pSvr).get('hostname'))
    print "===================================================="
    print str(host_list) + str(cmd_list) + str(arg_list)
    ret = local.cmd_iter(host_list, cmd_list, arg_list, expr_form='list',timeout=1800)
    print "===================================================="
    #print ret
    #pprint.pprint(ret)
    for r in ret:
        print r[r.keys()[0]]['retcode']
#
# local.cmd_iter(hosts, cmds, [ args, 'pillar={"foo": "bar"}'], expr_form ~~) 
# note : Loading companyCode, systemCode at run-time in pillar
