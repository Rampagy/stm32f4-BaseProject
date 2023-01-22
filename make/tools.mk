###############################################################
#
# Installers for tools required by the rootloader builds
#
# NOTE: These are not tied to the default goals
#       and must be invoked manually
#
###############################################################


####################
# ARM (Cortex) SDK #
####################
ARM_SDK_DIR := $(TOOLS_DIR)/arm-gnu-toolchain-12.2.rel1
SPLIT_URL := .rel1-

.PHONY: arm_sdk_install
ifdef LINUX
    arm_sdk_install: ARM_SDK_URL  := https://developer.arm.com/-/media/Files/downloads/gnu/12.2.rel1/binrel/arm-gnu-toolchain-12.2.rel1-x86_64-arm-none-eabi.tar.xz?rev=7bd049b7a3034e64885fa1a71c12f91d&hash=2C60D7D4E432953DB65C4AA2E7129304F9CD05BF
endif

ifdef MACOS
    arm_sdk_install: ARM_SDK_URL  := https://developer.arm.com/-/media/Files/downloads/gnu/12.2.rel1/binrel/arm-gnu-toolchain-12.2.rel1-darwin-x86_64-arm-none-eabi.tar.xz?rev=d317081ad790455196a077cae4af518f&hash=6CF68010758E3E75F72749AD40E97F5E44581C8A
endif

ifdef WINDOWS
    arm_sdk_install: ARM_SDK_URL  := https://developer.arm.com/-/media/Files/downloads/gnu/12.2.rel1/binrel/arm-gnu-toolchain-12.2.rel1-mingw-w64-i686-arm-none-eabi.zip?rev=709f3f15b2ee4763b186c10153ee6ca9&hash=2C33429A38E6D27CA40FD55B8E3D56B347F5EC1F
endif

arm_sdk_install: ARM_SDK_FILE := $(join $(word 1,$(subst $(SPLIT_URL), ,$(notdir $(ARM_SDK_URL)))),.rel1.zip)
# order-only prereq on directory existance:
arm_sdk_install: | $(DL_DIR) $(TOOLS_DIR)
arm_sdk_install: arm_sdk_clean
ifneq ($(OSFAMILY), windows)
	# download the source only if it's newer than what we already have
	$(V1) wget --no-check-certificate -N -P "$(DL_DIR)" "$(ARM_SDK_URL)"

	# binary only release so just extract it
	$(V1) tar -C $(TOOLS_DIR) -xjf "$(DL_DIR)/$(ARM_SDK_FILE)"
else
	$(V1) curl --continue - --location --insecure --output "$(DL_DIR)/$(ARM_SDK_FILE)" "$(ARM_SDK_URL)"
	$(V1) powershell -noprofile -command Expand-Archive -Force -DestinationPath $(ARM_SDK_DIR) -LiteralPath "$(DL_DIR)/$(ARM_SDK_FILE)"
endif

	$(V1) python "$(MAKE_DIR)/move_up_one_folder.py" $(ARM_SDK_DIR)

.PHONY: arm_sdk_clean
arm_sdk_clean:
ifneq ($(OSFAMILY), windows)
	$(V1) [ ! -d "$(ARM_SDK_DIR)" ] || $(RM) -r $(ARM_SDK_DIR)
else
	$(V1) powershell -noprofile -command "& {if (Test-Path $(ARM_SDK_DIR)) {Remove-Item -Recurse $(ARM_SDK_DIR)}}"
endif



##############################
#
# Set up paths to tools
#
##############################

ifneq ("$(wildcard $(ARM_SDK_DIR))","")
    ARM_SDK_PREFIX := $(ARM_SDK_DIR)/bin/arm-none-eabi-
else
    ifneq ($(MAKECMDGOALS),arm_sdk_install)
        $(info **WARNING** ARM-SDK not in $(ARM_SDK_DIR)  Please run 'make arm_sdk_install')
    endif
    # not installed, hope it's in the path...
    ARM_SDK_PREFIX ?= arm-none-eabi-
endif

# Get the ARM GCC version
ifneq ("$(ARM_SDK_PREFIX)","")
    ARM_GCC_VERSION := $(shell $(ARM_SDK_PREFIX)gcc -dumpversion)
endif

# Get the git branch name, commit hash, and clean/dirty state
GIT_BRANCH_NAME := $(shell git rev-parse --abbrev-ref HEAD)
GIT_COMMIT_HASH := $(shell git rev-parse --short HEAD)
GIT_DIRTY_LABEL := $(shell git diff --quiet || echo -dirty)

