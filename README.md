# Continuum NOS3
A cloud based satellite fleet operations software emulator based on NASA Operational Simulator for Small Satellites.

## NASA Operational Simulator for Small Satellites
The NASA Operational Simulator for Small Satellites (NOS3) is a suite of tools developed by NASA's Katherine Johnson Independent Verification and Validation (IV&V) Facility to aid in areas such as software development, integration & test (I&T), mission operations/training, verification and validation (V&V), and software systems check-out. 
NOS3 provides a software development environment, a multi-target build system, an operator interface/ground station, dynamics and environment simulations, and software-based models of spacecraft hardware.

## Startup 
* docker build -t test .
* With [x-server](https://sourceforge.net/projects/xming/):
    - docker run -it --env="DISPLAY=192.168.4.120:0.0" --env="QT_X11_NO_MITSHM=1" test

## Documentation
The best source of documentation can be found at [the wiki](https://github.com/nasa/nos3/wiki) or [NOS3](http://www.nos3.org).

### Directory Layout
* `components` contains the repositories for the hardware component apps; each repository contains the app, an associated sim, and COSMOS command and telemetry tables
* `fsw` contains the repositories needed to build cFS FSW
	- /apps - the open source cFS apps
	- /cfe - the core flight system (cFS) source files
	- /nos3_defs - cFS definitions to configure cFS for NOS3
	- /osal - operating system abstraction layer (OSAL), enables building for linux and flight OS
	- /psp - platform support package (PSP), enables use on multiple types of boards
	- /tools - standard cFS provided tools
* `gsw` contains the nos3 ground station files, and other ground based tools
	- /ait - Ammos Instrument Toolkit (Untested for 1.05.0)
	- /cosmos - COSMOS files
	- /OrbitInviewPowerPrediction - OIPP tool for operators
	- /scripts - convenience scripts
* `sims` contains the nos3 simulators and configuration files
	- /cfg - 42 configuration files and NOS3 top level configuration files
	- /nos_time_driver - time syncronization for all components
	- /sim_common - common files used by component simulators including the files that define the simulator plugin architecture
	- /sim_terminal - terminal for testing on NOS Engine busses
	- /truth_42_sim - interface between 42 and COSMOS to provide dynamics truth data to COSMOS

