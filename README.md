# STM32F4-FreeRTOS

A demo project of FreeRTOS running on a STM32F4 Discovery board.

## Steps to run this example

### Prerequisite

1. A PC running Linux(not tested) or Windows with Cygwin.
2. A STM32F4Discovery board.
3. A FT232RL USB to serial board which is recommended if there's no serial port on your computer.
4. USB Cable, Dupont Line and other tools.

### Install the toolchain

The pre-built version of GNU Tools for ARM can be downloaded from its [website](https://developer.arm.com/downloads/-/arm-gnu-toolchain-downloads). It's available for most systems. Follow the instructions in the readme file and installed the toolchain to your system. To verify your installation, simply type `arm-none-eabi-gcc --version` in your terminal, if everything goes right, you'll get output like this:

```
arm-none-eabi-gcc (Arm GNU Toolchain 12.3.Rel1 (Build arm-12.35)) 12.3.1 20230626
Copyright (C) 2022 Free Software Foundation, Inc.
This is free software; see the source for copying conditions.  There is NO
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
```

### Install ST-Link utility

#### Windows
Grab the official utility from [ST website](http://www.st.com/web/catalog/tools/FM146/CL1984/SC724/SS1677/PF251168). Note that you should install the USB driver before install the STM32CubeProgrammer.  Add the path to the STM32_Programmer_CLI to your enviroment variable `PATH`.

#### Linux and OS X

Grab the official utility from [ST website](http://www.st.com/web/catalog/tools/FM146/CL1984/SC724/SS1677/PF251168). Note that you should install the USB driver before install the STM32CubeProgrammer.  Add the path to the STM32_Programmer_CLI to your enviroment variable `PATH`.

**Note:** Not tested

or

Clone this [git](https://github.com/texane/stlink), follow the instructions on that page and install st-util to your system.

**Note:** Not tested


### Compile this example
The only thing you need to do is to edit the makefile and let it know your toolchain installation path. Change the `TOOLCHARN_ROOT` variable at the third line of makefile and point it to where you installed the toolchain. The you can simply type `make` and compile the example.

### Debug
Connect your STM32F4Discovery with a USB cable. You can flash the binary into the board with this:

`$ STM32_Programmer_CLI -c port=SWD -w binary/FreeRTOS.bin 0x8000000`

** Note: ** Everything below this is not tested.

The code is wrote directly into internal flash of STM32 processor and it starts to run after reset. To debug it, first start the GDB server:

`$ st-util &`

And then GDB:

```
$ arm-none-eabi-gdb binary/FreeRTOS.elf
(gdb) tar ext :4242
(gdb) b main
(gdb) c
```

You'll get breakpoint triggered at `main` function, and enjoy!
