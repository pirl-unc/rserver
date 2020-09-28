#!/bin/bash
# Source of most of this
# https://medium.com/@gchudnov/trapping-signals-in-docker-containers-7a57fdda7d86#.6b04xvnr8
#
# Q: Why handle SIGTERM instead of SIGKILL?
# A: scancel sends SIGTERM before SIGKILL and since SIGKILL can't be trapped we'll use SIGTERM
#    SIGCONT is sent before SIGTERM, but SIGTERM will interupt us if we use SIGCONT

my_port=$1

# sigterm_output_path="/datastore/alldata/shiny-server/rstudio-common/dbortone/projects/testing/custom_rstudio_image/out.txt"

my_pid=$$
my_sid=$(ps -p $$ -o sid=)

# echo "rserver_handler active to run clean_up_if_needed" > $sigterm_output_path
# echo "SLURM_JOBID: $SLURM_JOBID" >> $sigterm_output_path
# echo "my_pid: ${my_pid}" >> $sigterm_output_path
# echo "my_sid: ${my_sid}" >> $sigterm_output_path
# echo >> $sigterm_output_path


clean_up_if_needed() {
  
  
  # job_id=$1
  track_pid=$1
  my_sid=$2
  # sigterm_output_path="/datastore/alldata/shiny-server/rstudio-common/dbortone/projects/testing/custom_rstudio_image/out.txt"

  # my_pid=$$
  # $$ IS RETURNING PGRP. no idea why this would happen. hopefully this oddity is at least consistent
  # echo "clean_up_if_needed pgrp: $$" >> $sigterm_output_path
  my_pgrp=$$

  # echo "track_pid: ${track_pid}" >> $sigterm_output_path

  while [[ $(ps -p $track_pid -o pid | grep -c $track_pid) -eq 1 ]]
  do
    # echo "clean_up_if_needed track_pid: ${track_pid}" >> $sigterm_output_path
    # echo "clean_up_if_needed my_sid: ${my_sid}" >> $sigterm_output_path
    sleep 2
  done
  
  # echo "Main process is done and I'm alive! Now clean up...." >> $sigterm_output_path
  
  # next find pids with my sid but not my pgrp, so we don't kill this process
  # my_pgrp=$(ps -p $$ -o pgrp --no-header)
  kill_pids=($(ps -U $USER -o pid,sid,pgrp --no-header | awk -v my_pgrp=$my_pgrp -v my_sid=$my_sid '{if(($2 == my_sid) && ($3 != my_pgrp)) { print $1 }}'))
  
  # echo >> $sigterm_output_path
  # ps -U $USER -o pid,sid,pgrp >> $sigterm_output_path
  # echo >> $sigterm_output_path
  # echo "my_pgrp: $my_pgrp" >> $sigterm_output_path
  
  for kill_pid in ${kill_pids[@]}
  do
    # echo "Killing: $kill_pid" >> $sigterm_output_path
    kill -15 $kill_pid
  done
  
  # echo "Killing spree over" >> $sigterm_output_path
  
  exit 143
}



rserver --www-port=$my_port &>/dev/null &


# nohup can only run a bash script, not functions, so wee need to export it
export -f clean_up_if_needed
# need to have this process start with a different sid and pgrp so it doesn get killed by singularity's unstopable sigterm
# nohup and disown makes the ppid 1
# 'set -m : exec' gives it a new pgrp
(set -m; exec nohup bash -c "clean_up_if_needed ${my_pid} ${my_sid} & disown" &)

tail -f /dev/null




# important aborted attempts
#  nohup sets the ppid to 1 and makes it really hard to track the processes coming from rserver 
#  rsession can't be killed with pkill
#  running rserver directly from singularity exec runs it as pid 1
#  i can trap sigterm in singularity but I can't stop it.  either sigkill follows immediately or the sigterm isn't intercepted
#  nohup can only run bash, not functions
#  $$ inside a nohup command returns the pgrp.