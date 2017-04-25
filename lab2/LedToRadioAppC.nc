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
  components new AMSenderC(AM_BLINKTORADIO);
  components new AMReceiverC(AM_BLINKTORADIO);
  components new DemoSensorC() as Sensor;
  components new AccelXStreamC(), SounderC; // the mts300 board parts

  App.Boot -> MainC;
  App.Leds -> LedsC;
  App.Timer0 -> Timer0;
  App.Packet -> AMSenderC;
  App.AMPacket -> AMSenderC;
  App.AMSend -> AMSenderC;
  App.Receive -> AMReceiverC;
  App.AMControl -> ActiveMessageC;
  App.Read -> Sensor;
  App.ReadStream -> AccelXStreamC;
  App.Mts300Sounder -> SounderC;
}
