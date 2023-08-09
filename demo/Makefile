ARCHS = arm64 arm64e #armv7 armv7s
# Support for armv7 has been dropped.

TARGET := iphone:clang:latest:8.0

DEBUG = 0
FINAL_PACKAGE = 1
FOR_RELEASE = 1

CFLAGS = -I./support -I../support

# Set MOBILE_THEOS to 1 if you are utilizing mobile theos. If you are not using mobile theos, set it to 0.
# Note that when using mobile theos, linking (libSupport) as a static library may not be feasible. In such cases, we will opt for the dynamic library instead.
# However, please be aware that there are some disadvantages to this approach. You will need to manually include the dylib (libSupport.dylib) in your frameworks folder.
MOBILE_THEOS = 1

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = BypassInjector

$(LIBRARY_NAME)_FILES = jailed.mm $(wildcard ../support/memory/*.cpp)
$(LIBRARY_NAME)_CFLAGS = -fobjc-arc -fvisibility=hidden
$(LIBRARY_NAME)_CCFLAGS = -std=c++17 -fobjc-arc -fvisibility=hidden
$(LIBRARY_NAME)_FRAMEWORKS = UIKit Security
$(LIBRARY_NAME)_INSTALL_PATH = @rpath/Frameworks

$(LIBRARY_NAME)_LINKAGE_TYPE = dynamic

ifeq ($(MOBILE_THEOS),1)
	$(LIBRARY_NAME)_LDFLAGS += -L./support/dynamic -L../support/dynamic
else
  	$(LIBRARY_NAME)_LDFLAGS += -L./support/static -L../support/static
endif
$(LIBRARY_NAME)_LDFLAGS += -lSupport

include $(THEOS_MAKE_PATH)/library.mk
