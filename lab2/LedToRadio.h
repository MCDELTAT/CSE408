#ifndef LEDTORADIO_H
#define LEDTORADIO_H

enum {
 AM_BLINKTORADIO = 6,
 TIMER_PERIOD_MILLI = 250,
 AM_DEST_ADDR = 0xFFFF,
 DETECT_ACCEL = 2,
 DEFAULT_DETECT = DETECT_ACCEL
};

typedef nx_struct LedToRadioMsg {
 nx_uint16_t nodeid;
 nx_uint16_t sensorValue;
} LedToRadioMsg;

typedef nx_struct settings {
  nx_uint8_t detect;
} settings_t;

#endif
