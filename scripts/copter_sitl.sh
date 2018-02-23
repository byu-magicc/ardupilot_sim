#!/bin/bash

# sleep 10

# Pass in lat lon of starting point (origin in Gazebo)
# with syntax: 40.267987,-111.635558 (rock canyon park)
LATLON=$1

source ~/.bash_profile

# Catch CTRL+C and do SITL cleanup.
trap '{ echo "Cleaning up copter_sitl.sh"; killall xterm && killall mavproxy.py; }' INT

CMD="sim_vehicle.py -v ArduCopter -f gazebo-iris -l $LATLON,0,0 --map --console"
xterm -fa monospace -fs 12 -n CopterSITL -T CopterSITL -hold -geometry 100x20 -e $CMD