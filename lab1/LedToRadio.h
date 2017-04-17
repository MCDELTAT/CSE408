#ifndef LEDTORADIO_H
#define LEDTORADIO_H

enum {
 AM_LEDTORADIOMSG = 10,
 TIMER_PERIOD_MILLI = 250,
 AM_DEST_ADDR = 0x0007
};

typedef nx_struct LedToRadioMsg {
 nx_uint16_t nodeid;
 nx_uint16_t sensorValue;
} LedToRadioMsg;

#endif
