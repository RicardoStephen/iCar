iCar
====
The iCar is an RC car that can be controlled over bluetooth via a custom
Swift-based iOS application. It was a week-long project I worked on to 
experiment with the PSoC BLE Pioneer Kit I received at a workshop. A demo of the
first version of the iCar can be found at 
<https://www.youtube.com/watch?v=cJSokr4q-1Q> and a demo of the second version
can be found at <https://www.youtube.com/watch?v=uOKSZv3pq9I>. I also completed
the iCar without purchasing any new parts specifically for it, any measurement
devices, or even specifications for the motors I was using. This lack of 
resources resulted in a significant prototyping stage with an Arduino Micro 
before implementation with the PSoC 4 BLE module. Also, it forced me to be
creative with what I had.

![iCar version 1](https://github.com/RicardoStephen/iCar/blob/master/media/Portrait_v1.jpg)
*Figure 1: iCar version 1*

![iCar version 2](https://github.com/RicardoStephen/iCar/blob/master/media/Portrait_v2.jpg)
*Figure 2: iCar version 2*

**Chassis** The chassis was from a Tamiya Tracked Vehicle Chassis Kit. The kit
originally came with a single motor to drive the two rear wheels, but a
different pair of motors was used so the two wheels could be controlled
independently.

**H-Bridge** The schematic for the h-bridges can be seen in *Figure 3*, and the
associated schem file was designed using gEDA. For an ideal h-bridge, N-MOSFETs
would have been used for their higher switching speeds, efficiency, and power
ratings. However, none were available, so a heterogeneous set of NPN and PNP
transistors were used instead.

**Power Supply** Three 9V batteries with a common ground were used to power the
vehicle. One battery powered the PSoC board, and the other two were each sent
through a 5V regulator to supply each h-bridge. From testing, it was not so
clear that the third battery was required for the h-bridge, but it was
nevertheless included for mechanical balance and longer battery life. 

**PSoC Design** The PSoC 4 BLE module was used for motor control and
connectivity to an iOS device over bluetooth. The PSoC schematic can be found in
*Figure 4* and the representative firmware can be found in the
<tt>Cypress\_PSoC</tt> directory. While these files are a good summary of the
system, the whole project required by PSoC Creator can be found in the
<tt>Cypress\_PSoC/motor\_control.cydsn</tt> directory. 

**Bluetooth Interface** The bluetooth interface between the iCar and the iOS
application was composed of a custom bluetooth service with one characteristic.
This characteristic was associated with a 5-byte long attribute encoding control
information for the two motors:

> [on/off] [1A/1B] [PWM1] [2A/2B] [PWM2]

where each "[]" is a byte, and [x/y] is x if the byte is 1 or y if 0.

**User Interface** The iCar can be controlled by the Swift-based iOS application
associated with the <tt>iCar.xcodeproj</tt> XCode project. Scenes from the
application can be seen in Figures 5-7. The application communicates with the
iCar over bluetooth using the CoreBluetooth library. The user can control the
speed of the car by setting it directly via the slider or using the accelerate
and break buttons. There is also a five-segment control to determine if the iCar
drives in reverse, turns left, stops, turns right, or drives forward. Also, the
CoreMotion library allows users to control the direction of the iCar by tilting
the iPhone. 

In the demo of iCar version 1, the motor stalled a number of times; it was not
clear that the motors were powerful enough for the application. The tracks
accounted for most of the load on the motors, since it was observed that the
motors can spin quickly without the tracks. Because the motors were not very
powerful, the algorithm to control the angle of the iCar via the CoreMotion
library did not work as expected. Nevertheless, it was still a meaningful
experience prototyping, implementing, and debugging all of the the subsystems
required for the first version.

The tracks were removed in iCar version 2 in order to achieve higher speeds and
fewer stalls. While this was achieved, the design could have been greatly
improved with better resources. The rear wheels of the iCar were surrounded by
two layers of the track, and then by two layers of double-faced foam tape. This
was required to increase the radius of the wheel so that the base of the vehicle
would not touch the ground. However, the design did not have much traction,
resulting in a significant amount of slipping that bottlenecked the vehicle's
speed and navigation capabilities. In future designs, this could be rectified by
using wheels with better traction.

![iCar h-bridge schematic](https://github.com/RicardoStephen/iCar/blob/master/media/hbridge_schematic.png)
*Figure 3: H-bridge schematic*

![iCar PSoC schematic](https://github.com/RicardoStephen/iCar/blob/master/media/PSoC_schematic.png)
*Figure 4: PSoC schematic*

![iCar iOS application icon](https://github.com/RicardoStephen/iCar/blob/master/media/UX_1.jpg)

*Figure 5: iOS application icon*

![iCar iOS application launch scene](https://github.com/RicardoStephen/iCar/blob/master/media/UX_2.jpg)

*Figure 6: iOS application launch scene*

![iCar iOS application main scene](https://github.com/RicardoStephen/iCar/blob/master/media/UX_3.jpg)

*Figure 7: iOS application main scene*
