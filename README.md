ardupilot_sim
=============

This ROS simulation package includes plugins necessary for SITL/Gazebo simulations with the APM stack. Currently, only Copter plugins exist.

## Setting up ArduCopter SITL Environment ##

These steps can be found at the official ArduPilot Dev documentation on [Simulation & Testing](http://ardupilot.org/dev/docs/setting-up-sitl-on-linux.html).

1. Install prerequisites

    ```bash
    $ sudo apt install python-matplotlib python-serial python-wxgtk3.0 python-wxtools python-lxml python-scipy python-opencv ccache gawk genromfs python-pip python-pexpect
    $ sudo -H pip install future pymavlink MAVProxy
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

    The copter should then take off and hover at 30m. You may then use the map to right click and `Fly To` locations on the map (this is a GUIDED mode feature).

## Troubleshooting ##

- MAVProxy disconnects (`no link` error):
    1. During the gyro bias calibration step, ArduPilot does not send MAVLink heartbeat messages.
    2. ArduPilot gets stuck during this step if there are large IMU variances -- i.e., if the UAV is moving.
    3. For some reason, Gazebo seems to start the Iris model with each motor having some angular velocity, which causes the Iris to be moving slightly.

## Resources ##

This package is based off the [SwiftGust/ardupilot_gazebo](https://github.com/SwiftGust/ardupilot_gazebo) repo.

- [ErleRobot/ardupilot_sitl_gazebo_plugin](https://github.com/erlerobot/ardupilot_sitl_gazebo_plugin/tree/master/ardupilot_sitl_gazebo_plugin)