cmake_minimum_required(VERSION 3.20)

project(stm32f4_base_project LANGUAGES C)

function(select_clangd_database)
  if(CMAKE_EXPORT_COMPILE_COMMANDS)
    file(MAKE_DIRECTORY "${CMAKE_SOURCE_DIR}/build/clangd")
    file(CREATE_LINK "${CMAKE_BINARY_DIR}/compile_commands.json"
      "${CMAKE_SOURCE_DIR}/build/clangd/compile_commands.json" SYMBOLIC)
  endif()
endfunction()

if(CMAKE_CROSSCOMPILING)
  enable_language(ASM)
else()
  # Host build: unit tests only (see the "tests" preset)
  enable_testing()

  set(MIN_HOST_GCC_VERSION 9)
  set(MIN_HOST_CLANG_VERSION 10)
  if(CMAKE_C_COMPILER_ID STREQUAL "GNU" AND CMAKE_C_COMPILER_VERSION VERSION_LESS MIN_HOST_GCC_VERSION)
    message(FATAL_ERROR "The unit tests need GCC ${MIN_HOST_GCC_VERSION} or newer, found ${CMAKE_C_COMPILER_VERSION} (${CMAKE_C_COMPILER}). "
                        "Install a newer compiler or pass -DCMAKE_C_COMPILER=...")
  elseif(CMAKE_C_COMPILER_ID STREQUAL "Clang" AND CMAKE_C_COMPILER_VERSION VERSION_LESS MIN_HOST_CLANG_VERSION)
    message(FATAL_ERROR "The unit tests need Clang ${MIN_HOST_CLANG_VERSION} or newer, found ${CMAKE_C_COMPILER_VERSION} (${CMAKE_C_COMPILER}). "
                        "Install a newer compiler or pass -DCMAKE_C_COMPILER=...")
  endif()

  add_executable(test_main
    test_main.c
    blink_led.c
    Unity/unity.c)
  target_include_directories(test_main PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/Unity)
  target_compile_definitions(test_main PRIVATE TEST_COMPILE)
  target_link_libraries(test_main PRIVATE m)
  target_compile_options(test_main PRIVATE -Wall -Wextra -Wdouble-promotion)
  set_target_properties(test_main PROPERTIES C_STANDARD 99 C_EXTENSIONS ON)
  add_test(NAME test_main COMMAND test_main)
  select_clangd_database()
  return()
endif()

set(TARGET ${PROJECT_NAME})

set(FREERTOS      ${CMAKE_CURRENT_SOURCE_DIR}/FreeRTOS)
set(CMSIS_DSP     ${CMAKE_CURRENT_SOURCE_DIR}/Libraries/CMSIS/DSP)
set(STDPERIPH     ${CMAKE_CURRENT_SOURCE_DIR}/Libraries/STM32F4xx_StdPeriph_Driver)
set(LINKER_SCRIPT ${CMAKE_CURRENT_SOURCE_DIR}/Utilities/stm32_flash.ld)

if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Debug CACHE STRING "Build type" FORCE)
endif()

set(CMAKE_C_STANDARD 99)
set(CMAKE_C_EXTENSIONS ON)

set(MCU_FLAGS
  -mcpu=cortex-m4 -mthumb -mfloat-abi=hard -mfpu=fpv4-sp-d16)

# Include paths, defines and compiler flags shared by every target below
add_library(stm32f4_config INTERFACE)
target_include_directories(stm32f4_config INTERFACE
  ${CMAKE_CURRENT_SOURCE_DIR}/hardware
  ${CMAKE_CURRENT_SOURCE_DIR}/config
  ${CMAKE_CURRENT_SOURCE_DIR}
  ${FREERTOS}/include
  ${FREERTOS}/portable/GCC/ARM_CM4F
  ${CMAKE_CURRENT_SOURCE_DIR}/Libraries/CMSIS/Device/ST/STM32F4xx/Include
  ${CMAKE_CURRENT_SOURCE_DIR}/Libraries/CMSIS/Core/Include
  ${CMSIS_DSP}/Include
  ${CMSIS_DSP}/PrivateInclude
  ${STDPERIPH}/inc)
target_compile_definitions(stm32f4_config INTERFACE
  USE_STDPERIPH_DRIVER
  STM32F4XX
  STM32F40_41xxx
  HSE_VALUE=8000000
  __FPU_PRESENT=1
  ARM_MATH_CM4)
target_compile_options(stm32f4_config INTERFACE
  ${MCU_FLAGS}
  -fsingle-precision-constant -finline-functions -Wdouble-promotion
  -Wall -ffunction-sections -fdata-sections)

# The libraries are OBJECT libraries on purpose: the startup file only defines
# the exception handlers as weak symbols, so a static archive would never pull
# in the real handlers from FreeRTOS' port.c.
add_library(freertos OBJECT
  ${FREERTOS}/portable/GCC/ARM_CM4F/port.c
  ${FREERTOS}/list.c
  ${FREERTOS}/queue.c
  ${FREERTOS}/tasks.c
  ${FREERTOS}/event_groups.c
  ${FREERTOS}/timers.c
  ${FREERTOS}/portable/MemMang/heap_4.c)
target_link_libraries(freertos PRIVATE stm32f4_config)

set(DSP_MODULES
  BasicMathFunctions CommonTables InterpolationFunctions BayesFunctions
  MatrixFunctions ComplexMathFunctions QuaternionMathFunctions
  ControllerFunctions SVMFunctions DistanceFunctions StatisticsFunctions
  FastMathFunctions SupportFunctions FilteringFunctions TransformFunctions)
set(DSP_SOURCES)
foreach(module ${DSP_MODULES})
  list(APPEND DSP_SOURCES ${CMSIS_DSP}/Source/${module}/${module}.c)
endforeach()
add_library(cmsis_dsp OBJECT ${DSP_SOURCES})
target_link_libraries(cmsis_dsp PRIVATE stm32f4_config)

# Peripherals that are not built: hash, cryp, fmc
set(STDPERIPH_MODULES
  dcmi rtc adc dma sai can dma2d sdio cec dsi i2c spdifrx crc exti iwdg
  spi flash lptim syscfg flash_ramfunc ltdc tim pwr usart fmpi2c qspi wwdg dac
  fsmc rcc dbgmcu gpio rng dfsdm)
set(STDPERIPH_SOURCES ${STDPERIPH}/src/misc.c)
foreach(module ${STDPERIPH_MODULES})
  list(APPEND STDPERIPH_SOURCES ${STDPERIPH}/src/stm32f4xx_${module}.c)
endforeach()
add_library(stm32f4_stdperiph OBJECT ${STDPERIPH_SOURCES})
target_link_libraries(stm32f4_stdperiph PRIVATE stm32f4_config)

add_executable(${TARGET}
  blink_led.c
  main.c
  hardware/stm32f4xx_it.c
  hardware/system_stm32f4xx.c
  hardware/startup_stm32f4xx.s
  Libraries/syscall/syscalls.c)
target_link_libraries(${TARGET} PRIVATE
  stm32f4_config freertos cmsis_dsp stm32f4_stdperiph m c gcc)

set_target_properties(${TARGET} PROPERTIES
  SUFFIX .elf
  LINK_DEPENDS ${LINKER_SCRIPT})

target_link_options(${TARGET} PRIVATE
  ${MCU_FLAGS}
  LINKER:-u,_scanf_float LINKER:-u,_printf_float -fno-exceptions
  -Wl,--gc-sections
  -Wl,-T,${LINKER_SCRIPT}
  -Wl,-Map,${CMAKE_CURRENT_BINARY_DIR}/${TARGET}.map)

add_custom_command(TARGET ${TARGET} POST_BUILD
  COMMAND ${CMAKE_OBJCOPY} -O ihex   $<TARGET_FILE:${TARGET}> ${CMAKE_CURRENT_BINARY_DIR}/${TARGET}.hex
  COMMAND ${CMAKE_OBJCOPY} -O binary $<TARGET_FILE:${TARGET}> ${CMAKE_CURRENT_BINARY_DIR}/${TARGET}.bin
  COMMAND ${CMAKE_SIZE} $<TARGET_FILE:${TARGET}>
  VERBATIM)

# `cmake --build <dir> --target flash`
# Uses the first of OpenOCD, STM32CubeProgrammer or st-flash that is installed.
set(FLASH_ADDRESS 0x8000000)
set(OPENOCD_BOARD board/stm32f4discovery.cfg CACHE STRING "OpenOCD board config file used by the flash target")
set(STM32_PORT SWD CACHE STRING "Debug port used by STM32_Programmer_CLI")
include(cmake/openocd.cmake)
if(OPENOCD_DOWNLOAD)
  # Part of the default build so OpenOCD exists before the first flash or debug session
  add_custom_target(openocd ALL
    COMMAND ${CMAKE_COMMAND}
            -DOPENOCD_NAME=${OPENOCD_NAME} -DOPENOCD_URL=${OPENOCD_URL}
            -DOPENOCD_SHA256=${OPENOCD_SHA256} -DOPENOCD_DIR=${OPENOCD_DIR}
            -P ${CMAKE_CURRENT_SOURCE_DIR}/cmake/download_openocd.cmake
    COMMENT "Checking OpenOCD"
    USES_TERMINAL VERBATIM)
  set(OPENOCD_DEPENDS openocd)
endif()
find_program(STM32_PROGRAMMER_CLI NAMES STM32_Programmer_CLI STM32_Programmer_CLI.exe)
find_program(ST_FLASH st-flash)
if(OPENOCD)
  add_custom_target(flash
    COMMAND ${OPENOCD} -f ${OPENOCD_BOARD}
            -c "program $<TARGET_FILE:${TARGET}> verify reset exit"
    DEPENDS ${TARGET} ${OPENOCD_DEPENDS} VERBATIM)
elseif(STM32_PROGRAMMER_CLI)
  add_custom_target(flash
    COMMAND ${STM32_PROGRAMMER_CLI} -c port=${STM32_PORT} -w ${CMAKE_CURRENT_BINARY_DIR}/${TARGET}.bin ${FLASH_ADDRESS}
    DEPENDS ${TARGET} VERBATIM)
elseif(ST_FLASH)
  add_custom_target(flash
    COMMAND ${ST_FLASH} write ${CMAKE_CURRENT_BINARY_DIR}/${TARGET}.bin ${FLASH_ADDRESS}
    DEPENDS ${TARGET} VERBATIM)
else()
  message(STATUS "No flashing tool found (openocd, STM32_Programmer_CLI, st-flash): 'flash' target disabled")
endif()

select_clangd_database()
