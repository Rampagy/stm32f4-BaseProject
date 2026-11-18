# STM32F4 Base Project

A base project for the STM32F4 Discovery board: FreeRTOS, the STM32F4 standard peripheral library and CMSIS-DSP, built with CMake, with host-side unit tests (Unity).

## Prerequisites

- Linux (x86_64 or aarch64). On other hosts, install `arm-none-eabi-gcc` yourself (see below).
- CMake 3.21+ and Ninja.
- An STM32F4 Discovery board and a USB cable.

## Build

```
$ cmake --preset firmware
$ cmake --build --preset firmware
```

Use the `firmware-release` preset for an optimized build. The output (`stm32f4_base_project.elf`, `.hex`, `.bin` and `.map`) is written to `build/firmware/`.

### VS Code extensions

The workspace recommends these extensions:

- **CMake Tools** (`ms-vscode.cmake-tools`): configure and build presets, and run CTest tests.
- **clangd** (`llvm-vs-code-extensions.vscode-clangd`): C/C++ navigation and diagnostics.
  Configure both `firmware` and `tests` once to generate their compilation databases.
  Test-only files use the host database; firmware files use the firmware database.
  Shared `blink_led.c` and `blink_led.h` use the most recently configured preset.
  To switch their context, configure the desired preset again and restart clangd
  if needed. A build that triggers reconfiguration can also change the selection.
- **Cortex-Debug** (`marus25.cortex-debug`): flash and debug the board with OpenOCD.

Install them from VS Code's Extensions view by searching for `@recommended`.

### Toolchain

The first configure of the `firmware` preset downloads the pinned Arm GNU toolchain (15.2.rel1, about 180 MB, SHA-256 verified) into `.toolchain/`. The compiler is needed to configure the project, so this happens at configure time and the first configure takes a while. Everyone then builds with the same compiler. To use your own toolchain instead:

- `-DARM_TOOLCHAIN_PATH=/path/to/bin` (or the `ARM_TOOLCHAIN_PATH` environment variable) selects a specific toolchain, or
- `-DARM_TOOLCHAIN_AUTO_DOWNLOAD=OFF` uses `arm-none-eabi-gcc` from `PATH`.

To change the pinned version, edit the version and hashes at the top of `cmake/arm-none-eabi.cmake`.

### OpenOCD

The first build downloads a pinned [xPack OpenOCD](https://github.com/xpack-dev-tools/openocd-xpack) (0.12.0-7, about 3 MB, SHA-256 verified) into `.toolchain/`, through the `openocd` target that is part of the default build. Use `-DOPENOCD_EXECUTABLE=/path/to/openocd` for your own build, or `-DOPENOCD_AUTO_DOWNLOAD=OFF` to use `openocd` from `PATH`.

On Linux, your user needs permission to access the ST-Link. Install the udev rules and replug the board:

```
$ sudo cp .toolchain/openocd/openocd/contrib/60-openocd.rules /etc/udev/rules.d/
$ sudo udevadm control --reload-rules && sudo udevadm trigger
```

## Unit tests

The Unity tests are built for the host machine and need no hardware. They use your system C compiler (GCC 9+ or Clang 10+):

```
$ cmake --preset tests
$ cmake --build --preset tests
$ ctest --preset tests
```

## Flash

```
$ cmake --build --preset firmware --target flash
```

This uses OpenOCD with `board/stm32f4discovery.cfg` (override with `-DOPENOCD_BOARD=...`). If no OpenOCD is available it falls back to `STM32_Programmer_CLI` and then `st-flash`.

## Debug

In VS Code, install the recommended extensions (CMake Tools and Cortex-Debug), build the firmware once (this downloads the tools), connect the board and start the **Debug STM32F4 (OpenOCD)** configuration (F5). It builds the firmware, flashes it and stops at `main`.

From a terminal:

```
$ .toolchain/openocd/bin/openocd -f board/stm32f4discovery.cfg
$ .toolchain/current/bin/arm-none-eabi-gdb build/firmware/stm32f4_base_project.elf
(gdb) target extended-remote :3333
(gdb) monitor reset halt
(gdb) break main
(gdb) continue
```

## License

The project's own code is released under the [MIT License](LICENSE). Third-party components under `FreeRTOS/`, `Libraries/`, `Unity/`, `config/` and the ST-provided files in `hardware/` (startup, system and interrupt files) remain under their own licenses; their headers say which.
