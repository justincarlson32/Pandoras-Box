SYSROOT = $(THEOS)/sdks/iPhoneOS13.1.sdk
ARCHS = armv7 arm64 arm64e

include /var/theos/makefiles/common.mk

TWEAK_NAME = PandorasBox
PandorasBox_FILES = Tweak.xm PBListItem.m PBQueuePlayer.m
PandorasBox_FRAMEWORKS = UIKit AssetsLibrary AVFoundation AVKit CoreMedia

include /var/theos/makefiles/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"

