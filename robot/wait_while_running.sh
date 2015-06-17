#!/bin/bash

running=1
echo "waiting for robot to complete current task"
while [ $running = "1" ]; do
	running=`/home/user/applications/RAPID/robot/KARELcomget.sh`
done
echo "robot completed task"
