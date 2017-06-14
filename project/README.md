### CSE408 Final Project
### Sound Based Smart Alarm

The goal of this project is to create a working, functional alarm system that is tripped through audio cues. The armed state of the alarm is controlled by whether a chosen device is on the local WiFi network or not. For example, if a phone is present, then the person who owns the phone is home and the alarm will disarm.

Our goal is to be able to detect the sounds of breaking glass, of a door opening, and footsteps, all of which indicate someone's presence while the alarm is armed.

The folder breakdown is as follows:
* src: The final code that will run on our Teensy 3.6 device to carry out the system functionalities.
* brd: The files for the PCB board that will be CNC milled for this Project.
* case: The 3D design files required to print the case in which we hope to mount the project.
* Documents: Presentation Documents

### Installation:
#### Hardware:
All of the python code can be run off of a laptop microphone or webcam, or an arduino. The arduino must simply be a modern version that allows for the USB Host Driver on the AVR chip to be overwritten. A few of these boards include the Arduino Uno, Mega 2560, or Pro Mini. We will be using the [LUFA][LUFA] framwork to make the arduino a USB audio device. 

#### Software:
1) Python: There are many prerequisites for the software that I built. I recommend using Anaconda on a Linux system, as it will simplify configuration. We must use Python 2.7, as some of the dependencies only work in this version. Download the package for your system [here.][anaconda]

Create a virtual environment with the following command:
```
conda create --name [appname] python=2
```
then activate it with
```
source activate [appname]
```

2) PyAudio: This is an interface between the soundcard, the PortAudio driver and Python. To install it, follow the instruction [here.][pyaudio]

3) You will need to install FFMPEG, as some of the dependencies for the next package require it. On linux it's as easy as running
```
sudo apt-get install ffmpeg
```
If the package is not available with your distribution, then follow the instructions [here.][ffmpeg]

4) Finally the machine learning framework I am using is pyAudioAnalysis to install it, first install dependencies with ```pip install numpy matplotlib scipy sklearn hmmlearn simplejson eyed3 pydub ```

then run the following
```
git clone https://github.com/tyiannak/pyAudioAnalysis.git
```

More information on pyAudioAnalysis installation can be found [here.][pyAudioAnalysis]

If you are running the code from this repository, then note that I included the library to resolve pathing issues and simplify installation.

### How to Run:
#### Computer Input Audio:
If your laptop has a built in microphone or webcam, it will simplify the debugging process quite a bit. If this is the case, then you can simply run the application by the following:
```
python2 pyaudiorecord.py
```
simply speak into your microphone, and it will record the audio as a .wav file, and then determine if the voice is male or female.

#### Arduino Input Audio
If you configured an arduino as specified above, you can use it as audio input device on your system. Simply set this audio device as the default device, and then run my script again. I have included a utility script to verify the device is seen by the PortAudio driver. You can run this with:
```
python2 pyaudiodevicelist.py
```


[anaconda]: https://www.continuum.io/downloads
[ffmpeg]: https://www.ffmpeg.org/download.html
[LUFA]: http://www.fourwalledcubicle.com/LUFA.php
[pyaudio]: https://people.csail.mit.edu/hubert/pyaudio/#downloads
[pyAudioAnalysis]: https://github.com/tyiannak/pyAudioAnalysis
