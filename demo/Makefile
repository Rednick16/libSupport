ARCHS = arm64 #arm64e
TARGET := iphone:clang:latest:8.0
#INSTALL_TARGET_PROCESSES =  

DEBUG = 0
FINAL_PACKAGE = 1
FOR_RELEASE = 1
GO_EASY_ON_ME = 1

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = jailed_example

$(LIBRARY_NAME)_FILES = jailed.mm
$(LIBRARY_NAME)_CFLAGS = -fobjc-arc -fvisibility=hidden
$(LIBRARY_NAME)_CCFLAGS = -fobjc-arc -fvisibility=hidden
$(LIBRARY_NAME)_FRAMEWORKS = UIKit
$(LIBRARY_NAME)_INSTALL_PATH = @executable_path/Frameworks

$(LIBRARY_NAME)_LINKAGE_TYPE = dynamic

#include lib if you want to use it directly support.h 
#might get more detections to deal with tbh
$(LIBRARY_NAME)_LDFLAGS += #-L./support
$(LIBRARY_NAME)_LDFLAGS += #-lsupport

include $(THEOS_MAKE_PATH)/library.mk
