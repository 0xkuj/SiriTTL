include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = SiriTTLPrefs
SiriTTLPrefs_FILES = STLRootListController.m
SiriTTLPrefs_INSTALL_PATH = /Library/PreferenceBundles
SiriTTLPrefs_FRAMEWORKS = UIKit
SiriTTLPrefs_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/SiriTTLPrefs.plist$(ECHO_END)
