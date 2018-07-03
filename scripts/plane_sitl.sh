#!/bin/bash

# Pass in lat lon of starting point (origin in Gazebo)
# with syntax: 40.267987,-111.635558 (rock canyon park)
LATLON=$1
INSTANCE=$2
MAP=$3

# Catch CTRL+C (and other signals) and do SITL cleanup.
trap '{ echo "Cleaning up plane_sitl.sh"; kill -f xterm; kill -f mavproxy.py; }' EXIT

if $MAP; then
  CMD="sim_vehicle.py -v ArduPlane -f gazebo-zephyr -l $LATLON,0,0 --map --console --instance $INSTANCE"
else
  CMD="sim_vehicle.py -v ArduPlane -f gazebo-zephyr -l $LATLON,0,0 --console --instance $INSTANCE"
fi

xterm -fa monospace -fs 12 -n PlaneSITL -T PlaneSITL -hold -geometry 100x20 -e $CMD
