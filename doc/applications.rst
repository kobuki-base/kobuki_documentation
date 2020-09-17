Creating Applications
=====================

Chirp
-----

About
^^^^^

This example merely configures and establishes a connection
to Kobuki which will cause it to chirp, pause for five
seconds and then emit the corresponding shutdown chirp.
First though, some information about the library
and the API that will be useful to get you started.

The Kobuki Library
^^^^^^^^^^^^^^^^^^

The nature of the computational resources you have as well
as your application's use case can have a significant
impact on how you design your application, especially for
details around the control loop. For this reason, the
library does not endeavour to provide a control loop
(that is up to you) and as such, :maroon:`libkobuki.so`
is simply one of classes, data structures, simple functions
and collaback-oriented sigslot mechanisms.

The Kobuki Class
^^^^^^^^^^^^^^^^

The :maroon:`kobuki:Kobuki` class is the first port of call
for developing your application. Configuration and non-callback
modes of interaction are handled via this class. Callback modes
are handled by sigslots, mroe on these later.

Initialisation & Configuration
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Kobuki configuration is handled by the :maroon:`kobuki:Parameters`
class which is passed ot the kobuki instance via the
:maroon:`kobuki::Kobuki::init()` method. Most of the parameters to be
configured have sane defaults.

The only one that requires frequent configuration is the serial device
port. If you aren't using a udev rule to guarantee discovery
at :maroon:`/dev/kobuki`, then you'll typically find Kobuki at
:maroon:`COM1` (windows) or :maroon:`/dev/ttyUSB0` (linux).

Code
^^^^

.. code-block:: c++

   #include <iostream>
   #include <string>
   #include <ecl/time.hpp>
   #include <ecl/command_line.hpp>
   #include <kobuki_core/kobuki.hpp>
   
   class KobukiManager
   {
   public:
     KobukiManager(const std::string &device)
     {
       kobuki::Parameters parameters;
       // Specify the device port, default: /dev/kobuki
       parameters.device_port = device;
   
       // Other parameters are typically happy enough as defaults, some examples follow
       //
       // namespaces all sigslot connection names, default: /kobuki
       parameters.sigslots_namespace = "/kobuki";
       // Most use cases will bring their own smoothing algorithms, but if
       // you wish to utilise kobuki's minimal acceleration limiter, set to true
       parameters.enable_acceleration_limiter = false;
       // Adjust battery thresholds if your levels are significantly varying from factory settings.
       // This will affect led status as well as triggering driver signals
       parameters.battery_capacity = 16.5;
       parameters.battery_low = 14.0;
       parameters.battery_dangerous = 13.2;
   
       // Initialise - exceptions are thrown if parameter validation or initialisation fails.
       try
       {
         kobuki.init(parameters);
       }
       catch (ecl::StandardException &e)
       {
         std::cout << e.what();
       }
     }
   private:
     kobuki::Kobuki kobuki;
   };
   
   int main(int argc, char **argv)
   {
     ecl::CmdLine cmd_line("chirp", ' ', "0.2");
     ecl::ValueArg<std::string> device_port(
         "p", "port",
         "Path to device file of serial port to open",
         false,
         "/dev/kobuki",
         "string"
     );
     cmd_line.add(device_port);
     cmd_line.parse(argc, argv);
   
     KobukiManager kobuki_manager(device_port.getValue());
     ecl::Sleep()(5);
     return 0;
   }

Events & Streams
----------------

About
^^^^^

The next two applications make use of the callback handles provided
by the core Kobuki class for listening in to events and streams
from the Kobuki. This is done by registering callbacks with the
`sigslots <https://wiki.ros.org/ecl_sigslots>`_ framework.

Signals and Slots
^^^^^^^^^^^^^^^^^

The kobuki driver establishes a set of signals on uniquely labelled
channels. Each channel consists of two parts. The first part
represents the namespace, which can be customised via the 
:maroon:`sigslots_namespace` variable in the :maroon:`kobuki::Parameter` structure.
The second uniquely identifies the signal itself.

The following represent the available signals along with the type of data they transmit
when namespaced under the default namespace, "/kobuki".

**The Sensor Stream**

* :maroon:`/kobuki/stream_data [void]`

The :maroon:`stream_data` channel signals that a new data packet has arrived
and is ready to be processed. These data packets are sent periodically and
are include a composited payload containing data from all sensor streams.
This is a special case, in that the type associated
with the signal does not represent the data that has been collected, but just that
it has arrived. This data can be fetched
from within the callback connected to this signal via
:maroon:`Kobuki::getCoreSensorData()` which returns a
:maroon:`kobuki::CoreSensors::Data` structure holding all the important sensor information
for the Kobuki. 

 
**General Purpose Signals**

* :maroon:`/kobuki/ros_debug [std::string]`
* :maroon:`/kobuki/ros_info [std::string]`
* :maroon:`/kobuki/ros_warn [std::string]`
* :maroon:`/kobuki/ros_error [std::string]`
* :maroon:`/kobuki/version_info [kobuki::VersionInfo]`: communicated only on request

**Event Handling Signals** 

* :maroon:`/kobuki/button_event [kobuki::ButtonEvent]`
* :maroon:`/kobuki/bumper_event [kobuki::BumperEvent]`
* :maroon:`/kobuki/cliff_event [kobuki::CliffEvent]`
* :maroon:`/kobuki/wheel_event [kobuki::WheelEvent]`
* :maroon:`/kobuki/power_event [kobuki::PowerEvent]`
* :maroon:`/kobuki/input_event [kobuki::InputEvent]`
* :maroon:`/kobuki/robot_event [kobuki::RobotEvent]`

These fire only when an event occurs.

Wheel events occur when the wheel position toggles between compressed and uncompressed
(e.g. when you lift the robot from the floor). Input events correspond to gpio state
changes (useful when you are customising Kobuki with additional sensors that can send
binary signals to your program). 

**Slots**

The kobuki driver does not establish any slots, that part is up to you and is
demonstrated in the following program.

Code - Button Events
^^^^^^^^^^^^^^^^^^^^

.. code-block:: c++

   #include <iostream>
   #include <random>
   #include <string>
   #include <vector>
   
   #include <ecl/command_line.hpp>
   #include <ecl/time.hpp>
   #include <ecl/sigslots.hpp>
   
   #include <kobuki_core/kobuki.hpp>
   
   class KobukiManager
   {
   public:
     KobukiManager(const std::string &device) :
         slot_button_event(&KobukiManager::processButtonEvent, *this)
     {
       kobuki::Parameters parameters;
       parameters.device_port = device;
   
       try
       {
         kobuki.init(parameters);
       }
       catch (ecl::StandardException &e)
       {
         std::cout << e.what();
       }
       slot_button_event.connect("/kobuki/button_event");
     }
   
     /*
      * Nothing to do in the main thread, just put it to sleep
      */
     void spin()
     {
       ecl::Sleep sleep(1);
       while (true)
       {
         sleep();
       }
     }
   
     /*
      * Catches button events and prints a curious message to stdout.
      */
     void processButtonEvent(const kobuki::ButtonEvent &event)
     {
       std::vector<std::string> quotes = {
         "That's right buddy, keep pressin' my buttons. See what happens!",
         "Anything less than immortality is a complete waste of time",
         "I can detect humour, you are just not funny",
         "I choose to believe ... what I was programmed to believe",
         "My story is a lot like yours, only more interesting ‘cause it involves robots.",
         "I wish you'd just tell me rather trying to engage my enthusiasm with these buttons, because I haven't got one.",
       };
       std::random_device r;
       std::default_random_engine generator(r());
       std::uniform_int_distribution<int> distribution(0, 5);
       if (event.state == kobuki::ButtonEvent::Released ) {
         std::cout << quotes[distribution(generator)] << std::endl;
       }
     }
   
   private:
     kobuki::Kobuki kobuki;
     ecl::Slot<const kobuki::ButtonEvent&> slot_button_event;
   };
   
   int main(int argc, char **argv)
   {
     ecl::CmdLine cmd_line("buttons", ' ', "0.1");
     ecl::ValueArg<std::string> device_port(
         "p", "port",
         "Path to device file of serial port to open",
         false,
         "/dev/kobuki",
         "string"
     );
     cmd_line.add(device_port);
     cmd_line.parse(argc, argv);
   
     KobukiManager kobuki_manager(device_port.getValue());
     kobuki_manager.spin();
     return 0;
   }


Code - The Sensor Stream
^^^^^^^^^^^^^^^^^^^^^^^^


.. code-block:: c++

   #include <iostream>
   #include <string>
   
   #include <ecl/command_line.hpp>
   #include <ecl/time.hpp>
   #include <ecl/sigslots.hpp>
   
   #include <kobuki_core/kobuki.hpp>
   
   class KobukiManager
   {
   public:
     KobukiManager(const std::string &device) :
         slot_stream_data(&KobukiManager::processStreamData, *this)
     {
       kobuki::Parameters parameters;
       parameters.device_port = device;
   
       try
       {
         kobuki.init(parameters);
       }
       catch (ecl::StandardException &e)
       {
         std::cout << e.what();
       }
       slot_stream_data.connect("/kobuki/stream_data");
     }
   
     /*
      * Nothing to do in the main thread, just put it to sleep
      */
     void spin()
     {
       ecl::Sleep sleep(1);
       while (true)
       {
         sleep();
       }
     }
   
     /*
      * Called whenever the kobuki receives a data packet.
      * Up to you from here to process it.
      */
     void processStreamData()
     {
       kobuki::CoreSensors::Data data = kobuki.getCoreSensorData();
       std::cout << "Encoders [" << data.left_encoder << "," << data.right_encoder << "]" << std::endl;
     }
   
   private:
     kobuki::Kobuki kobuki;
     ecl::Slot<> slot_stream_data;
   };
   
   int main(int argc, char **argv)
   {
     ecl::CmdLine cmd_line("buttons", ' ', "0.1");
     ecl::ValueArg<std::string> device_port(
         "p", "port",
         "Path to device file of serial port to open",
         false,
         "/dev/kobuki",
         "string"
     );
     cmd_line.add(device_port);
     cmd_line.parse(argc, argv);
   
     KobukiManager kobuki_manager(device_port.getValue());
     kobuki_manager.spin();
     return 0;
   }

A Simple Control Loop
---------------------

About
^^^^^

This example demonstrates how to process kobuki's pose data
and based on the current pose, computes and sends the
appropriate wheel commands to the robot, i.e. it closes the loop
between sensing and control.

Code
^^^^

Engage and watch Kobuki move around a dead-reckoned
square with sides of length 1.0m.

.. code-block:: c++

   #include <string>
   #include <csignal>
   #include <ecl/geometry.hpp>
   #include <ecl/time.hpp>
   #include <ecl/sigslots.hpp>
   #include <ecl/linear_algebra.hpp>
   #include <ecl/command_line.hpp>
   #include "kobuki_core/kobuki.hpp"


   /*****************************************************************************
   ** Classes
   *****************************************************************************/

   class KobukiManager {
   public:
     KobukiManager(
         const std::string & device,
         const double &length,
         const bool &disable_smoothing
     ) :
       dx(0.0), dth(0.0),
       length(length),
       slot_stream_data(&KobukiManager::processStreamData, *this)
     {
       kobuki::Parameters parameters;
       parameters.sigslots_namespace = "/kobuki";
       parameters.device_port = device;
       parameters.enable_acceleration_limiter = !disable_smoothing;

       kobuki.init(parameters);
       kobuki.enable();
       slot_stream_data.connect("/kobuki/stream_data");
     }

     ~KobukiManager() {
       kobuki.setBaseControl(0,0); // linear_velocity, angular_velocity in (m/s), (rad/s)
       kobuki.disable();
     }

     void processStreamData() {
       ecl::linear_algebra::Vector3d pose_update;
       ecl::linear_algebra::Vector3d pose_update_rates;
       kobuki.updateOdometry(pose_update, pose_update_rates);
       ecl::concatenate_poses(pose, pose_update);
       dx += pose_update[0];   // x
       dth += pose_update[2];  // heading
       // std::cout << dx << ", " << dth << std::endl;
       // std::cout << kobuki.getHeading() << ", " << pose.heading() << std::endl;
       // std::cout << "[" << pose[0] << ", " << pose.y() << ", " << pose.heading() << "]" << std::endl;
       processMotion();
     }

     // Generate square motion
     void processMotion() {
       const double buffer = 0.05;
       double longitudinal_velocity = 0.0;
       double rotational_velocity = 0.0;
       if (dx >= (length) && dth >= ecl::pi/2.0) {
         std::cout << "[Z] ";
         dx=0.0; dth=0.0;
       } else if (dx >= (length + buffer)) {
         std::cout << "[R] ";
         rotational_velocity = 1.1;
       } else {
         std::cout << "[L] ";
         longitudinal_velocity = 0.3;
       }
       std::cout << "[dx: " << dx << "][dth: " << dth << "][" << pose[0] << ", " << pose[1] << ", " << pose[2] << "]" << std::endl;
       kobuki.setBaseControl(longitudinal_velocity, rotational_velocity);
     }

     const ecl::linear_algebra::Vector3d& getPose() {
       return pose;
     }

   private:
     double dx, dth;
     const double length;
     ecl::linear_algebra::Vector3d pose;  // x, y, heading
     kobuki::Kobuki kobuki;
     ecl::Slot<> slot_stream_data;
   };

   /*****************************************************************************
   ** Signal Handler
   *****************************************************************************/

   bool shutdown_req = false;
   void signalHandler(int /* signum */) {
     shutdown_req = true;
   }

   /*****************************************************************************
   ** Main
   *****************************************************************************/

   int main(int argc, char** argv)
   {
     ecl::CmdLine cmd_line("Uses a simple control loop to move Kobuki around a dead-reckoned square with sides of length 1.0m", ' ', "0.2");
     ecl::ValueArg<std::string> device_port(
         "p", "port",
         "Path to device file of serial port to open",
         false,
         "/dev/kobuki",
         "string"
     );
     ecl::ValueArg<double> length(
         "l", "length",
         "traverse square with sides of this size in length (m)",
         false,
         0.25,
         "double"
     );
     ecl::SwitchArg disable_smoothing(
         "d", "disable_smoothing",
         "Disable the acceleration limiter (smoothens velocity)",
         false
     );

     cmd_line.add(device_port);
     cmd_line.add(length);
     cmd_line.add(disable_smoothing);
     cmd_line.parse(argc, argv);

     signal(SIGINT, signalHandler);

     std::cout << "Demo : Example of simple control loop." << std::endl;
     KobukiManager kobuki_manager(
         device_port.getValue(),
         length.getValue(),
         disable_smoothing.getValue()
     );
   
     ecl::Sleep sleep(1);
     ecl::linear_algebra::Vector3d pose;  // x, y, heading
     try {
       while (!shutdown_req){
         sleep();
         pose = kobuki_manager.getPose();
         // std::cout << "current pose: [" << pose[0] << ", " << pose[1] << ", " << pose[2] << "]" << std::endl;
       }
     } catch ( ecl::StandardException &e ) {
       std::cout << e.what();
     }
     return 0;
   }

Decoupling the Control
^^^^^^^^^^^^^^^^^^^^^^

This program relied on the periodic sensor stream to trigger the
control commands. This results in a loop with the fewest
lines of code as well as minimum latency between pose update and
control.

Alternatively, you may wish to decopule the control from the
sensor stream callback (e.g. via the :maroon:`spin()` method). That
is also fine and usual in more complex use cases. Beware however, of
concurrency issues if using a separate thread.


Logging
-------

About
^^^^^

Kobuki provides loggers over the debug, info, warning and error signals. By
default, the software wires up stdout loggers directly to the warning and error
signals, but you can both change this log level (e.g. DEBUG will cause all
log levels to be printed to stdout) OR disable them complately and wire up slots
to your own loggers.

Code - Log Levels
^^^^^^^^^^^^^^^^^

.. code-block:: c++
   
   #include <iostream>
   #include <string>
   #include <ecl/console.hpp>
   #include <ecl/time.hpp>
   #include <ecl/command_line.hpp>
   #include <kobuki_core/kobuki.hpp>
   
   int main(int argc, char **argv)
   {
     ecl::CmdLine cmd_line("log_levels", ' ', "0.1");
     ecl::ValueArg<std::string> device_port(
         "p", "port",
         "Path to device file of serial port to open",
         false,
         "/dev/kobuki",
         "string"
     );
     cmd_line.add(device_port);
     cmd_line.parse(argc, argv);
   
     std::cout << ecl::bold << "\nLog Levels Demo\n" << ecl::reset << std::endl;
   
     kobuki::Parameters parameters;
     parameters.device_port = device_port.getValue();
     parameters.log_level = kobuki::LogLevel::DEBUG;
   
     kobuki::Kobuki kobuki;
     try {
       kobuki.init(parameters);
     } catch (ecl::StandardException &e) {
       std::cout << e.what();
     }
   
     ecl::Sleep()(5);
     return 0;
   }

Output - Log Levels
^^^^^^^^^^^^^^^^^^^

.. image:: images/demo_log_levels.png

Code - Custom Loggers
^^^^^^^^^^^^^^^^^^^^^

.. code-block:: c++
   
   #include <iostream>
   #include <string>
   #include <ecl/console.hpp>
   #include <ecl/sigslots.hpp>
   #include <ecl/time.hpp>
   #include <ecl/command_line.hpp>
   #include <kobuki_core/kobuki.hpp>
   
   class KobukiManager
   {
   public:
     KobukiManager(const std::string &device) :
       slot_debug(&KobukiManager::logCustomDebug, *this),
       slot_info(&KobukiManager::logCustomInfo, *this),
       slot_warning(&KobukiManager::logCustomWarning, *this),
       slot_error(&KobukiManager::logCustomError, *this)
     {
       kobuki::Parameters parameters;
   
       parameters.device_port = device;
       // Disable the default loggers
       parameters.log_level = kobuki::LogLevel::NONE;
   
       // Wire them up ourselves
       slot_debug.connect(parameters.sigslots_namespace + "/debug");
       slot_info.connect(parameters.sigslots_namespace + "/info");
       slot_warning.connect(parameters.sigslots_namespace + "/warning");
       slot_error.connect(parameters.sigslots_namespace + "/error");
   
       try {
         kobuki.init(parameters);
       } catch (ecl::StandardException &e) {
         std::cout << e.what();
       }
     }
   
     void logCustomDebug(const std::string& message) {
       std::cout << ecl::green << "[DEBUG_WITH_COLANDERS] " << message << ecl::reset << std::endl;
     }
   
     void logCustomInfo(const std::string& message) {
       std::cout << "[INFO_WITH_COLANDERS] " << message << ecl::reset << std::endl;
     }
   
     void logCustomWarning(const std::string& message) {
       std::cout << ecl::yellow << "[WARNING_WITH_COLANDERS] " << message << ecl::reset << std::endl;
     }
   
     void logCustomError(const std::string& message) {
       std::cout << ecl::red << "[ERROR_WITH_COLANDERS] " << message << ecl::reset << std::endl;
     }
   
   private:
     kobuki::Kobuki kobuki;
     ecl::Slot<const std::string&> slot_debug, slot_info, slot_warning, slot_error;
   };
   
   int main(int argc, char **argv)
   {
     ecl::CmdLine cmd_line("logging", ' ', "0.3");
     ecl::ValueArg<std::string> device_port(
         "p", "port",
         "Path to device file of serial port to open",
         false,
         "/dev/kobuki",
         "string"
     );
     cmd_line.add(device_port);
     cmd_line.parse(argc, argv);
   
     std::cout << ecl::bold << "\nLogging Demo\n" << ecl::reset << std::endl;
   
     KobukiManager kobuki_manager(device_port.getValue());
     ecl::Sleep()(5);
     return 0;
   }

Output - Custom Loggers
^^^^^^^^^^^^^^^^^^^^^^^

.. image:: images/demo_custom_logging.png

Debugging the Stream
--------------------

About
^^^^^

If you're having troubles with your connection and need to debug the raw data stream,
tune into the :grey:`/kobuki/raw_data_stream` signal.

Code
^^^^

.. code-block:: bash

   #include <iostream>
   #include <string>
   #include <ecl/console.hpp>
   #include <ecl/sigslots.hpp>
   #include <ecl/time.hpp>
   #include <ecl/command_line.hpp>
   #include <kobuki_core/kobuki.hpp>
   
   class KobukiManager
   {
   public:
     KobukiManager(const std::string &device) :
       slot_raw_data_stream(&KobukiManager::logRawDataStream, *this)
     {
       kobuki::Parameters parameters;
   
       parameters.device_port = device;
   
       slot_raw_data_stream.connect(parameters.sigslots_namespace + "/raw_data_stream");
   
       try {
         kobuki.init(parameters);
       } catch (ecl::StandardException &e) {
         std::cout << e.what();
       }
     }
   
     void logRawDataStream(kobuki::PacketFinder::BufferType& buffer) {
       std::ostringstream ostream;
       ostream << ecl::cyan << "[" << ecl::TimeStamp() << "] " << ecl::yellow;
       ostream << std::setfill('0') << std::uppercase;
       for (unsigned int i = 0; i < buffer.size(); i++) {
         ostream << std::hex << std::setw(2) << static_cast<unsigned int>(buffer[i]) << " " << std::dec;
       }
       ostream << ecl::reset;
       std::cout << ostream.str() << std::endl;
     }
   
   private:
     kobuki::Kobuki kobuki;
     ecl::Slot<kobuki::PacketFinder::BufferType&> slot_raw_data_stream;
   };
   
   int main(int argc, char **argv)
   {
     ecl::CmdLine cmd_line("raw_data_stream", ' ', "0.3");
     ecl::ValueArg<std::string> device_port(
         "p", "port",
         "Path to device file of serial port to open",
         false,
         "/dev/kobuki",
         "string"
     );
     cmd_line.add(device_port);
     cmd_line.parse(argc, argv);
   
     std::cout << ecl::bold << "\nRaw Data Stream Demo\n" << ecl::reset << std::endl;
   
     KobukiManager kobuki_manager(device_port.getValue());
     ecl::Sleep()(5);
     return 0;
   }

Output
^^^^^^

.. image:: images/demo_raw_data_stream.png
