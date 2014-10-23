
BOARDDIR := device/rpi/rpi

PRODUCT_COPY_FILES := \
	brcm_usrlib/dag/vmcsx/egl.cfg:system/lib/egl/egl.cfg \
	$(BOARDDIR)/b2g.sh:system/bin/b2g.sh \
	$(BOARDDIR)/bootanimation.zip:system/media/bootanimation.zip \
	$(BOARDDIR)/init.rc:root/init.rc \
	$(BOARDDIR)/volume.cfg:system/etc/volume.cfg \
	$(BOARDDIR)/wpa_supplicant.conf:system/etc/wifi/wpa_supplicant.conf \
	$(BOARDDIR)/prebuilt/bootcode.bin:boot/bootcode.bin \
	$(BOARDDIR)/prebuilt/cmdline.txt:boot/cmdline.txt \
	$(BOARDDIR)/prebuilt/config.txt:boot/config.txt \
	$(BOARDDIR)/prebuilt/fixup_cd.dat:boot/fixup_cd.dat \
	$(BOARDDIR)/prebuilt/fixup.dat:boot/fixup.dat \
	$(BOARDDIR)/prebuilt/fixup_x.dat:boot/fixup_x.dat \
	$(BOARDDIR)/prebuilt/kernel.img:boot/kernel.img \
	$(BOARDDIR)/prebuilt/8192cu.ko:system/lib/modules/8192cu.ko \
	$(BOARDDIR)/prebuilt/fbtft_device.ko:system/lib/modules/fbtft_device.ko \
	$(BOARDDIR)/prebuilt/start_cd.elf:boot/start_cd.elf \
	$(BOARDDIR)/prebuilt/start.elf:boot/start.elf \
	$(BOARDDIR)/prebuilt/start_x.elf:boot/start_x.elf

PRODUCT_CHARACTERISTICS := tablet

PRODUCT_PROPERTY_OVERRIDES := \
	wifi.interface=wlan0

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
