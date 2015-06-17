#!/bin/bash

running=1
echo "waiting for robot to complete current task"
while [ $running = "1" ]; do
	running=`/home/user/fanucrobot/KARELcomget.sh`
done
echo "robot completed task"
