set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR arm)

# Toolchain selection, in order of priority:
#   1. -DARM_TOOLCHAIN_PATH=<bin dir> (or the ARM_TOOLCHAIN_PATH environment variable)
#   2. A pinned Arm GNU toolchain, downloaded into <repo>/.toolchain on first configure
#      (disable with -DARM_TOOLCHAIN_AUTO_DOWNLOAD=OFF to use arm-none-eabi-gcc from PATH)
set(ARM_GNU_VERSION 15.2.rel1)
set(ARM_GNU_SHA256_x86_64  597893282ac8c6ab1a4073977f2362990184599643b4c5ee34870a8215783a16)
set(ARM_GNU_SHA256_aarch64 d061559d814b205ed30c5b7c577c03317ec447ca51cd5a159d26b12a5bbeb20c)

if(NOT ARM_TOOLCHAIN_PATH AND DEFINED ENV{ARM_TOOLCHAIN_PATH})
  set(ARM_TOOLCHAIN_PATH $ENV{ARM_TOOLCHAIN_PATH})
endif()
if(NOT DEFINED ARM_TOOLCHAIN_AUTO_DOWNLOAD)
  set(ARM_TOOLCHAIN_AUTO_DOWNLOAD ON)
endif()

if(NOT ARM_TOOLCHAIN_PATH AND ARM_TOOLCHAIN_AUTO_DOWNLOAD
   AND CMAKE_HOST_SYSTEM_NAME STREQUAL "Linux"
   AND DEFINED ARM_GNU_SHA256_${CMAKE_HOST_SYSTEM_PROCESSOR})
  set(_arm_name arm-gnu-toolchain-${ARM_GNU_VERSION}-${CMAKE_HOST_SYSTEM_PROCESSOR}-arm-none-eabi)
  set(_arm_root ${CMAKE_CURRENT_LIST_DIR}/../.toolchain/${_arm_name})
  if(NOT EXISTS ${_arm_root}/bin/arm-none-eabi-gcc)
    set(_arm_archive ${CMAKE_CURRENT_LIST_DIR}/../.toolchain/${_arm_name}.tar.xz)
    message(STATUS "${_arm_name} is not installed yet. Downloading it (about 180 MB, 1.1 GB extracted); this only happens once, so configuring takes a while.")
    file(DOWNLOAD
      https://developer.arm.com/-/media/Files/downloads/gnu/${ARM_GNU_VERSION}/binrel/${_arm_name}.tar.xz
      ${_arm_archive}
      EXPECTED_HASH SHA256=${ARM_GNU_SHA256_${CMAKE_HOST_SYSTEM_PROCESSOR}}
      SHOW_PROGRESS)
    message(STATUS "Extracting ${_arm_name}...")
    file(ARCHIVE_EXTRACT INPUT ${_arm_archive}
         DESTINATION ${CMAKE_CURRENT_LIST_DIR}/../.toolchain)
    file(REMOVE ${_arm_archive})
  endif()
  get_filename_component(ARM_TOOLCHAIN_PATH ${_arm_root}/bin ABSOLUTE)
  # Stable path for tools that need the toolchain location (e.g. .vscode/launch.json)
  file(CREATE_LINK ${_arm_name} ${CMAKE_CURRENT_LIST_DIR}/../.toolchain/current SYMBOLIC)
endif()

# The toolchain file is re-run for try_compile projects, which need this variable too
list(APPEND CMAKE_TRY_COMPILE_PLATFORM_VARIABLES ARM_TOOLCHAIN_PATH)

set(ARM_TOOLCHAIN_PREFIX arm-none-eabi)

if(ARM_TOOLCHAIN_PATH)
  set(_arm_hints HINTS ${ARM_TOOLCHAIN_PATH} NO_DEFAULT_PATH)
endif()

find_program(ARM_CC ${ARM_TOOLCHAIN_PREFIX}-gcc ${_arm_hints})
if(NOT ARM_CC)
  message(FATAL_ERROR "${ARM_TOOLCHAIN_PREFIX}-gcc not found. Install the Arm GNU toolchain "
                      "or set ARM_TOOLCHAIN_PATH to its bin directory.")
endif()
get_filename_component(_arm_bin ${ARM_CC} DIRECTORY)

set(CMAKE_C_COMPILER   ${_arm_bin}/${ARM_TOOLCHAIN_PREFIX}-gcc)
set(CMAKE_ASM_COMPILER ${_arm_bin}/${ARM_TOOLCHAIN_PREFIX}-gcc)
set(CMAKE_OBJCOPY      ${_arm_bin}/${ARM_TOOLCHAIN_PREFIX}-objcopy CACHE FILEPATH "")
set(CMAKE_SIZE         ${_arm_bin}/${ARM_TOOLCHAIN_PREFIX}-size CACHE FILEPATH "")

set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
