
BOARDDIR := device/rpi/rpi

PRODUCT_COPY_FILES := \
	$(BOARDDIR)/init.rc:root/init.rc \
	$(BOARDDIR)/vold.fstab:system/etc/vold.fstab

PRODUCT_PROPERTY_OVERRIDES :=

$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base.mk)

PRODUCT_NAME := rpi
PRODUCT_DEVICE := rpi
# PRODUCT_BRAND := rpi
# PRODUCT_MODEL := rpi
# PRODUCT_MANUFACTURER := rpi
# PRODUCT_RELEASE_NAME := rpi

# TODO: PRODUCT_PROPERTY_OVERRIDES := ...

# TODO: PRODUCT_PACKAGES := ...
