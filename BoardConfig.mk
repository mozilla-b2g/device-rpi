
TARGET_GLOBAL_CFLAGS += -mfpu=vfp -mfloat-abi=softfp -Os
TARGET_GLOBAL_CPPFLAGS += -mfpu=vfp -mfloat-abi=softfp -Os

TARGET_ARCH := arm
TARGET_ARCH_VARIANT := armv6-vfp

TARGET_CPU_ABI := armeabi-v6l
TARGET_CPU_ABI2 := armeabi
ARCH_ARM_HAVE_VFP := true
ARCH_ARM_HAVE_TLS_REGISTER := true
TARGET_ARCH_VARIANT_CPU := arm1176jzf-s

# We have a prebuilt kernel, but it's not used in the same way as the
# typical gonk build setup.
TARGET_NO_KERNEL := true
TARGET_NO_RECOVERY := true

USE_OPENGL_RENDERER := true

BOARD_USES_GENERIC_AUDIO := false
BOARD_USES_ALSA_AUDIO := true
BUILD_WITH_ALSA_UTILS := true
BOARD_HAVE_BLUETOOTH := false
USE_CAMERA_STUB := true

BOARD_HAVE_BRCM_DAG := true

GECKO_CONFIGURE_ARGS := \
	--with-arch=armv6 \
	--disable-b2g-bt

GAIA_DEVICE_TYPE := tablet
BOARD_GAIA_MAKE_FLAGS := NOFTU=1 NO_LOCK_SCREEN=1 # GAIA_MEMORY_PROFILE=low ?
