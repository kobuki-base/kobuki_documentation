Installing & Running the Software
=================================

Install from Binaries
---------------------

If you happen to have access to a binary install (e.g. ROS), follow their instructions and
then proceed directly to :ref:`drive-section`, otherwise follow the instructions below to
build Kobuki and it's dependencies from source.

Build from Source
-----------------

Requirements
^^^^^^^^^^^^

The environment under which these instructions have been tested (and thus supported) is as follows.

* Platform: Linux (most flavours)
* C++ Version: c++14
* Compiler: gcc
* Build Dependencies: ament, colcon, vcstool, CMake
* Code Dependencies: Eigen, Sophus, ECL

Other platforms may work, but your mileage will vary. Windows has been supported in the past, so
if you're willing to do a bit of work, you might find success.

.. _build2-section:

Preparation
^^^^^^^^^^^

Ensure your system has the following packages installed:

* GCC (>=9)
* CMake (>=3.5)
* wget
* python3-venv

Download a few scripts that will help setup your workspace.

.. code-block:: bash

   $ mkdir kobuki && cd kobuki
   
   # a virtual environment launcher that will fetch build tools from pypi (colcon, vcstools)
   $ wget https://raw.githubusercontent.com/kobuki-base/kobuki_documentation/release/1.0.x/resources/venv.bash || exit 1
   
   # custom build configuration options for eigen, sophus
   $ wget https://raw.githubusercontent.com/kobuki-base/kobuki_documentation/release/1.0.x/resources/colcon.meta || exit 1
   
   # list of repositories to git clone
   $ wget https://raw.githubusercontent.com/kobuki-base/kobuki_documentation/release/1.0.x/resources/kobuki_standalone.repos || exit 1

Fetch the sources:

.. code-block:: bash

   $ source ./venv.bash
   
   $ mkdir src
   
   # vcs handles distributed fetching of repositories listed in a .repos file
   $ vcs import ./src < kobuki_standalone.repos || exit 1

   $ deactivate

.. note::

   If you prefer to use your system Eigen:

   .. code-block:: bash

      $ touch src/eigen/AMENT_IGNORE

.. _build-section:

Build
^^^^^

.. code-block:: bash

   $ source ./venv.bash

   # build everything
   $ colcon build --merge-install --cmake-args -DBUILD_TESTING=OFF
   
   # disable any unused cmake variable warnings (e.g. sophus doesn't use BUILD_TESTING)
   $ colcon build --merge-install --cmake-args -DBUILD_TESTING=OFF --no-warn-unused-cli

   # build a single package
   $ colcon build --merge-install --packages-select kobuki_core --cmake-args -DBUILD_TESTING=OFF
   
   # build everything, verbosely
   $ VERBOSE=1 colcon build --merge-install --event-handlers console_direct+ --cmake-args -DBUILD_TESTING=OFF

   # build release with debug symbols
   $ colcon build --merge-install --cmake-args -DBUILD_TESTING=OFF -DCMAKE_BUILD_TYPE=RelWithDebInfo

   # update the source workspace
   $ vcs pull ./src

   $ deactivate

The resulting headers, libraries and resources can be found under ``./install``.

These instructions are continuously vetted with a github action
(`yaml <https://github.com/kobuki-base/kobuki_documentation/blob/devel/.github/workflows/weekly.yaml>`_,
`results/logs <https://github.com/kobuki-base/kobuki_documentation/actions?query=workflow%3Abuild_sources>`_). 

Connect Kobuki
--------------

Kobuki's default means of communication is over usb (it can instead use the serial comm port
directly, more on that later). On most linux systems, your Kobuki will appear on
``/dev/ttyUSBO`` as soon as you connect the cable. This is a typical serial2usb device port
and if you happen to be using more than one such device, Kobuki may appear at ``ttyUSB1``,
``ttyUSB1``, ...

In order to provide a constant identifier for the connection, we've prepared a udev rule for you:

.. code-block:: bash

   $ wget https://raw.githubusercontent.com/kobuki-base/kobuki_ftdi/devel/60-kobuki.rules
   $ sudo cp 60-kobuki.rules /etc/udev/rules.d

   # different linux distros may use a different service manager (this is Ubuntu's)
   #   --> failing all else, a reboot will work
   $ sudo service udev reload
   $ sudo service udev restart

With this udev rule, you'll find your Kobuki appear at ``/dev/kobuki`` as soon as you
connect and turn on the robot. This also comes with the added convenience that it is
the default device port value for most Kobuki programs.

* Connect the usb cable
* Turn Kobuki on (you'll hear a chirp)
* Check for existence of ``/dev/kobuki``
* I'm wearing a colander, you should too

If you're still having problems, refer to the :ref:`troubleshooting-section` pages
on :ref:`troubleshooting-usb-section`.

.. _drive-section:

Checking the Version Info
-------------------------

.. code-block:: bash

   # drop into the runtime enviroment
   $ source ./install/setup.bash
   
   # who is your kobuki?
   $ kobuki-version-info
   Version Info:
     Hardware Version: 1.0.4
     Firmware Version: 1.2.0
     Software Version: 1.1.0
     Unique Device ID: 97713968-842422349-1361404194

Your driver may give you a warning (software or firmware upgrade advised) or error
(incompatible firmware/software) about mismatching versions.
If it's the firmware you need to upgrade, refer to the section on :ref:`firmware-section`. 

Take Kobuki for a Test Drive
----------------------------

.. code-block:: bash

   # drop into the runtime enviroment
   $ source ./install/setup.bash

   # take kobuki for a test drive
   $ kobuki-simple-keyop
   Simple Keyop : Utility for driving kobuki by keyboard.
   KobukiManager : using linear  vel step [0.05].
   KobukiManager : using linear  vel max  [1].
   KobukiManager : using angular vel step [0.33].
   KobukiManager : using angular vel max  [6.6].
   Reading from keyboard
   ---------------------------                                                                                                                             
   Forward/back arrows : linear velocity incr/decr.                                                                                                        
   Right/left arrows : angular velocity incr/decr.
   Spacebar : reset linear/angular velocities.
   q : quit.
   current pose: [0, 0, 0]
   current pose: [0, 0, 0]
   current pose: [0, 0, 0]
   current pose: [0.0064822, -1.17028e-06, -0.00074167]
   current pose: [0.0226873, -9.88246e-05, -0.0133501]
