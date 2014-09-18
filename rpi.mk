
BOARDDIR := device/rpi/rpi

$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base.mk)

PRODUCT_NAME := rpi
PRODUCT_DEVICE := rpi
# PRODUCT_BRAND := rpi
# PRODUCT_MODEL := rpi
# PRODUCT_MANUFACTURER := rpi
# PRODUCT_RELEASE_NAME := rpi

PRODUCT_COPY_FILES := \
	brcm_usrlib/dag/vmcsx/egl.cfg:system/lib/egl/egl.cfg \
	$(BOARDDIR)/init.rc:root/init.rc \
	$(BOARDDIR)/vold.fstab:system/etc/vold.fstab \
	$(BOARDDIR)/bootanimation.zip:system/media/bootanimation.zip

PRODUCT_PACKAGES := \
	audio.primary.goldfish \
	libGLES_hgl

PRODUCT_PROPERTY_OVERRIDES := \
	ro.moz.bootanim.bgcolor=0x00539f
