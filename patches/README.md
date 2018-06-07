# Ardupilot Params
When ardupilot runs the SITL it loads a `.parm ` file to determine which simulation it will run. These are located in `ardupilot/Tools/autotest/default_parms`. Files that begin with gazebo will interface with gazebo and send servo commands to the gazebo plugin.

Unfortunately, ardupilot doesn't come with a basic 4-channel plane gazebo parameter file. We bypass this issue by modifying `gazebo-zephyr.parm`. You can look in the patch to see the parameters that were modified and added. A full list of parameters for ardupilot can be found [here](http://ardupilot.org/copter/docs/parameters.html).
