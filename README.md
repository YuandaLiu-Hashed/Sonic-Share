# Sonic-Share

This is an iOS and macOS(Catalyst) app.
The sharing mechanism is not limited to the apple system as the audio implementation is largely in C/C++.
The app (currently) only works for 44.1khz and 48khz audio input and outputs. The app will crash on macOS if the sample rate is larger or smaller. Changing the sample rate in Audio & Midi Setup to either of the supported sample rates will fix the issue. 

## Inspiration
The inspiration for this project comes from the old phone-based modem internet. In the olden days, one would yank their cabled phone into a modem box, and data is transmitted through audio waves. It was a genius solution because it manages to provide internet through phone cables, which were already readily available back then, unlike internet cables. The phone modem is essentially a speaker and a microphone that "talk on the phone". Guess what also has a speaker and a microphone? Yes, literally ALL modern devices have a decent speaker and microphone. So why not bring this retro-idea of data transmission back? 

Obviously, it would be way too annoying if we brought it back as is. You will hear BRBRBRBZZZZZLLLLLLLLAAAAAAA all the time. But if we keep the concept but reimagine the implementation. We can see that there is a narrow band of frequency between 17khz and 20khz that most modern devices can produce but are outside of the human hearing range. That is essentially what I did, creating a data transmission protocol (and implementation) to transmit data with audio between the frequency range of 17khz and 20khz.

## What it does
It does one thing precisely. It transmits data through high-frequency inaudible audio at a rate of 150 bits per second. 

## How I built it
It may be obvious to think that the easy way to go about this is to transmit with a single pitch sound that turns on and off at a defined frequency, but that proves to be completely unreliable through tests done before the hackathon. Besides, the margin of the signal-to-noise ratio is very thin, and I have a large band of frequency available, so why not use them? 

When I started to work on it, I settled on four frequencies 17khz, 18khz, 19khz, and 20khz to transmit my data, where each frequency is a single bit. The on/off of specific frequencies are determined by the bit they transmit. The first signal is where all frequencies are on, and the subsequent signals are the data itself. I would use a 16-sized FFT to detect the rising of the first signal and perform a 128-sized FFT to extract frequencies in subsequent signals. This would give me a theoretical bitrate of ```44100/128 * 4 = 1378``` bits per second. 

I implemented this idea, but soon realized a glaring problem: frequency interference. The sending frequencies are high enough to interfere with the raw audio representation medium of 44100hz and each other. Imagine a signal of 101hz and you plot this signal 200 times per second. What you would get is a 100hz signal that is modulating its volume at 1 time per second. With a frequency difference of 1khz, we would get interference that is all over the place.

The solution was to only send a single frequency at once, eliminating interference once and for all. That reduced the bit rate down to ```44100/128 * 2 = 689``` bits per second. The mapping for frequencies is down below.
```
17khz = 00
18khz = 01
19khz = 11
20khz = 10
```

This mapping is chosen because I also decided to implement hamming code into the transmission. Specifically, the hamming code is 16-11-SECODED hamming code. It stands for 15+1=16 total bits, 11 data bits, single error correction double error detection. This mapping is chosen because the difference between two adjacent frequencies is only a single bit difference. Thus a misinterpretation is only a single-bit error. Thus in order to transmit a byte (8 bits) 16bits are needed. This further decreased our maximum bitrate to ```44100/128 * 2 / 2 = 344``` bits per second. Mapping is as follows.
```
DDDDDDDD111EEEEE
where
D = data
E = error correction parity
```

However, problems keep coming. This method is good enough for my computer with a high-end microphone and speaker. Mobile devices like my phone have a hard time decoding the signal. Thus, I increased the size of the data extraction FFT from 128 to 256 samples. This decision decreased our bitrate further by half to ```44100/128 * 2 / 4 = 172```. I then added transitions between one signal point to the next, making the high-frequency switching noise significantly less noticeable. This further decreased the bitrate from 172hz to 150hz. The size of the transmission is also provided upfront as a double-byte integer. This, along with the hamming code decoder, allows the receiver to decide whether the signal is complete or not. This is the final iteration of the communication protocol. 

The UI is largely simplistic (I ran out of time).
I built two pages. One page to send a transmission with the option of looping it. One page to receive a transmission with the option of copying it to the clipboard and opening it in a browser.

## Challenges I ran into

There are many challenges:

* Challenge: Realtime audio processing needs to be, well, realtime
* Solution: Use C/C++. Allocate buffer upfront. No allocations and deallocations while rendering audio.
* Challenge: The signal transmission in the real world is far more error-prone than theoretical.
* Solution: Use hamming code, use larger FFT, slow down transmission, etc.
* Challenge: C++ can't interface with Swift.
* Solution: Use bridge header and encapsulate C code within Obj-C.
* Challenge: Running out of time while writing this post.
* Solution: Use bullet points from now on.

## Accomplishments that I am proud of
* Believe it or not, this is the first time I coded something complete with a tight deadline.
* Being able to navigate the challenges above with my expertise in C/C++.
* Made friends along the way.

## What I learned
* Time management is important
* Start early when you don't know when you are going to finish
* ```std::unique_ptr``` in c++ is good
* How to write memory-safe, realtime-safe, thread-safe code
* How to use atomic variables and circular buffer to accomplish the previous point
* I am running out of ideas.

## What's next for Sonic Share
* I believe sonic share has the potential for being as popular as QR codes. It has the convenience of being able to "scan" without pointing at the camera. 
* This transmission method is platform agnostic. People can share data between completely different devices of different ecosystems. If you have a device with a speaker and a microphone, you can sonic share.
* At the current stage, sharing range is <1m. If I have enough time to optimize the efficiency and range, I can improve the range and bitrate further. 
* If developed properly, this could be a new form of wireless communication. Merchants can share their websites and payment methods. Teachers can share links this way. If popularized, the limit is endless.
* The app is demonstrated sharing of strings. But the communication code itself accepts an array of bytes(UInt8). So anything can be theoretically shared. It's just not implemented in the app.
* Submit this post so Sonic Share can be seen by the hackGT people.
