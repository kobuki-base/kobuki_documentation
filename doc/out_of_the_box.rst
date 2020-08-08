Out of the Box
==============

.. WARNING:: Be aware of the :ref:`safety-guidelines`.

Charging
--------
Connect the power adapter to Kobuki or dock Kobuki in the docking station. If Kobuki is turned on, you will hear a short sound when charging starts and the LED will light up appropriately.

.. |blink green| replace:: :blink-green:`Blinking Green`

+------------------+---------------+
| LED Color        | Status        |
+==================+===============+
| :green:`Green`   | fully charged |
+------------------+---------------+
| |blink green|    | charging      |
+------------------+---------------+
| :orange:`Orange` | low battery   |
+------------------+---------------+

.. note:: The battery still charges if Kobuki is off, but you will not see the LED, nor hear sounds

First Run
---------

You want to see Kobuki in action without further ado? Kobuki has a special random walker mode embedded
into the firmware which you can activate on start-up:

 * Disconnect the power cable
 * Turn on Kobuki.
 * Within the first 3 seconds press the B0 button and hold for 2 seconds.
 * LED2 will start blinking and Kobuki wander around.

.. note::

   This was introduced to the firmware in v1.1.0. In case your kobuki is not running this or a
   later version, please refer to :ref:`updating-firmware`.

