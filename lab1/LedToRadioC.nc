#include <Timer.h>
#include "LedToRadio.h"

module LedToRadioC {
  uses interface Boot;
  uses interface Leds;
  uses interface Timer<TMilli> as Timer0;
  uses interface Packet;
  uses interface AMPacket;
  uses interface AMSend;
  uses interface Receive;
  uses interface SplitControl as AMControl;
  uses interface Read<uint16_t>;
}

implementation {
  bool busy = FALSE;
  message_t pkt;
  uint16_t otherMoteSensorValue;

  event void Boot.booted() {
    call AMControl.start();
  }

  event void AMControl.startDone(error_t err) {
    /*otherMoteSensorValue = 0;*/
    if (err == SUCCESS) {
      call Timer0.startPeriodic(TIMER_PERIOD_MILLI);
    }
    else {
      call AMControl.start();
    }
  }

  event void AMControl.stopDone(error_t err) {
  }

  event void Timer0.fired() {
    call Read.read();
  }

  event void Read.readDone(error_t err, uint16_t sensorValue) {
    if (!busy) {
      LedToRadioMsg* btrpkt = (LedToRadioMsg*)(call Packet.getPayload(&pkt, sizeof (LedToRadioMsg)));
      btrpkt->nodeid = TOS_NODE_ID;
      btrpkt->sensorValue = sensorValue;
      if (call AMSend.send(AM_DEST_ADDR, &pkt, sizeof(LedToRadioMsg)) == SUCCESS) {
        // Set Red LED (LED0)
        call Leds.led0On();
        busy = TRUE;
      }
    }
  }

  // Automatically called event flag for when send is completed
  event void AMSend.sendDone(message_t* msg, error_t error) {
    if (&pkt == msg) {
      // Turn off the led to indicate the send is completed
      call Leds.led0Off();
      busy = FALSE;
    }
  }

  event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len) {
    if (len == sizeof(LedToRadioMsg)) {
      LedToRadioMsg* btrpkt = (LedToRadioMsg*)payload;
      //if recieving from mote w sensor, alarm
      /*call Leds.led2Toggle();*/
      if (btrpkt->nodeid == 8) {
        otherMoteSensorValue = btrpkt->sensorValue;
        /*call Leds.led2Toggle();*/
        if (otherMoteSensorValue < 433) {
          call Leds.led0Toggle();
          call Leds.led1Toggle();
          call Leds.led2Toggle();
        } else {
          call Leds.led0Off();
          call Leds.led1Off();
          call Leds.led2Off();
        }
      } else {
        //do nothing because wo a sensor it will send garbage values
        call Leds.led0Off();
        call Leds.led1Off();
        call Leds.led2Off();
      }
    }
    return msg;
  }
}
