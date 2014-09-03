
BOARDDIR := device/rpi/rpi

PRODUCT_COPY_FILES := \
	development/data/etc/apns-conf.xml:system/etc/apns-conf.xml \
	development/data/etc/vold.conf:system/etc/vold.conf \
	development/tools/emulator/system/camera/media_profiles.xml:system/etc/media_profiles.xml \
	brcm_usrlib/dag/vmcsx/egl.cfg:system/lib/egl/egl.cfg \
	$(BOARDDIR)/init.rc:root/init.rc \
	$(BOARDDIR)/vold.fstab:system/etc/vold.fstab

PRODUCT_PROPERTY_OVERRIDES := \
	ro.ril.hsxpa=1 \
	ro.ril.gprsclass=10

PRODUCT_PACKAGES := \
	audio.primary.goldfish \
	libGLES_hgl

$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base.mk)

PRODUCT_NAME := rpi
PRODUCT_DEVICE := rpi
# PRODUCT_BRAND := rpi
# PRODUCT_MODEL := rpi
# PRODUCT_MANUFACTURER := rpi
# PRODUCT_RELEASE_NAME := rpi

# TODO: PRODUCT_PROPERTY_OVERRIDES := ...

# TODO: PRODUCT_PACKAGES := ...
