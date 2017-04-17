#include <Timer.h>
#include "LedToRadio.h"

configuration LedToRadioAppC {
}
implementation {
  components MainC;
  components LedsC;
  components LedToRadioC as App;
  components new TimerMilliC() as Timer0;
  components ActiveMessageC;
  components new AMSenderC(AM_LEDTORADIOMSG);
  components new AMReceiverC(AM_LEDTORADIOMSG);
  /*components new DemoSensorC() as Sensor;*/
  components new PhotoC() as Sensor;

  App.Boot -> MainC;
  App.Leds -> LedsC;
  App.Timer0 -> Timer0;
  App.Packet -> AMSenderC;
  App.AMPacket -> AMSenderC;
  App.AMSend -> AMSenderC;
  App.Receive -> AMReceiverC;
  App.AMControl -> ActiveMessageC;
  App.Read -> Sensor;
}
