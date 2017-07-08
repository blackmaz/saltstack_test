# 데이터 가져오는지 확인 필요
{%- set mst = salt['mysql.get_master_status'](connection_pass=cfg.rpw,connection_user=cfg.rid,connection_host=cfg.mst_ip) %}

CHANGE MASTER TO MASTER_HOST='{{cfg.mst_ip}}'
     , MASTER_USER='{{cfg.rid}}'
     , MASTER_PORT={{cfg.port}}
     , MASTER_PASSWORD='{{cfg.rpw}}'
     , MASTER_LOG_FILE='{{mst.File}}'
     , MASTER_LOG_POS={{mst.Position}}
;
start slave;

