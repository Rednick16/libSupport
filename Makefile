ARCHS = arm64 arm64e #armv7 armv7s #i386 x86_64
THEOS_DEVICE_IP = 192.168.0.56

TARGET := iphone:latest:10.0 #simulator iphone
#TARGET := simulator:latest:1.0

DEBUG = 1
FINAL_PACKAGE = 1
FOR_RELEASE = 1
GO_EASY_ON_ME = 0

INCLUDES_PATH := \
	-Ifishhook/ \
	-Ilitehook/ \
	-Imemory/ \
	-Isupport/ \
	-Iwrapper/ \
	-Iswizzling/ \
	-Iapple_priv/ \
	-Iutilities/ \
	-I./

SUPPORT_FILES := \
	$(wildcard swizzling/*.m) \
	$(wildcard support/*.m | support/hooks/*.m) \
	$(wildcard wrapper/*.mm) \
	$(wildcard fishhook/*.m) \
	$(wildcard litehook/*.c) \
	$(wildcard memory/*.m | memory/*.mm) \
	$(wildcard utilities/*.m) \
	#$(wildcard MUHook/ObjC/*.m | MUHook/Symbol/*.m) \

include $(THEOS)/makefiles/common.mk

LIBRARY_BUILD_VERSION := $(shell grep -E "^Version:" control | cut -d' ' -f2)

LIBRARY_NAME = libSupport

$(LIBRARY_NAME)_FILES = $(SUPPORT_FILES)
$(LIBRARY_NAME)_CFLAGS = $(INCLUDES_PATH) -fobjc-arc -fvisibility=hidden 
$(LIBRARY_NAME)_CCFLAGS = -std=c++17 -fno-rtti -fobjc-arc -fvisibility=hidden
$(LIBRARY_NAME)_FRAMEWORKS = UIKit Foundation CoreFoundation #Security

ADDITIONAL_CFLAGS = -Wno-format -Wno-error -Wunused-variable -Wunused-but-set-variable -DLIBRARY_BUILD_VERSION=\"$(LIBRARY_BUILD_VERSION)\" -DTARGET_OS_BRIDGE=0 -DTARGET_OS_IOS=1 -DTARGET_OS_OSX=0 -DLS_DEBUG=DEBUG

$(LIBRARY_NAME)_INSTALL_PATH = @rpath
#$(LIBRARY_NAME)_LINKAGE_TYPE = static

include $(THEOS_MAKE_PATH)/library.mk

BOLD        := $(shell tput bold)
RESET       := $(shell tput sgr0)
RED			:= $(shell tput setaf 1)
GREEN		:= $(shell tput setaf 2)
BLUE		:= $(shell tput setaf 4)
PINK        := $(shell tput setaf 5)
WHITE       := $(shell tput setaf 7)
YELLOW      := $(shell tput setaf 3)

after-all::
	$(ECHO_NOTHING)echo "$(BOLD)$(GREEN)==> $(WHITE)Creating xcframework...$(RESET)"$(ECHO_END)
	@sh ./xcframework.sh
	$(ECHO_NOTHING)echo "$(BOLD)$(PINK)==> $(WHITE)Library version: $(YELLOW)$(LIBRARY_BUILD_VERSION)$(RESET)"$(ECHO_END)
.PHONY: after-all