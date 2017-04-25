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
    settings.detect = DEFAULT_DETECT;
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
    //call Read.read(); //call this to read from light sensor.
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
  void theft() {
    // call the beeper
    // call Mts300Sounder.beep(100);
    // if the radio isn't busy, then send a packet with a known value
    // we can then pick up this known value and handle control with it.
    if (!busy) {
      LedToRadioMsg* btrpkt = (LedToRadioMsg*)(call Packet.getPayload(&pkt, sizeof (LedToRadioMsg)));
      btrpkt->nodeid = TOS_NODE_ID;
      btrpkt->sensorValue = 12345; // simply because it's a memorable value
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
      theft(); /* ALERT! ALERT! */
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
      LedToRadioMsg* btrpkt = (LedToRadioMsg*)payload;
      if (btrpkt->nodeid == 8 || btrpkt->nodeid == 7) {
        // Only blink the Leds on the reciever
        otherSensorValue = btrpkt->sensorValue;
        // it came from the light sensor
        if (otherSensorValue < 600) {
          call Leds.led0Toggle();
          call Leds.led1Toggle();
          call Leds.led2Toggle();
        }
        // it came from the theft function from the accelerometer
        if (otherSensorValue == 12345) {
          call Mts300Sounder.beep(100);
          call Leds.led0Toggle();
          call Leds.led1Toggle();
          call Leds.led2Toggle();
        }
      }
    }
    return msg;
  }
}
