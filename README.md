# STM32F4 Base Project

A FreeRTOS example for the STM32F4 Discovery board (STM32F407VG), using
CMSIS-DSP and the STM32F4 Standard Peripheral Library. The firmware runs a
task that uses a sine calculation to blink the green LD4 LED (PD12).

## Requirements

- CMake 3.21 or newer and Ninja.
- For host tests: a C compiler and math library. GCC 9+ and Clang 10+ are
  checked by the build.
- For firmware: an Arm GNU toolchain. On Linux x86_64 and aarch64, CMake
  downloads the pinned toolchain automatically.
- To flash or debug: an STM32F4 Discovery board, connected to the computer
  through its **ST-LINK USB port** with a USB data cable.

The firmware build and flashing have been tested on Linux with the Discovery
board. The flash and debug configurations target this board; other STM32F4
boards may require different startup, linker, pin and OpenOCD settings.

## Build firmware

From the repository root:

```sh
cmake --preset firmware
cmake --build --preset firmware
```

The first configure downloads the SHA-256-verified Arm GNU 15.2.rel1 toolchain
to `.toolchain/` on supported Linux hosts. This is roughly a 180 MB download
and 1.1 GB extracted. The first build also downloads xPack OpenOCD 0.12.0-7
(about 3 MB, SHA-256 verified). Later builds reuse both downloads.

The `firmware` preset is a debug build; its ELF, HEX, BIN and map files are in
`build/firmware/`. For an optimized build, use:

```sh
cmake --preset firmware-release
cmake --build --preset firmware-release
```

The release build uses link-time optimization (LTO), except for the FreeRTOS
port, interrupt handlers and syscall implementations. Release output is in
`build/firmware-release/`. Clean a configured build with
`cmake --build --preset firmware --target clean` (or use `firmware-release`).
Cleaning build outputs does not remove `.toolchain/`.

### Using installed tools

To select a different Arm compiler, pass its `bin` directory when configuring
or set the `ARM_TOOLCHAIN_PATH` environment variable:

```sh
cmake --preset firmware -DARM_TOOLCHAIN_PATH=/path/to/bin
```

Alternatively, set `-DARM_TOOLCHAIN_AUTO_DOWNLOAD=OFF` to look for
`arm-none-eabi-gcc` on `PATH`. On unsupported hosts, provide a toolchain or
place it on `PATH`. Use a fresh build directory or delete the CMake cache when
changing compilers.

For OpenOCD, pass `-DOPENOCD_EXECUTABLE=/path/to/openocd`, or set
`-DOPENOCD_AUTO_DOWNLOAD=OFF` to use `openocd` from `PATH`. The tool overrides
apply to the CMake flash target; the VS Code debug configuration has separate
paths, described below.

## Host tests

These Unity tests run on the computer and do not require a board or Arm
toolchain:

```sh
cmake --preset tests
cmake --build --preset tests
ctest --preset tests
```

The current tests exercise `blink()` using the host math library; they do not
test the firmware's CMSIS-DSP implementation or hardware.

## Flash and run

After building and connecting the board's ST-LINK USB port:

```sh
cmake --build --preset firmware --target flash
```

This replaces the firmware on the board, verifies the image and resets the
target when using OpenOCD. The green LD4 LED should blink. To flash a release
build, use `--preset firmware-release` instead.

The flash target uses OpenOCD with `board/stm32f4discovery.cfg` by default.
Set `-DOPENOCD_BOARD=...` when configuring to use a different OpenOCD board
configuration. If OpenOCD is unavailable, the target falls back to
`STM32_Programmer_CLI`, then `st-flash`; if none is found, the target is not
created.

### Linux USB permissions

If OpenOCD reports `LIBUSB_ERROR_ACCESS`, install the udev rules included
with the downloaded OpenOCD, then unplug and reconnect the board:

```sh
sudo cp .toolchain/openocd/openocd/contrib/60-openocd.rules /etc/udev/rules.d/
sudo udevadm control --reload-rules
sudo udevadm trigger
```

These rules apply system-wide; the packaged ST-LINK rule grants all local
users access to the device. If using a system OpenOCD instead, follow its
distribution's udev setup instructions.

## VS Code

Install the workspace's recommended extensions from the Extensions view
(`@recommended`):

- **CMake Tools** (`ms-vscode.cmake-tools`) configures and builds presets and
  runs CTest tests.
- **clangd** (`llvm-vs-code-extensions.vscode-clangd`) provides C/C++
  navigation and diagnostics.
- **Cortex-Debug** (`marus25.cortex-debug`) provides OpenOCD debugging.

Configure both `firmware` and `tests` once to generate the compile databases
used by clangd. Test-only files use the host database, firmware files use the
firmware database, and shared `blink_led.c` and `blink_led.h` use the most
recently configured preset. Configure the desired preset again to switch
their context; restart clangd if needed. A build that triggers reconfiguration
can also change the selection.

### Debugging

Connect the board, select **Debug STM32F4 (OpenOCD)** in Run and Debug, and
press F5. The launch task configures and builds the debug firmware; the
debugger then flashes it and stops at `main`. Continue with F5 or set a
breakpoint in `test_FPU_test`. The **Attach to STM32F4 (OpenOCD)** option
attaches to the running firmware; build it first so its ELF matches the image
on the board.

The included launch configurations use the downloaded OpenOCD and GDB paths
under `.toolchain/`. If using installed tools instead, update `serverpath` and
`armToolchainPath` in `.vscode/launch.json`, or remove them to use tools from
`PATH`. The VS Code OpenOCD board configuration is also set in that file,
independently of the CMake `OPENOCD_BOARD` option.

To debug from a terminal instead, first flash the debug firmware as above. In
one terminal, start OpenOCD:

```sh
.toolchain/openocd/bin/openocd -f board/stm32f4discovery.cfg
```

In another terminal:

```text
.toolchain/current/bin/arm-none-eabi-gdb build/firmware/stm32f4_base_project.elf
(gdb) target extended-remote :3333
(gdb) monitor reset halt
(gdb) break main
(gdb) continue
```

## Serial output

`printf` writes through USART3 at 115200 baud, 8 data bits, no parity and one
stop bit. To receive it, connect a **3.3 V** USB-to-serial adapter's RX to
PB10 (USART3 TX), and connect the adapter's GND to the board's GND. Open the
adapter's serial port at 115200 8-N-1. The output is not sent to the VS Code
debug console. Transmission currently polls the peripheral.

## License

Project-owned code is released under the [MIT License](LICENSE). Third-party
code retains its own terms, including files in `FreeRTOS/`, `Libraries/`,
`Unity/`, `config/` and `hardware/`. Check individual notices before using or
redistributing them. In particular, `Utilities/stm32_flash.ld` contains a
separate Ac6 distribution notice.
