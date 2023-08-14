TARGET:=FreeRTOS
# TODO change to your ARM gcc toolchain path
TOOLCHAIN_ROOT:=../arm-none-eabi
TOOLCHAIN_PATH:=$(TOOLCHAIN_ROOT)/bin
TOOLCHAIN_PREFIX:=arm-none-eabi

# TODO change to the port your stm debugger is using
PORT:=SWD

TEST_ROOT:=
TEST_PATH:=
TEST_PREFIX:=gcc

# Default number of jobs (cores/threads) to compile with
CPUS:=128

# Optimization level, can be [0, 1, 2, 3, s, fast].
OPTLVL:=0
DBG:=-g

MAKEFLAGS += --jobs=$(CPUS)

FREERTOS:=$(CURDIR)/FreeRTOS
STARTUP:=$(CURDIR)/hardware
LINKER_SCRIPT:=$(CURDIR)/Utilities/stm32_flash.ld

# Path to CMSIS-DSP
CMSIS_DSP:=$(CURDIR)/Libraries/CMSIS/DSP

INCLUDE=-I$(CURDIR)
INCLUDE=-I$(CURDIR)/hardware
INCLUDE+=-I$(FREERTOS)/include
INCLUDE+=-I$(FREERTOS)/portable/GCC/ARM_CM4F
INCLUDE+=-I$(CURDIR)/Libraries/CMSIS/Device/ST/STM32F4xx/Include
INCLUDE+=-I$(CURDIR)/Libraries/CMSIS/Core/Include
INCLUDE+=-I$(CMSIS_DSP)/Include
INCLUDE+=-I$(CMSIS_DSP)/PrivateInclude
INCLUDE+=-I$(CURDIR)/Libraries/STM32F4xx_StdPeriph_Driver/inc
INCLUDE+=-I$(CURDIR)/config

BUILD_DIR = $(CURDIR)/build
BIN_DIR = $(CURDIR)/binary

# vpath is used so object files are written to the current directory instead
# of the same directory as their source files
vpath %.c $(CURDIR)/Libraries/STM32F4xx_StdPeriph_Driver/src \
          $(CURDIR)/Libraries/syscall $(CURDIR)/hardware $(FREERTOS) \
          $(FREERTOS)/portable/MemMang $(FREERTOS)/portable/GCC/ARM_CM4F \
          $(CMSIS_DSP)/Source/BasicMathFunctions \
          $(CMSIS_DSP)/Source/CommonTables \
          $(CMSIS_DSP)/Source/InterpolationFunctions \
          $(CMSIS_DSP)/Source/BayesFunctions \
          $(CMSIS_DSP)/Source/MatrixFunctions \
          $(CMSIS_DSP)/Source/ComplexMathFunctions \
          $(CMSIS_DSP)/Source/QuaternionMathFunctions \
          $(CMSIS_DSP)/Source/ControllerFunctions \
          $(CMSIS_DSP)/Source/SVMFunctions \
          $(CMSIS_DSP)/Source/DistanceFunctions \
          $(CMSIS_DSP)/Source/StatisticsFunctions \
          $(CMSIS_DSP)/Source/FastMathFunctions \
          $(CMSIS_DSP)/Source/SupportFunctions \
          $(CMSIS_DSP)/Source/FilteringFunctions \
          $(CMSIS_DSP)/Source/TransformFunctions \

vpath %.s $(STARTUP)
ASRC=startup_stm32f4xx.s

# Application Files
SRC+=blink_led.c

# Project Source Files
SRC+=stm32f4xx_it.c
SRC+=system_stm32f4xx.c
SRC+=main.c
SRC+=syscalls.c

# FreeRTOS Source Files
SRC+=port.c
SRC+=list.c
SRC+=queue.c
SRC+=tasks.c
SRC+=event_groups.c
SRC+=timers.c
SRC+=heap_4.c

# DSP Source Files
SRC+=BasicMathFunctions.c
SRC+=CommonTables.c
SRC+=InterpolationFunctions.c
SRC+=BayesFunctions.c
SRC+=MatrixFunctions.c
SRC+=ComplexMathFunctions.c
SRC+=QuaternionMathFunctions.c
SRC+=ControllerFunctions.c
SRC+=SVMFunctions.c
SRC+=DistanceFunctions.c
SRC+=StatisticsFunctions.c
SRC+=FastMathFunctions.c
SRC+=SupportFunctions.c
SRC+=FilteringFunctions.c
SRC+=TransformFunctions.c

# Standard Peripheral Source Files
SRC+=misc.c
SRC+=stm32f4xx_dcmi.c
#SRC+=stm32f4xx_hash.c
SRC+=stm32f4xx_rtc.c
SRC+=stm32f4xx_adc.c
SRC+=stm32f4xx_dma.c
#SRC+=stm32f4xx_hash_md5.c
SRC+=stm32f4xx_sai.c
SRC+=stm32f4xx_can.c
SRC+=stm32f4xx_dma2d.c
#SRC+=stm32f4xx_hash_sha1.c
SRC+=stm32f4xx_sdio.c
SRC+=stm32f4xx_cec.c
SRC+=stm32f4xx_dsi.c
SRC+=stm32f4xx_i2c.c
SRC+=stm32f4xx_spdifrx.c
SRC+=stm32f4xx_crc.c
SRC+=stm32f4xx_exti.c
SRC+=stm32f4xx_iwdg.c
SRC+=stm32f4xx_spi.c
#SRC+=stm32f4xx_cryp.c
SRC+=stm32f4xx_flash.c
SRC+=stm32f4xx_lptim.c
SRC+=stm32f4xx_syscfg.c
#SRC+=stm32f4xx_cryp_aes.c
SRC+=stm32f4xx_flash_ramfunc.c
SRC+=stm32f4xx_ltdc.c
SRC+=stm32f4xx_tim.c
#SRC+=stm32f4xx_cryp_des.c
#SRC+=stm32f4xx_fmc.c
SRC+=stm32f4xx_pwr.c
SRC+=stm32f4xx_usart.c
#SRC+=stm32f4xx_cryp_tdes.c
SRC+=stm32f4xx_fmpi2c.c
SRC+=stm32f4xx_qspi.c
SRC+=stm32f4xx_wwdg.c
SRC+=stm32f4xx_dac.c
SRC+=stm32f4xx_fsmc.c
SRC+=stm32f4xx_rcc.c
SRC+=stm32f4xx_dbgmcu.c
SRC+=stm32f4xx_gpio.c
SRC+=stm32f4xx_rng.c
SRC+=stm32f4xx_dfsdm.c

CDEFS=-DUSE_STDPERIPH_DRIVER
CDEFS+=-DSTM32F4XX
CDEFS+=-DSTM32F40_41xxx
CDEFS+=-DHSE_VALUE=8000000
CDEFS+=-D__FPU_PRESENT=1
CDEFS+=-DARM_MATH_CM4

MCUFLAGS=-mcpu=cortex-m4 -mthumb -mfloat-abi=hard -mfpu=fpv4-sp-d16 -fsingle-precision-constant -finline-functions -Wdouble-promotion -std=gnu99
COMMONFLAGS=-O$(OPTLVL) $(DBG) -Wall -ffunction-sections -fdata-sections
CFLAGS=$(COMMONFLAGS) $(MCUFLAGS) $(INCLUDE) $(CDEFS)

LDLIBS=-lm -lc -lgcc
LDFLAGS=$(MCUFLAGS) -u _scanf_float -u _printf_float -fno-exceptions -Wl,--gc-sections,-T$(LINKER_SCRIPT),-Map,$(BIN_DIR)/$(TARGET).map

CC=$(TOOLCHAIN_PATH)/$(TOOLCHAIN_PREFIX)-gcc
LD=$(TOOLCHAIN_PATH)/$(TOOLCHAIN_PREFIX)-gcc
OBJCOPY=$(TOOLCHAIN_PATH)/$(TOOLCHAIN_PREFIX)-objcopy
AS=$(TOOLCHAIN_PATH)/$(TOOLCHAIN_PREFIX)-as
AR=$(TOOLCHAIN_PATH)/$(TOOLCHAIN_PREFIX)-ar
GDB=$(TOOLCHAIN_PATH)/$(TOOLCHAIN_PREFIX)-gdb

OBJ = $(SRC:%.c=$(BUILD_DIR)/%.o)

$(BUILD_DIR)/%.o: %.c
	@echo [CC] $(notdir $<)
	@$(CC) $(CFLAGS) $< -c -o $@

all: $(OBJ)
	@echo [AS] $(ASRC)
	@$(AS) -o $(ASRC:%.s=$(BUILD_DIR)/%.o) $(STARTUP)/$(ASRC)
	@echo [LD] $(TARGET).elf
	@$(CC) -o $(BIN_DIR)/$(TARGET).elf $(LDFLAGS) $(OBJ) $(ASRC:%.s=$(BUILD_DIR)/%.o) $(LDLIBS)
	@echo [HEX] $(TARGET).hex
	@$(OBJCOPY) -O ihex $(BIN_DIR)/$(TARGET).elf $(BIN_DIR)/$(TARGET).hex
	@echo [BIN] $(TARGET).bin
	@$(OBJCOPY) -O binary $(BIN_DIR)/$(TARGET).elf $(BIN_DIR)/$(TARGET).bin


TEST_INCLUDE=-I$(CURDIR)/Unity

# Test source files
TEST_SRC+=$(CURDIR)/test_main.c
TEST_SRC+=$(CURDIR)/Unity/unity.c
TEST_SRC+=$(CURDIR)/blink_led.c

TEST_CDEFS=-DTEST_COMPILE

TEST_FLAGS=-Wdouble-promotion -m32 -Wextra -std=gnu99
TEST_CFLAGS=$(COMMONFLAGS) $(TEST_FLAGS) $(TEST_INCLUDE) $(TEST_CDEFS)

TEST_CC=$(TEST_PREFIX)

test_main: $(TEST_SRC)
	@echo Building tests...
	@$(TEST_CC) $(TEST_CFLAGS) $^ -o $@

tests: test_main
	@echo Running tests...
	@./test_main


.PHONY: clean_windows
clean_windows:
	@echo [del] build
	@for %%G in (build/*) do if not "%%~G" == "README.txt" del /f "build\%%~G"
	@echo [del] BIN
	@del /f binary\$(TARGET).elf
	@del /f binary\$(TARGET).hex
	@del /f binary\$(TARGET).bin
	@del /f binary\$(TARGET).map
	@del /f test_main.exe


.PHONY: clean_linux
clean_linux:
	@echo [RM] OBJ
	@rm -f $(OBJ)
	@rm -f $(ASRC:%.s=$(BUILD_DIR)/%.o)
	@echo [RM] BIN
	@rm -f $(BIN_DIR)/$(TARGET).elf
	@rm -f $(BIN_DIR)/$(TARGET).hex
	@rm -f $(BIN_DIR)/$(TARGET).bin
	@rm -f $(BIN_DIR)/$(TARGET).map
	@echo [RM] test
	@rm -f test_main


.PHONY: flash
flash:
	@STM32_Programmer_CLI.exe -c port=$(PORT) -w $(BIN_DIR)/$(TARGET).bin 0x8000000
