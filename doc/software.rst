Installing & Running the Software
=================================

Install from Binaries
---------------------

If you happen to have access to a binary install (e.g. ROS), follow their instructions and
then proceed directly to :ref:`drive-section`.

Install from Source
-------------------

Requirements
^^^^^^^^^^^^

The environment under which these instructions have been tested (and thus supported) is as follows.

* Platform: Linux (most flavours)
* C++ Version: c++14
* Compiler: gcc
* Build Dependencies: ament, colcon, vcstool, CMake
* Code Dependencies: Eigen, Sophus, ECL

Other options may work, but your mileage will vary. Windows has been supported in the past, so
if you're willing to do a bit of work, you might find success.

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
   $ wget https://raw.githubusercontent.com/kobuki-base/kobuki_documentation/devel/resources/venv.bash || exit 1
   
   # custom build configuration options for eigen, sophus
   $ wget https://raw.githubusercontent.com/kobuki-base/kobuki_documentation/devel/resources/colcon.meta || exit 1
   
   # list of repositories to git clone
   $ wget https://raw.githubusercontent.com/kobuki-base/kobuki_documentation/devel/resources/kobuki_standalone.repos || exit 1

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

Build
^^^^^

.. code-block:: bash

   $ source ./venv.bash

   # build everything
   $ colcon build --merge-install --cmake-args -DBUILD_TESTING=OFF

   # build a single package
   $ colcon build --merge-install --cmake-args -DBUILD_TESTING=OFF --package-select kobuki_dock_drive
   
   # build everything, verbosely
   $ VERBOSE=1 colcon build --merge-install --event-handlers console_direct+ -DBUILD_TESTING=OFF

   # build release with debug symbols
   $ colcon build --merge-install --cmake-args -DBUILD_TESTING=OFF -DCMAKE_BUILD_TYPE=RelWithDebInfo

   # update the source workspace
   $ vcs pull ./src

   $ deactivate

The resulting headers, libraries and resources can be found under ``./install``.

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

If you're still having problems, refer to the
`kobuki_ftdi/README <https://github.com/kobuki-base/kobuki_ftdi/blob/devel/README.md>`_
for assistance.

.. _drive-section:

Take Kobuki for a Drive
-----------------------

.. code-block:: bash

   # drop into the runtime enviroment
   $ source ./install/setup.bash
   
   # who is your kobuki?
   $ kobuki_version_info
   Version Info:
     Hardware Version: 1.0.4
     Firmware Version: 1.2.0
     Software Version: 1.1.0
     Unique Device ID: 97713968-842422349-1361404194

   # take kobuki for a test drive
   $ kobuki_simple_keyop
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


.. _Dabit Wiki: https://github.com/dabit-industries/kobuki_wiki
