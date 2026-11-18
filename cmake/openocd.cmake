# Locates OpenOCD for the `flash` target. Sets OPENOCD (empty if unavailable) and
# OPENOCD_DOWNLOAD (ON if the pinned copy still has to be downloaded at build time).
#
# Priority:
#   1. -DOPENOCD_EXECUTABLE=/path/to/openocd
#   2. A pinned xPack OpenOCD, downloaded into <repo>/.toolchain by the `openocd`
#      target during the first build (disable with -DOPENOCD_AUTO_DOWNLOAD=OFF
#      to use openocd from PATH)

set(XPACK_OPENOCD_VERSION 0.12.0-7)
set(XPACK_OPENOCD_SHA256_x86_64  94b3790983beaf8ed57e646c0620dd66d705fddae03d290823a6ed3b439468d6)
set(XPACK_OPENOCD_SHA256_aarch64 db73a3ab91c556ecec2405a7e02d404b11139df6aba1031cad94a7e6766d06cc)
set(XPACK_OPENOCD_ARCH_x86_64  x64)
set(XPACK_OPENOCD_ARCH_aarch64 arm64)

set(OPENOCD_EXECUTABLE "" CACHE FILEPATH "Path to an OpenOCD executable (default: download a pinned version)")
option(OPENOCD_AUTO_DOWNLOAD "Download a pinned OpenOCD into .toolchain/ when none is given" ON)

set(OPENOCD "")
set(OPENOCD_DOWNLOAD OFF)
if(OPENOCD_EXECUTABLE)
  set(OPENOCD ${OPENOCD_EXECUTABLE})
elseif(OPENOCD_AUTO_DOWNLOAD
       AND CMAKE_HOST_SYSTEM_NAME STREQUAL "Linux"
       AND DEFINED XPACK_OPENOCD_SHA256_${CMAKE_HOST_SYSTEM_PROCESSOR})
  set(_ocd_arch ${XPACK_OPENOCD_ARCH_${CMAKE_HOST_SYSTEM_PROCESSOR}})
  set(OPENOCD_NAME xpack-openocd-${XPACK_OPENOCD_VERSION})
  set(OPENOCD_DIR ${CMAKE_CURRENT_SOURCE_DIR}/.toolchain)
  set(OPENOCD_URL https://github.com/xpack-dev-tools/openocd-xpack/releases/download/v${XPACK_OPENOCD_VERSION}/${OPENOCD_NAME}-linux-${_ocd_arch}.tar.gz)
  set(OPENOCD_SHA256 ${XPACK_OPENOCD_SHA256_${CMAKE_HOST_SYSTEM_PROCESSOR}})
  set(OPENOCD ${OPENOCD_DIR}/${OPENOCD_NAME}/bin/openocd)
  set(OPENOCD_DOWNLOAD ON)
else()
  find_program(OPENOCD_ON_PATH openocd)
  if(OPENOCD_ON_PATH)
    set(OPENOCD ${OPENOCD_ON_PATH})
  endif()
endif()
