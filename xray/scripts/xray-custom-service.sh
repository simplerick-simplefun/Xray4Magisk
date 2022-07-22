#!/system/bin/sh

MODFILE=/data/adb/modules/xray4magisk/disable
if [ -n "$(magisk -v | grep lite)" ]; then
  MODFILE=/data/adb/lite_modules/xray4magisk/disable
fi

case "$1" in
  start)
    rm -rf ${MODFILE}
    ;;
  stop)
    touch ${MODFILE}
    ;;
  *)
    echo "$0:  usage:  $0 {start|stop}"
    ;;
esac

