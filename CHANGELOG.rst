=========
Changelog
=========

.. note::

   This is a curated list of changes for all repositories in the kobuki ecosystem (to which this
   documentation pertains). See also:
   
   [`kobuki_core/CHANGELOG.rst <https://github.com/kobuki-base/kobuki_core/blob/devel/CHANGELOG.rst>`_] 
   [`kobuki_firmware/CHANGELOG.rst <https://github.com/kobuki-base/kobuki_firmware/blob/devel/CHANGELOG.rst>`_]

September '20
-------------

* **[kobuki_core-1.3.1]**
   * configurable stdout logging
   * custom_logging and raw_data_stream demos added
   * dual version firmware compatibility (1.1.4, 1.2.0)
* **[kobuki_core-1.3.0]** LegacyPose2D -> Eigen::Vector3d
* **[kobuki_core-0.7.10]** dual version firmware compatibility (1.1.4, 1.2.0)
* **[kobuki_documentation-1.0.2]** debugging tutorials (logging and raw data streams)

August '20
----------

* **[kobuki_core-1.2.0]** :grey:`kobuki_driver` & :grey:`kobuki_dock_driver` merged into :grey:`kobuki_core`
* **[kobuki_core-1.1.1]** :red:`(bugfix)` restore low latency usb reads via the udev rule and `doxygen <https://kobuki-base.github.io/kobuki_core/>`_ revamp
* **[kobuki_core-0.7.9]** :red:`(bugfix)` restore low latency usb reads via the udev rule
* **[kobuki_documentation-1.0.1]** `cross-compiling <https://kobuki.readthedocs.io/en/devel/embedded_boards.html#cross-compiling>`_ instructions
* **[kobuki_documentation-1.0.0]** new guide on `readthedocs <https://kobuki.readthedocs.io/en/devel/index.html>`_, everything in one place now!

Mar '20
-------

* **[kobuki_firmware-1.2.0]** new `github repo <https://github.com/kobuki-base/kobuki_firmware>`_ for the kobuki firmware binaries, with license

Jan '20
-------

* **[kobuki_core-1.0.0]**
   * moved to the kobuki-base github org
   * ported to the colcon build system