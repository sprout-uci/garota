# GAROTA:

##### GAROTA paper (USENIX Security'22): [link available soon]

Embedded (aka smart or IoT) devices are increasingly popular and becoming ubiquitous. Unsurprisingly, they are also attractive attack targets for exploits and malware. Low-end embedded devices, designed with strict cost, size, and energy limitations, are especially challenging to secure, given their lack of resources to implement sophisticated security services, available on higher-end computing devices. To this end, several tiny Roots-of-Trust (RoTs) were proposed to enable services, such as remote verification of device’s software state and runtime integrity. Such RoTs operate reactively: they can prove whether a desired action (e.g., software update, or execution of a program) was performed on a specific device. However, they can not guarantee that a desired action will be performed, since malware controlling the device can trivially block access to the RoT by ignoring/discarding received commands and other trigger events. This is a major and important problem because it allows malware to effectively “brick” or incapacitate a potentially huge number of (possibly mission-critical) devices.

Though recent work made progress in terms of incorporating more active behavior atop existing RoTs, it relies on extensive hardware support –Trusted Execution Environments (TEEs) which are too costly for low-end devices. In this work, we set out to systematically design a minimal active RoT for tiny low-end MCU-s. We begin with the following questions: What functions and hardware support are required to guarantee actions in the presence of malware?, How to implement this efficiently?, and What security benefits stem from such an active RoT architecture? We then design, implement, formally verify, and evaluate GAROTA : Generalized Active Root-Of-Trust Architecture. We believe that GAROTA is the first clean-slate design of an active RoT for low-end MCU-s. We show how GAROTA guarantees that even a fully software compromised low-end MCU performs a desired action. We demonstrate its practicality by implementing GAROTA in the context of three types of applications where actions are triggered by: sensing hardware, network events and timers. We also formally specify and verify GAROTA functionality and properties.

### GAROTA Directory Structure

	├── msp_bin
	├── openmsp430
	│   ├── contraints_fpga
	│   ├── fpga
	│   ├── msp_core
	│   ├── msp_memory
	│   ├── msp_periph
	│   └── simulation
	├── scripts
	│   ├── build
	│   ├── build-verif
	│   └── verif-tools
	├── application
	│   ├── gpio
	│   ├── timer
	│   └── uart
	├── test
	│   └── simulation
	├── utils
	├── verification_specs
	│   └── soundness_and_security_proofs
	└── garota
		└── hw-mod
		    └── hw-mod-auth

## Dependencies Installation

Environment (processor and OS) used for development and verification:
Intel i7-3770
Ubuntu 18.04.3 LTS

Dependencies on Ubuntu:

		sudo apt-get install bison pkg-config gawk clang flex gcc-msp430 iverilog tcl-dev
		cd scripts
		sudo make install

## Building GAROTA Software
To generate the Microcontroller program memory configuration containing VRASED trusted software (SW-Att) and sample applications we are going to use the Makefile inside the scripts directory:

        cd scripts

This repository accompanies 4 test-cases: simple_app, violation_forge_ER, violation_forge_OR, violation_forge_META. (See [Description of Provided test-cases] for details on each test-case)
These test-cases correspond to one successfull proof of execution (PoX) and 3 cases where PoX fails due to a violation that could be used to attack the correctness of the execution.
To build GAROTA for a specific test-case run:

        make "name of test-case"

For instance:

        make gpio

to build the software including the binaries of gpio test-case.
Note that this step will not run any simulation, but simply generate the MSP430 binaries corresponding to the test-case of choice.
As a result of the build, two files pmem.mem and smem.mem should be created inside msp_bin directory:

- pmem.mem program memory contents corresponding the application binaries

- smem.mem contains SW-Att binaries.

In the next steps, during synthesis, these files will be loaded to the MSP430 memory when we either: deploy GAROTA on the FPGA or run GAROTA simulation using VIVADO simulation tools.

If you want to clean the built files run:

        make clean

        Note: Latest Build tested using msp430-gcc (GCC) 4.6.3 2012-03-01

To test GAROTA with a different application you will need to repeat these steps to generate the new "pmem.mem" file and re-run synthesis.

## Creating a GAROTA project on Vivado and Running Synthesis

This is an example of how to synthesize and prototype GAROTA using Basys3 FPGA and XILINX Vivado v2019.2 (64-bit) IDE for Linux

- Vivado IDE is available to download at: https://www.xilinx.com/support/download.html

- Basys3 Reference/Documentation is available at: https://reference.digilentinc.com/basys3/refmanual

#### Creating a Vivado Project for GAROTA

1 - Clone this repository;

2 - Follow the steps in [Building GAROTA Software](#building-GAROTA-software) to generate .mem files for the application of your choice.

2- Start Vivado. On the upper left select: File -> New Project

3- Follow the wizard, select a project name and location. In project type, select RTL Project and click Next.

4- In the "Add Sources" window, select Add Files and add all *.v and *.mem files contained in the following directories of this reposiroty:

        openmsp430/fpga
        openmsp430/msp_core
        openmsp430/msp_memory
        openmsp430/msp_periph
        /vrased/hw-mod
        /msp_bin

and select Next.

Note that /msp_bin contains the pmem.mem and smem.mem binaries, generated in step [Building GAROTA Software].

5- In the "Add Constraints" window, select add files and add the file

        openmsp430/contraints_fpga/Basys-3-Master.xdc

and select Next.

        Note: this file needs to be modified accordingly if you are running GAROTA in a different FPGA.

6- In the "Default Part" window select "Boards", search for Basys3, select it, and click Next.

        Note: if you don't see Basys3 as an option you may need to download Basys3 to your Vivado installation.

7- Select "Finish". This will conclude the creation of a Vivado Project for GAROTA.

Now we need to configure the project for systhesis.

8- In the PROJECT MANAGER "Sources" window, search for openMSP430_fpga (openMSP430_fpga.v) file, right click it and select "Set as Top".
This will make openMSP430_fpga.v the top module in the project hierarchy. Now its name should appear in bold letters.

9- In the same "Sources" window, search for openMSP430_defines.v file, right click it and select Set File Type and, from the dropdown menu select "Verilog Header".

Now we are ready to synthesize openmsp430 with GAROTA hardware the following step might take several minutes.

10- On the left menu of the PROJECT MANAGER click "Run Synthesis", select execution parameters (e.g, number of CPUs used for synthesis) according to your PC's capabilities.

11- If synthesis succeeds, you will be prompted with the next step to "Run Implementation". You *do not* to "Run Implementation" if you only want simulate GAROTA.
"Run implementation" is only necessary if your purpose is to deploy GAROTA on an FPGA.

If you want to deploy GAROTA on an FPGA, continue following the instructions on [Deploying GAROTA on Basys3 FPGA].

If you want to simulate GAROTA using VIVADO sim-tools, continue following the instructions on [Running GAROTA on Vivado Simulation Tools].

## Running GAROTA on Vivado Simulation Tools

After completing the steps 1-10 in [Creating a Vivado Project for GAROTA]:

1- In Vivado, click "Add Sources" (Alt-A), then select "Add or create simulation sources", click "Add Files", and select everything inside openmsp430/simulation.

2- Now, navigate "Sources" window in Vivado. Search for "tb_openMSP430_fpga", and *In "Simulation Sources" tab*, right-click "tb_openMSP430_fpga.v" and set its file type as top module.

3- Go back to Vivado window and in the "Flow Navigator" tab (on the left-most part of Vivado's window), click "Run Simulation", then "Run Behavioral Simulation".

4- On the newly opened simulation window, select a time span for your simulation to run (see times for each default test-case below) and the press "Shift+F2" to run.

5- In the green wave window you will see values for several signals, including "pc[15:0]". pc contains the program counter value, i.e., the address of the instruction being executed at each time.

To determine the address of an instruction one can check the compilation file produced at scripts/tmp-build/application/"test-case-name"/garota.lst  (where "test-case-name" is the name of the test-case, i.e., if you ran "make gpio", "test-case-name"=simple_app). In this file search for the name of the function of  or memory address of interest.

#### NOTE: To simulate a different test-case you need to re-run "make test-case_name" to generate the corresponding pmem.mem file and re-run the synthesis step (step 10 in [Creating a Vivado Project for GAROTA]) on Vivado. 

## Deploying GAROTA on Basys3 FPGA

(NOTE: an FPGA is not required to test GAROTA design, and simulation-based testing is often more expressive)

1- After Step 10 in [Creating a Vivado Project for GAROTA], select "Run Implementation" and wait until this process completes (typically takes around 1 hour).

2- If implementation succeeds, you will be prompted with another window, select option "Generate Bitstream" in this window. This will generate the bitstream that is used to step up the FPGA according to VRASED hardware and software.

3- After the bitstream is generated, select "Open Hardware Manager", connect the FPGA to you computer's USB port and click "Auto-Connect".
Your FPGA should be now displayed on the hardware manager menu.

        Note: if you don't see your FPGA after auto-connect you might need to download Basys3 drivers to your computer.

4- Right-click your FPGA and select "Program Device" to program the FPGA.

## Description of Provided test-cases

This repo contains three default test-cases, one for each type of trigger described in GAROTA paper.

#### 1- gpio:

The first example, GPIO-TCB, operates in the context of a safety-critical temperature sensor. 

GAROTA is used to assure that the sensor’s most safety-critical function – sounding an alarm – is never prevented from executing due to software compromise of the underlying MCU. 

We use a standard builtin MCU interrupt, based on General Purpose Input/Output (GPIO) to implement a trigger. MCU execution always starts by calling the TCB. Therefore, after MCU initialization/reset any other applications can only execute after TCB. Ensuring that the proper configurations will take place. Specifically `P1` will be configured as input and once pressed the interrupt will be handled by a protected function. These configurations can not change as guaranteed by GAROTA.

#### 2- timer:

The second example of GAROTA, Timer-TCB, is in the domain of real-time task scheduling. Without GAROTA (even in the presence of a passive RoT), a compromised MCU controlled by malware could ignore performing its periodic security- or safety-critical tasks. 

In this example we show how GAROTA can ensure that a prescribed task, implemented within the TCB will execute periodically without fail. TCB in this example will configure a timer that once triggered, just as before will spark the execution of our custom handling code.

#### 3- uart:

The last example, NetTCB, uses network event-based trigger to ensure that the TCB quickly filters all received network packets to identify those that carry TCB-destined commands and take the appropriate action. 

Incoming packets that do not contain such commands are ignored by the TCB and passed on to applications through the regular interface (i.e., reading from the UART buffer). In this example, we implement guaranteed receipt of external reset commands from some trusted remote entity. 

Each incoming UART message will immediately trigger our custom handling procedure, that after filtering the message, it will either pass it along so it can be read by the intended recipient, or will perform a reset.


#### FPGA Runs

Note that timer periods used for testing via simalation are often too fast when the design is synthesized on an FPGA. As such, these timer-based event might not be noticeable to the human eye. In such cases, it is necessary to change timer configurations and constants in order to run a human-visible example.

#### NOTE: To simulate (or run a test with and FPGA) using a different test-case you need to re-run "make test-case_name" to generate the corresponding pmem.mem file and re-run the synthesis step (step 10 in [Creating a Vivado Project for GAROTA]) on Vivado.

## Running GAROTA Verification

To check HW-Mod against VRASED and GAROTA LTL subproperties using NuSMV run:

        make verify

Note that running make verify proofs may take several minutes (Time may very widely depending on the setup, e.g., 22 minutes on a Ubuntu18 VM with 4 cores and 4GB of RAM).

To run GAROTA and VRASED end-to-end implementation proofs check the readme file in:

        verification_specs/garota_end_to_end_proofs

To run end-to-end proofs you also need to install Spot: https://spot.lrde.epita.fr/install.html

## A note on the extent of GAROTA verification

GAROTA verification extends exclusively to GAROTA hardware module (within garota folder in this repo). The verification of the underlying MCU core or proving the correctness of the integration of GAROTA module with a specific core is not in the scope of this project.

GAROTA hardware module is verified for a generic machine model (its integration with the openMSP430 core is done as examplary prototype). Assuring that the axioms in GAROTA's machine model hold when instatiating GAROTA in each particular MCU core is required in order to obtain GAROTA provable guarantees. This per-core model fact-checking must be performed whenever GAROTA module is instantiated in a different MCU model.

See GAROTA paper for details on the machine model and verified guarantees.
