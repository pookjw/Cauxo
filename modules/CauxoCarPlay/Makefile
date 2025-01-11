TARGET := iphone:clang:latest
INSTALL_TARGET_PROCESSES = CarPlay
THEOS_PACKAGE_SCHEME = rootless
export ARCHS = arm64 arm64e

TWEAK_NAME = CauxoCarPlay
$(TWEAK_NAME)_CFLAGS = -fno-objc-arc -fno-objc-weak -Wno-module-import-in-extern-c -Wno-unused-variable -std=c++2b -DUSE_ELLEKIT
$(TWEAK_NAME)_FRAMEWORKS = Foundation UIKit
$(TWEAK_NAME)_FILES = $(shell find . -type f -name  "*.mm")

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/aggregate.mk
