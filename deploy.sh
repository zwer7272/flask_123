#!/bin/bash

# tar code
# version: v1.0
# author: python4qi

LOG_FILE="/data/logs/deploy.log"

write_log(){
  echo "$(date +%F%T) : $0 $1" >> "${LOG_FILE}"
}

get_code(){
  echo "获取代码"
  write_log "获取代码"
}

tar_code(){
  echo "打包代码"
  write_log "打包代码"
  ssh root@192.168.133.253 "bash /data/scripts/tar_code.sh"
}

scp_code(){
  echo "传输代码"
  write_log "传输代码"
  scp root@192.168.133.253:/data/codes/django.tar.gz /data/codes
}

untar_code(){
  echo "解压代码"
  write_log "解压代码"
  cd /data/codes
  tar xzf django.tar.gz
}

stop_server(){
  echo "关闭应用"
  write_log "关闭应用"
  echo "关闭nginx"
  write_log "关闭nginx"
  /data/server/nginx/sbin/nginx -s stop
  echo "关闭django"
  write_log "关闭django"
  kill $(lsof -Pti :8000)
}

replace_code(){
  echo "放置代码"
  write_log "放置代码"
  echo "备份代码"
  write_log "备份代码"
  mv /data/server/itcast/helloworld/views.py /data/backup/views.py-$(date +%Y%m%d%H%M%S)
  echo "替换代码"
  write_log "替换代码"
  mv /data/codes/django/views.py /data/server/itcast/helloworld/
}

start_server(){
  echo "开启应用"
  write_log "开启应用"
  echo "开启django"
  write_log "开启django"
  export WORKON_HOME=/data/virtual
  source /usr/local/bin/virtualenvwrapper.sh
  workon pyd_django
  cd /data/server/itcast
  python manage.py runserver >/dev/null 2>&1 &
  deactivate
  echo "开启nginx"
  write_log "开启nginx"
  /data/server/nginx/sbin/nginx 
}

check(){
  echo "检查应用"
  write_log "检查应用"
  netstat -tnulp | grep 80
}

LOCK_FILE="/tmp/deploy.pid"

add_lock(){
  echo "添加锁文件"
  write_log "添加锁文件"
  touch ${LOCK_FILE}
}

del_lock(){
  echo "删除锁文件"
  write_log "删除锁文件"
  rm "${LOCK_FILE}"
}

deploy(){
  add_lock
  get_code
  #sleep 10
  tar_code
  scp_code
  untar_code
  stop_server
  replace_code
  start_server
  check
  del_lock
}

usage(){
  echo "使用方法：bash $0 deploy"
}

main(){
  case $1 in
  "deploy")
    write_log "发布代码"
    if [ -f "${LOCK_FILE}" ]
    then
      echo "脚本$0正在执行，稍等"
    else
      deploy
    fi
    ;;
  *)
    usage
    ;;
  esac
} 

if [ $# -eq 1 ]
then
main $1
else
usage
fi
