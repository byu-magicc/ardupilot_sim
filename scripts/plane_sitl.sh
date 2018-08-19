#!/bin/bash

# Pass in lat lon of starting point (origin in Gazebo)
# with syntax: 40.267987,-111.635558 (rock canyon park)
LATLON=$1

# Catch CTRL+C (and other signals) and do SITL cleanup.
trap '{ echo "Cleaning up plane_sitl.sh"; killall xterm && killall mavproxy.py; }' EXIT

CMD="sim_vehicle.py -v ArduPlane -f gazebo-zephyr $LATLON,0,0 --map --console"
xterm -fa monospace -fs 12 -n PlaneSITL -T PlaneSITL -hold -geometry 100x20 -e $CMD
