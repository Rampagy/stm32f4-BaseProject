# Run at build time by the `openocd` target: cmake -DOPENOCD_NAME=... -P download_openocd.cmake
# Required: OPENOCD_NAME OPENOCD_URL OPENOCD_SHA256 OPENOCD_DIR

if(EXISTS ${OPENOCD_DIR}/${OPENOCD_NAME}/bin/openocd)
  return()
endif()

message(STATUS "OpenOCD ${OPENOCD_NAME} is not installed yet. Downloading it (about 3 MB); this only happens once.")
set(_archive ${OPENOCD_DIR}/${OPENOCD_NAME}.tar.gz)
file(DOWNLOAD ${OPENOCD_URL} ${_archive}
     EXPECTED_HASH SHA256=${OPENOCD_SHA256}
     SHOW_PROGRESS)
message(STATUS "Extracting ${OPENOCD_NAME}...")
file(ARCHIVE_EXTRACT INPUT ${_archive} DESTINATION ${OPENOCD_DIR})
file(REMOVE ${_archive})
# Stable path for .vscode/launch.json
file(CREATE_LINK ${OPENOCD_NAME} ${OPENOCD_DIR}/openocd SYMBOLIC)
message(STATUS "OpenOCD installed in ${OPENOCD_DIR}/${OPENOCD_NAME}")
