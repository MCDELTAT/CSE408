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
  uses interface ReadStream<uint16_t>;
  uses interface Mts300Sounder;
}

implementation {
  enum {
    /* Number of acceleration samples to collect */
    ACCEL_SAMPLES = 10,

    /* Interval between acceleration samples (us) */
    ACCEL_INTERVAL = 10000
  };

  bool busy = FALSE;
  message_t pkt;
  settings_t settings;
  uint16_t otherSensorValue = 0;
  uint16_t accelSamples[ACCEL_SAMPLES];

  event void Boot.booted() {
    call AMControl.start();
    settings.detect = 5; //this will make it so it doesn't send accel data right now
  }

  event void AMControl.startDone(error_t err) {
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
    call Read.read(); //call this to read from light sensor.
    if (settings.detect == DETECT_ACCEL) {
      call ReadStream.postBuffer(accelSamples, ACCEL_SAMPLES);
    	call ReadStream.read(ACCEL_INTERVAL);
    }
  }

  // The event for reading the photo sensor
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

  /* Report theft, based on current settings */
  void theft(uint32_t variance) {
    // call the beeper
    // call Mts300Sounder.beep(100);
    // if the radio isn't busy, then send a packet with the variance detetected
    // in the checkAcceleration function. It should be small enough to be distinguished
    // the light sensor.
    if (!busy) {
      LedToRadioMsg* btrpkt = (LedToRadioMsg*)(call Packet.getPayload(&pkt, sizeof (LedToRadioMsg)));
      btrpkt->nodeid = TOS_NODE_ID;
      btrpkt->sensorValue = variance;
      if (call AMSend.send(AM_DEST_ADDR, &pkt, sizeof(LedToRadioMsg)) == SUCCESS) {
        // Set Red LED (LED0)
        call Leds.led0On();
        busy = TRUE;
      }
    }
  }

  /* A deferred task to check the acceleration data and detect theft. */
  task void checkAcceleration() {
    uint8_t i;
    uint16_t avg;
    uint32_t var;

    /* We check for theft by checking whether the variance of the sample
       (in mysterious acceleration units) is > 4 */

    for (avg = 0, i = 0; i < ACCEL_SAMPLES; i++)
      avg += accelSamples[i];
      avg /= ACCEL_SAMPLES;

    for (var = 0, i = 0; i < ACCEL_SAMPLES; i++) {
	    int16_t diff = accelSamples[i] - avg;
	    var += diff * diff;
    }

    if (var > 4 * ACCEL_SAMPLES)
      theft(var); /* ALERT! ALERT! */
  }

  /* The acceleration read completed. Post the task that will check for
     theft. We defer this somewhat cpu-intensive computation to avoid
     having the current task run for too long. */
  event void ReadStream.readDone(error_t ok, uint32_t usActualPeriod) {
    if (ok == SUCCESS)
      post checkAcceleration();
  }

  /* The current sampling buffer is full. If we were using several buffers,
     we would switch between them here. */
  event void ReadStream.bufferDone(error_t ok, uint16_t *buf, uint16_t count) { }

  event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len) {
    if (len == sizeof(LedToRadioMsg)) {
      //do nothing this time because MATLAB will be carrying out the sensor handling
    }
    return msg;
  }
}
