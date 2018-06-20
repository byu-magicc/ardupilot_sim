ardupilot_sim
=============

This ROS simulation package includes plugins necessary for SITL/Gazebo simulations with the APM stack.

Tested with the following setup:

## Setting up ArduCopter SITL Environment ##

These steps can be found at the official ArduPilot Dev documentation on [Simulation & Testing](http://ardupilot.org/dev/docs/setting-up-sitl-on-linux.html).

1. Install prerequisites

    ```bash
    $ sudo apt install python-matplotlib python-serial python-wxgtk3.0 python-wxtools python-lxml python-scipy python-opencv ccache gawk genromfs python-pip python-pexpect
    $ sudo -H pip install future pymavlink MAVProxy
    ```

1. Grab the Ardupilot git repository

    ```bash
    git clone git://github.com/ArduPilot/ardupilot.git
    cd ardupilot
    git checkout Copter-3.5.4
    git submodule update --init --recursive
    ```

1. Add the `sim_vehicle.py` script to your path by adding the following to your `.bashrc`:

    ```bash
    export PATH=$PATH:$HOME/ardupilot/Tools/autotest
    ```

1. You can test that your (non-ROS/Gazebo) SITL environment is properly set up by running the following command:

    ```bash
    $ sim_vehicle.py -w -v ArduCopter -f y6 -l 40.267941,-111.635381,0,0 --map --console
    ```

    This command should use the `waf` build system to build an ELF version of ArduCopter. Once the build is complete, it should bring up a MAVProxy map and console and load the vehicle at Rock Canyon Park in Provo.

    After about 30 seconds, you should see something like the following in the console window:

    ```
    Ready to FLY fence breach
    APM: EKF2 IMU0 initial yaw alignment complete
    APM: EKF2 IMU1 initial yaw alignment complete
    APM: GPS 1: detected as u-blox at 115200 baud
    APM: EKF2 IMU0 tilt alignment complete
    APM: EKF2 IMU1 tilt alignment complete
    APM: EKF2 IMU0 Origin set to GPS
    APM: EKF2 IMU1 Origin set to GPS
    APM: EKF2 IMU1 is using GPS
    APM: EKF2 IMU0 is using GPS
    ```

    This means that the virtual Pixhawk is setup and you are ready to fly. You can fly by using the MAVProxy command line with the following commands:

    ```bash
    STABILIZE> mode guided
    GUIDED> arm throttle
    GUIDED> takeoff 30
    ```

    The copter should then take off and hover at 30m. You may then use the map to right click and `Fly To` locations on the map (this is a GUIDED mode feature). The basic MAVProxy commands can be found in the ![APM Tutorial](http://ardupilot.org/dev/docs/copter-sitl-mavproxy-tutorial.html)

1. Now that the SITL environment is working, you can test the gazebo plugin. 

    ```bash
    cd <some catkin_ws>/src
    git clone git@magiccvs.byu.edu:lab/ardupilot_sim.git
    cd ..
    catkin_make
    source devel/setup.bash
    roslaunch ardupilot_sim copter.launch
    ```

    At this point you should see the iris model appear in gazebo. Using the same MAVProxy commands in the previous section should cause the propellers to spin and iris to takeoff.


## Setting up ArduPlane SITL Environment ##

1. First follow the **Setting up ArduCopter SITL Environment** section. 

1. The plane support was developed on the `ArduPlane-3.8.5` branch.

    ```bash
    git checkout ArduPlane-3.8.5
    ```

1. The Ardupilot SITL is written to support multiple physics engines (JSBSim, Gazebo, etc.). If the `sim_vehicle.py` script is called with a frame name beginning with `gazebo-`, it will default to using gazebo for its physics engine. At this moment, the official ardupilot only supports a flying wing model `gazebo-zephyr`. This model only has two control surfaces (elevons) with a rear-mounted propeller. We will commonly want to use typical 4-channel planes during our simulations / flight tests. Since the possible frames are contained in the ardupilot repository, the easiest way to get 4-channel plane support is to patch the `gazebo-zephyr.parm` file and make it a 4-channel plane.

    ```bash
    cd $HOME/ardupilot
    git apply <path to catkin_ws>/src/ardupilot_sim/patches/Zephyr-Params.patch
    ```

1. You can now test the gazebo plugin.

    ```bash
    roslaunch ardupilot_sim plane.launch
    ```

1. Miscellaneous Plane things

- **Note**: you can apply this patch to the `Copter-3.5.4` branch but you will get merge conflicts. If you feel more comfortable, you can work on that branch and resolve the merge conflicts and it will work.

- The basic MAVProxy commands for the plane can be found in the ![APM Tutorial](http://ardupilot.org/dev/docs/plane-sitlmavproxy-tutorial.html). 

- The first waypoint needs to be of type `NAV_TAKEOFF`, this differs from the Copter simulation.


 

## Coordinate Frames ##

The firmware on the Pixhawk (both APM and the underlying PX4) assume a standard aerospace fixed coordinate frame of *local North-East-Down (NED)*. Gazebo, however, has been very popular with ground and service robotics and therefore uses the fixed *[local East-North-Up (ENU)](https://en.wikipedia.org/wiki/Geographic_coordinate_system#Cartesian_coordinates)* coordinate frame. Note that the order in which the frame is stated is patterned after X-Y-Z (i.e., East-North-Up means that X is East, Y is North, Z is Up). It is important to note that both of these conventions (NED and ENU) are fixed frames. The rotating and translating body in this fixed frame (i.e., the UAV) typically has a frame that is inspired by its locally fixed frame. This means that for an NED (Z-down) reference frame, the UAV body is typically forward-right-down (Z-down). For an ENU (Z-up) reference frame, the UAV body is typically forwared-left-up (Z-up). It is common for people to call these local body frames as, respectively, NED and NWU frames, but you should be aware that this is not strictly correct and cause confusion. We will explain the possible confusion by focusing on the meaning of *north* in both of these (NED and NWU body) frames. Because these are local body frames, there is no *north* in the globally fixed sense, other than that *north* means forward out of the nose of the airplane. For this reason, it is suggested that when referring to body NED or NWU, the word *body* is included, to signal to the reader that these compass directions do not refer to the Earth's poles. To be very clear for the sake of the quick reader, it may even be advisable to write it as such: NED (FRD) and NWU (FLU).

In simulation, it is important to handle these coordinate frames with clarity and precision. Gazebo returns world pose (`model->GetWorldPose().Ign()`) w.r.t the fixed ENU frame. APM expects data w.r.t the fixed NED frame. Therefore, a coordinate frame transformation is necessary to justify this. This transformation can be specified by the user in the `arducopter.xacro` (though there should be no reason to change it) as follows:

```xml
<!-- How to get from the Gazebo model's body frame [NWU (FLU)] to an aerospace body frame [NED (FRD)] -->
<modelXYZToAirplaneXForwardZDown>0 0 0 3.141593 0 0</modelXYZToAirplaneXForwardZDown>
<!-- How to get from the Gazebo fixed ENU frame to a fixed NED frame -->
<gazeboXYZToNED>0 0 0 3.141593 0 1.5708</gazeboXYZToNED>
```

## Using an RC Transmitter as a Joystick in SITL ##

It is possible to use an RC Transmitter to control the SITL using MAVProxy's `joystick` module. See ArduPilot SITL docs [here](http://ardupilot.org/dev/docs/using-sitl-for-ardupilot-testing.html#using-a-joystick) and MAVProxy module docs [here](http://ardupilot.github.io/MAVProxy/html/modules/joystick.html). The following should set it up for you (working with Taranis Q X7).

1. Install prerequisites:

    ```bash
    $ sudo -H pip install joystick pygame
    ```

1. Connect RC TX via USB.
1. Calibrate RC TX using QGroundControl, `Radio Calibration` tab (this will take care of channel mappings). -- you may need to restart simulation.
1. In MAVProxy xterm, load the joystick module (`module load joystick`).
1. Fly!

## Troubleshooting ##

- MAVProxy disconnects (`no link` error):
    1. During the gyro bias calibration step, ArduPilot does not send MAVLink heartbeat messages.
    2. ArduPilot gets stuck during this step if there are large IMU variances -- i.e., if the UAV is moving.
    3. For some reason, Gazebo seems to start the Iris model with each motor having some angular velocity, which causes the Iris to be moving slightly.

- MAVProxy Map says "Unavailable":
    - The map tile server provider is not available. Go to `View` > `Service` and choose another (`MicrosoftSat` seems to work well).
    - As discussed [here](https://discuss.ardupilot.org/t/sitl-on-linux-map-unavailable/26088), set the `MAP_SERVICE` environment variable to change the default map service provider: `export MAP_SERVICE=MicrosoftSat`.

## Resources ##

This package is based off the [SwiftGust/ardupilot_gazebo](https://github.com/SwiftGust/ardupilot_gazebo) repo.

- [ErleRobot/ardupilot_sitl_gazebo_plugin](https://github.com/erlerobot/ardupilot_sitl_gazebo_plugin/tree/master/ardupilot_sitl_gazebo_plugin)
