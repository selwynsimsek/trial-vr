# TrialVR
TrialVR is an extension to the [Trial game engine](https://github.com/Shirakumo/trial) that handles input from and renders to a modern virtual reality headset, using OpenVR. It provides an Emacs-based REPL that allows one to code interactively and iteratively whilst in virtual reality. TrialVR runs on Windows and Linux, and requires a SteamVR installation.

TrialVR is a work in progress.

Visit the #shirakumo channel on the Freenode IRC network to chat about this project.

## Usage
```(ql:quickload :trial-vr)```

```(org.shirakumo.fraf.trial.vr:launch :own-thread t)```

## Installation
Windows is recommended for performance reasons.

### Prerequisites
+ A VR-ready PC with [SteamVR](https://store.steampowered.com/app/250820/SteamVR/) installed.
+ Any SteamVR compatible headset. The HTC Vive, Valve Index and Oculus Rift are all compatible, as well as many others.
+ A development environment that allows for use of the CFFI groveller. MinGW-w64 and its MSYS2 shell are recommended for Windows.
+ SBCL is highly recommended, though other implementations ought to work.

Clone the following to `quicklisp/local-projects`
+ TrialVR
+ Trial, [https://github.com/shirakumo/trial]
+ fork of 3b-openvr, [https://github.com/selwynsimsek/3b-openvr]
+ upstream CFFI, [https://github.com/cffi/cffi]

### Windows
Additionally clone to `quicklisp/local-projects`
+ com-on, commit af046064 [https://github.com/Shinmera/com-on]


### Linux
Additionally clone to `quicklisp/local-projects`
+ cl-xwd, [https://github.com/selwynsimsek/cl-xwd/]
+ cl-ode
+ cl-steamworks, [https://github.com/Shinmera/cl-steamworks]

Install VNC Viewer, Xvfb, Portacle, x11vnc and Fluxbox. These are used to capture the screen output of Emacs to VR.

Clone [vrx-utils](https://github.com/selwynsimsek/vrx-utils) to any location on your computer.
In a shell, navigate to `vrx-utils` and execute `./vr-system`.
An Emacs windows should appear. Connect to Swank on port 4005 and use the REPL to start TrialVR.

## Author

* Selwyn Simsek

## Copyright

Copyright (c) 2020 Selwyn Simsek
