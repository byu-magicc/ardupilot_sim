#!/bin/bash

# sleep 10

source ~/.bash_profile

CMD="sim_vehicle.py -v ArduCopter -f gazebo-iris -l 40.267941,-111.635381,0,0 --map --console"
xterm -fa monospace -fs 12 -n CopterSITL -T CopterSITL -hold -geometry 100x20 -e $CMD

# This is a hacky way of doing cleanup, but it works for now.
# sim_vehicle.py kicks off a new xterm window for arducopter and
# mavproxy is running as well for the SITL stuff.
pkill xterm
pkill mavproxy.py