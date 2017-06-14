### Teensy Recording

The goal of this project sub folder is to get Teensy sending it's audio buffer to my laptop and recording it as .wav files for later ingest into my ML library for classification.

#### Proccess:
- [x] Install Toolchain (PortAudio v19, audioteensy env, pyaudio)
- [x] Make a simple .wav player
- [x] PyAudio Simple Recorder (from Laptop Mic)
- [x] PyAudio Script to get available inputs (to verify teensy input)
- [ ] Get the teensy to send audio buffer to computer
- [ ] Playback the Recording
