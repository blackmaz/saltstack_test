import salt.client
import yaml

f = open("siteconfig.yaml", 'r')
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
  for h in host_list:
    if ret != {}:
      for s, r in  ret.get(h).get('state.apply').items():
        print '['+h+']' + '['+id+']' + '['+str(r.get('result'))+']' + s
    else:
      print '['+h+']' + '['+id+']' 
      
