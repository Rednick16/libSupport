ARCHS = arm64 #arm64e
TARGET := iphone:clang:latest:8.0
#INSTALL_TARGET_PROCESSES =  

DEBUG = 0
FINAL_PACKAGE = 1
FOR_RELEASE = 1
GO_EASY_ON_ME = 1

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = jailed_example

$(TWEAK_NAME)_FILES = Tweak.xm
$(TWEAK_NAME)_CFLAGS = -fobjc-arc -fvisibility=hidden
$(TWEAK_NAME)_CCFLAGS = -fobjc-arc -fvisibility=hidden
$(TWEAK_NAME)_FRAMEWORKS = UIKit

$(TWEAK_NAME)_LDFLAGS += -L./support
$(TWEAK_NAME)_LDFLAGS += -lsupport

include $(THEOS_MAKE_PATH)/tweak.mk
