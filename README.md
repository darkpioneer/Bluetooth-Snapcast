# Raspberry Pi Bluetooth Audio Routing to Snapserver

## Overview
This documentation outlines the steps to set up a Raspberry Pi to route Bluetooth audio input to a null-sink and then forward it to a Snapserver using a pipe or netcat (nc).  
This setup is ideal for creating a wireless multi-room audio system.

## Motivation

### The Need
My journey began with a personal need: to stream audio from locally connected Bluetooth devices, like my phone, across multiple devices on my network. This was particularly important for enjoying podcasts and audiobooks seamlessly in different areas of my home.

### The Solution
This project addresses that need by enabling the Raspberry Pi to act as a bridge, streaming Bluetooth audio to all Snapclients on the network. Additionally, for an integrated experience, it allows for looping back the Bluetooth audio to the same Raspberry Pi. This is achieved by running Snapclient on the Pi itself and setting the appropriate source, ensuring a cohesive multi-room audio experience.


## Prerequisites
- Raspberry Pi with Bluetooth capability.
- Snapserver installed on the network.
- Basic knowledge of Linux command line and editing files.

## Configuration Steps

### Configure Bluetooth on the Raspberry Pi

#### Install the bluetooth modules

```sudo apt-get install pulseaudio pulseaudio-module-bluetooth```

#### Add our user to the bluetooth group and reboot

```
sudo usermod -a -G bluetooth $USER
sudo reboot
```

#### Set to be always be discoverable as an A2DP sink

Edit the file `/etc/bluetooth/main.conf` with the following content:

```
Class = 0x20041C
DiscoverableTimeout = 0
AlwaysPairable = true
PairableTimeout = 0
```
Bluetooth CoD can be checked and generated with this service   
https://www.ampedrftech.com/cod.htm

#### Set Bluetooth Device Name

Create or edit the file /etc/machine-info and add the following line to set your device's Bluetooth name:

```
PRETTY_HOSTNAME=<DEVICE NAME>
```

#### Restart bluetooth

```sudo systemctl restart bluetooth```

#### Create Bluetooth Auth Service

Create the file /etc/systemd/system/bt-agent.service.  

```
[Unit]
Description=Bluetooth Auth Agent
After=bluetooth.service
PartOf=bluetooth.service

[Service]
Type=simple
ExecStart=/usr/bin/bt-agent -c NoInputNoOutput

[Install]
WantedBy=bluetooth.target
```

#### Register and Activate Service

```
sudo systemctl enable bt-agent
sudo systemctl start bt-agent
sudo systemctl status bt-agent
```

## Configure Snapserver to receive audio stream

#### Edit Snapserver Configuration

Edit the file /etc/snapserver.conf to match your desired settings.

```
stream = tcp://0.0.0.0:3333?name=<SOURCE_NAME>&sampleformat=44100:16:2
```

To find the bluetooth sampleformat, play audio on the paired device and use the command 
```
pactl list sink-inputs
```

If the sampe rate is mismatched you will get buffering issues

## Configure PulseAudio

#### Edit Default PulseAudio Configuration

Edit /etc/pulse/default.pa to include:

```
load-module module-null-sink sink_name=BluetoothSink sink_properties=device.description=Bluetooth-Audio-Sink
```

#### Set Null-Sink as Default

Use the following commands:

```
pacmd list-sinks
pacmd set-default-sink 0
```

### Stream Audio to Snapserver

```
parec -d BluetoothSink.monitor | nc SERVERIP 3333
```

### Caution

The provided auto-remove-bt.sh script will remove all Bluetooth devices that are not currently connected. Use with caution, as it might require re-pairing of devices.

## Sources and Inspiration

Another How to turn your Pi in a Bluetooth Speaker Tutorial  
https://forums.raspberrypi.com/viewtopic.php?t=235519

This project's documentation and some scripts were initially developed with the help of ChatGPT, an AI language model by OpenAI. The model provided foundational structure and code examples, which were subsequently modified and expanded for this specific application.


### Contributing

Contributions to this project are welcome. Please feel free to fork the repository and submit pull requests.

### License

MIT License

Copyright (c) 2024 Tom Lincoln

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

### Contact/Support

For questions or support regarding this project, please open an issue in the GitHub repository.