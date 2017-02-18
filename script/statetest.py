# -*- coding: utf-8 -*-
import salt.client
import yaml
import sys
import getopt
import pprint

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

cfg = yaml.load(f)

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
    ret = local.cmd(host_list, cmd_list, arg_list, expr_form='list')
    pprint.pprint(ret)
      
