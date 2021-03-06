Conversions
===========

Encoder2Pose
------------

Here are the necessary parameters and calcualations for conversion of
encoder ticks to robot pose.


+----------------------+-----------------------+-------------------------------------+-----------------------------------------------------------------+
|                      | Name                  | Value                               | Description                                                     |
+======================+=======================+=====================================+=================================================================+
| **Robot Parameters** | wheelbase (bias)      | 230mm                               | length between the centre of the wheels                         |
+----------------------+-----------------------+-------------------------------------+-----------------------------------------------------------------+
|                      | wheel radius          | 35mm                                |                                                                 |
+----------------------+-----------------------+-------------------------------------+-----------------------------------------------------------------+
|                      | wheel width           | 21mm                                |                                                                 |
+----------------------+-----------------------+-------------------------------------+-----------------------------------------------------------------+
| **Magnetic Encoder** | ticks per revolution  | 52 tick/rev                         |                                                                 |
+----------------------+-----------------------+-------------------------------------+-----------------------------------------------------------------+
|                      | pulses per revolution | 13 pulse/rev                        |                                                                 |
+----------------------+-----------------------+-------------------------------------+-----------------------------------------------------------------+
| **Gear Box**         | 1st stage             | 1:10                                |                                                                 |
+----------------------+-----------------------+-------------------------------------+-----------------------------------------------------------------+
|                      | 2nd stage             | 22:12                               |                                                                 |
+----------------------+-----------------------+-------------------------------------+-----------------------------------------------------------------+
|                      | 3rd stage             | 30:11                               |                                                                 |
+----------------------+-----------------------+-------------------------------------+-----------------------------------------------------------------+
|                      | 4th stage             | 35:12                               |                                                                 |
+----------------------+-----------------------+-------------------------------------+-----------------------------------------------------------------+
|                      | 5th stage             | 34:1                                |                                                                 |
+----------------------+-----------------------+-------------------------------------+-----------------------------------------------------------------+
|                      | resultant ratio       | 6545/132 = 49.5833                  | 6545 turns of motors(or encoders) will make 132 turns of wheels |
+----------------------+-----------------------+-------------------------------------+-----------------------------------------------------------------+
| **Conversions**      | ticks to metres       | 0.000085292090497737556558 m/tick   |                                                                 |
+----------------------+-----------------------+-------------------------------------+-----------------------------------------------------------------+
|                      | ticks to radians      | 0.002436916871363930187454 rad/tick |                                                                 |
+----------------------+-----------------------+-------------------------------------+-----------------------------------------------------------------+
|                      | metres to ticks       | 11724.41658029856624751591 tick/m   |                                                                 |
+----------------------+-----------------------+-------------------------------------+-----------------------------------------------------------------+
|                      | radian to ticks       | 11.72441658029856624751591 tick/mm  |                                                                 |
+----------------------+-----------------------+-------------------------------------+-----------------------------------------------------------------+
