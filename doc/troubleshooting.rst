.. _troubleshooting-section:

Troubleshooting
===============

asfd

.. _troubleshooting-usb-section:

The USB/FTDI Connection
-----------------------

Kobuki's FTDI chip is flashed with a special identifier that allows programs to
uniquely identify the device as a kobuki. This in turn allows for udev rules
that conveniently establish it's presence under :maroon:`/dev/kobuki`.

Is it just Working?
^^^^^^^^^^^^^^^^^^^

Important checks that you can expect to see if and once it's working:

Does kobuki appear as USB device?

.. code-block:: bash

   > lsusb
   0403:6001 Future Technology Devices International, Ltd FT232 USB-Serial (UART) IC

Do you see it in :maroon:`dmesg` when you insert the usb cable?

.. code-block:: bash

   > dmesg
   [  118.984126] usb 3-1: new full-speed USB device number 5 using xhci_hcd
   [  119.139253] usb 3-1: New USB device found, idVendor=0403, idProduct=6001
   [  119.139257] usb 3-1: New USB device strings: Mfr=1, Product=2, SerialNumber=3
   [  119.139259] usb 3-1: Product: iClebo Kobuki
   [  119.139261] usb 3-1: Manufacturer: Yujin Robot
   [  119.139263] usb 3-1: SerialNumber: kobuki_A505QO28
   [  119.150240] usbcore: registered new interface driver usbserial_generic
   [  119.150249] usbserial: USB Serial support registered for generic
   [  119.152383] usbcore: registered new interface driver ftdi_sio
   [  119.152403] usbserial: USB Serial support registered for FTDI USB Serial Device
   [  119.152505] ftdi_sio 3-1:1.0: FTDI USB Serial Device converter detected
   [  119.152530] usb 3-1: Detected FT232RL
   [  119.152665] usb 3-1: FTDI USB Serial Device converter now attached to ttyUSB0

and when you remove it?

.. code-block:: bash

   [  184.386124] usb 3-1: USB disconnect, device number 5
   [  184.386507] ftdi_sio ttyUSB0: FTDI USB Serial Device converter now disconnected from ttyUSB0
   [  184.386547] ftdi_sio 3-1:1.0: device disconnected

Problems & Solutions
^^^^^^^^^^^^^^^^^^^^

* No :maroon:`/dev/kobuki`?

.. code-block:: bash

   # copy across udev rules
   > sudo cp 60-kobuki.rules /etc/udev/rules.d
   > sudo service udev reload
   > sudo service udev restart

* Does kobuki stream data?

Check if anything is streaming - even when you don't have a program explicitly
connected, you should see a stream of unusual characters.

.. code-block:: bash

   > cat /dev/kobuki 

If you don't have any streaming, check that your kernel has the ftdi_sio kernel
driver built. Refer to `kobuki_core#24 <https://github.com/yujinrobot/kobuki_core/issues/24>`_
for more discussion.

* Everything seems fine, yet I still can't get the kobuki driver to communicate with it.

You may not be in the correct group, try the following and logout/login (or reboot):

.. code-block:: bash

   > sudo addgroup $(USER) dialout

Kobuki's Unique Device ID?
--------------------------

Each Kobuki comes with a unique device ID imprinted on the FTDI chip
at the factory. This can be retrieved with the
:maroon:`kobuki_version_info` program that comes as part of the
:maroon:`kobuki_core` package.

.. code-block:: bash

   $ kobuki_version_info
   Version Info:
     Hardware Version: 1.0.4
     Firmware Version: 1.2.0
     Software Version: 1.1.0
     Unique Device ID: 97713968-842422349-1361404194

If you need to engage with the company that you bought the Kobuki
from, this is the number to report.

Version Mismatch
----------------

Your driver may give you a **warning** when it detects that your
firmware's minor version is behind the latest supported by your driver:

.. code-block:: bash

   Robot firmware is outdated; we suggest you to upgrade it
   (hint: https://kobuki.readthedocs.io/en/devel/firmware.html)
   Robot firmware version is 1.0.0, latest version is 1.2.0.

or **error** if a major version upgrade is required (usually
indicative of a :ref:`protocol-section` change):

.. code-block:: bash

   Robot firmware is outdated and needs to be upgraded
   (hint: https://kobuki.readthedocs.io/en/devel/firmware.html)
   Robot firmware version is 1.0.0, latest version is 1.2.0.

If this happens, then refer to the upgrade instructions in :ref:`firmware-section`. 

Malformed Payload
-----------------

A malformed payload error occurs when Kobuki receives an unexpected byte or series
of bytes in the long packets arriving on the serial connection. A typical error
message will look something like:

.. code-block:: bash

   [ERROR] Kobuki : malformed sub-payload detected. [225][170][E1 AA 55 4D 01 0F ]
   [ERROR] Kobuki : malformed sub-payload detected. [42][170][2A AA 55 4D 01 0F ]
   [ERROR] Kobuki : malformed sub-payload detected. [94][170][5E AA 55 4D 01 0F ]
   [ERROR] Kobuki : malformed sub-payload detected. [63][170][3F AA 55 4D 01 0F C0 E8 00 00 00 ]

This is usually due to one of two causes:

1. Old or overly long cables
2. An FTDI driver configured with long latency

The first problem is easily diagnosed - simply try replacing cables (to be certain, ensure the
cable length is under 2m). 

The second problem is also easily diagnosed:

.. code-block:: bash

   # Replace ttyUSB0 with ttyUSB# if it's not on the first port
   $ cat /sys/bus/usb-serial/devices/ttyUSB0/tty/ttyUSB0/device/latency_timer
   # If you see 16, your udev rule has not configured a non-default value (too slow!)
   16

This was caused by a change in the kernel post the kobuki release which switched the
default latency from 1ms to 16ms. As a result, the throughput is sub-optimal for
Kobuki's use case. See `kobuki#382 <https://github.com/yujinrobot/kobuki/issues/382>`_
for more details (only if you're curious!).

The udev rules for Kobuki have already been updated to re-configure this latency for
1ms. If you're seeing 16ms, it means you haven't yet migrated to using the new
udev rules.

Simply grab a copy of the new udev
rule `60-kobuki.rules <https://github.com/kobuki-base/kobuki_ftdi/blob/devel/60-kobuki.rules>`_
and:

.. code-block:: bash

   # copy across udev rules
   > sudo cp 60-kobuki.rules /etc/udev/rules.d
   > sudo service udev reload
   > sudo service udev restart

The key change is in the addition of a :maroon:`ATTR{device/latency_timer}="1"` field in the rule.

