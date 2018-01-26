#!/bin/bash

# sleep 10

# Pass in lat lon of starting point (origin in Gazebo)
# with syntax: 40.267987,-111.635558 (rock canyon park)
LATLON=$1

source ~/.bash_profile

CMD="sim_vehicle.py -v ArduCopter -f gazebo-iris -l $LATLON,0,0 --map --console"
xterm -fa monospace -fs 12 -n CopterSITL -T CopterSITL -hold -geometry 100x20 -e $CMD

# This is a hacky way of doing cleanup, but it works for now.
# sim_vehicle.py kicks off a new xterm window for arducopter and
# mavproxy is running as well for the SITL stuff.
pkill xterm
pkill mavproxy.py