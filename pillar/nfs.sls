# NFS configuration pillar

#NFS Server 설정
nfs-server:
  server-ip: 192.168.50.102
  exports-dir: /share/data
  nfs-allowed-client-ip: 192.168.50.*
  nfs-opts: rw,sync

#NFS Client 설정
nfs-client:
  mount-dir: /share/data
  fstab-opts: hard,intr

