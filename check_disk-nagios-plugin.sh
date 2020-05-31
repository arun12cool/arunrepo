#!/bin/bash
j=0; ok=0
crit=0
COMMAND="/bin/df -PH"
TEMP_FILE="/var/tmp/df.$RANDOM"
CRIT=80


get_data ()
{
  /bin/df -PH > ${TEMP_FILE}.tmp
  cat ${TEMP_FILE}.tmp | grep -v Used | grep -v '0 0 0'|grep -ve '- - -' > ${TEMP_FILE}
  EQP_FS=$(cat ${TEMP_FILE} | grep -v Used |grep -v '0 0 0'|grep -ve '- - -' | wc -l)
}

process_data (){
  FILE=$TEMP_FILE
  exec 3<&0
  exec 0<"$FILE"

  while read LINE; do
    j=$((j+1))
    FULL[$j]=`echo $LINE | awk '{print $2}'`
    USED[$j]=`echo $LINE | awk '{print $3}'`
    FREE[$j]=`echo $LINE | awk '{print $4}'`
    FSNAME[$j]=`echo $LINE | awk '{print $6}'`
    PERCENT[$j]=`echo $LINE | awk '{print $5}' | sed 's/[%]//g'`

  done
  exec 3<&0
}

get_data
process_data

for (( i=1; i<=$EQP_FS; i++ )); do
  if [ "${PERCENT[$i]}" -lt "${CRIT}" ]; then
    ok=$((ok+1))
  elif [ "${PERCENT[$i]}" -eq "${CRIT}" -o "${PERCENT[$i]}" -gt "${CRIT}" ]; then
    crit=$((crit+1))
    CRIT_DISKS[$crit]="${FSNAME[$i]} has ${PERCENT[$i]}% of utilization or ${USED[$i]} of ${FULL[$i]},"
  fi
done

for (( i=1; i<=$EQP_FS; i++ )); do
  DATA[$i]="${FSNAME[$i]} ${PERCENT[$i]}% of ${FULL[$i]},"
  perf[$i]="${FSNAME[$i]}=${PERCENT[$i]}%;${CRIT};0;;"
done

if [ "$ok" -eq "$EQP_FS" -a "$crit" -eq 0 ]; then
  echo "OK. DISK STATS: ${DATA[@]}"
  exit 0
elif [ "$crit" -gt 0 ]; then
    echo "CRITICAL-DISK SPACE: DISK STATS: ${DATA[@]}_Critical ${CRIT_DISKS[@]}| ${perf[@]}"
    df -h
    exit 2
  fi
else
  echo "Unknown"
  exit 3
