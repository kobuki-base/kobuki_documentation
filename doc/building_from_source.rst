Building from Source
====================

.. _kobuki-core-on-ubuntu-section:

Kobuki Core - Ubuntu
--------------------

Resources
^^^^^^^^^

* `Build ROS2 From Sources`_

.. _Build ROS2 From Sources: https://index.ros.org/doc/ros2/Installation/Eloquent/Linux-Development-Setup/
.. _ROS2 Repos: https://raw.githubusercontent.com/ros2/ros2/eloquent/ros2.repos
.. _Dabit Wiki: https://github.com/dabit-industries/kobuki_wiki

Requirements
^^^^^^^^^^^^

These instructions have been tested on an **Ubuntu Bionic** (18.04) platform using
ROS2 Eloquent for the build tools. They should work, or at least provide direction
for other Ubuntu and ROS distros, but your mileage may vary.

Locale
^^^^^^

Make sure to set a locale that supports UTF-8. If you are in a minimal environment
such as a Docker container, the locale may be set to something minimal like POSIX.

The following is an example for setting locale.
However, it should be fine if you're using a different UTF-8 supported locale.

.. code-block:: bash

   sudo locale-gen en_US en_US.UTF-8
   sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
   export LANG=en_US.UTF-8

System Build Tools
^^^^^^^^^^^^^^^^^^

.. code-block:: bash

   sudo apt update && sudo apt install -y \
     build-essential \
     cmake \
     git \
     wget

ROS2 Build Tools
^^^^^^^^^^^^^^^^

.. note::

    Here we just fetch the required tooling for a distributed repository build. The resulting
    build will not be a Kobuki node for ROS2, nor will it depend on ROS2 in any way. 

For these you'll need access to the ROS2 apt repositories.

.. code-block:: bash

   sudo apt update && sudo apt install curl gnupg2 lsb-release
   curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | sudo apt-key add -
   sudo sh -c 'echo "deb http://packages.ros.org/ros2/ubuntu `lsb_release -cs` main" > /etc/apt/sources.list.d/ros2-latest.list'

Then fetch the required build tools:

.. code-block:: bash

   sudo apt update && sudo apt install -y \
     python3-colcon-common-extensions \
     python-rosdep \
     python3-vcstool

Sources
^^^^^^^

.. _kobuki-core-cross-compile-section:

Kobuki Core - Cross Compile
---------------------------

