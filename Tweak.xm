#define PLIST_PATH @"/var/mobile/Library/Preferences/com.0xkuj.sirittlprefs.plist"
static BOOL isEnabled;
static float siriDuration;

@interface AXSpringBoardServer
- (void)dismissSiri;
- (bool)isSiriVisible;
+ (id)server;
@end

static void loadPrefs() {
	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:PLIST_PATH];

	isEnabled = [prefs objectForKey:@"isEnabled"] ? [[prefs objectForKey:@"isEnabled"] boolValue] : YES;
	siriDuration = [prefs objectForKey:@"siriDuration"] ? [[prefs objectForKey:@"siriDuration"] floatValue] : 5;
}

static BOOL isCurrentlyIdle = NO;
%hook SiriPresentationViewController
- (void)siriViewController:(id)arg1 siriIdleAndQuietStatusDidChange:(BOOL)isSiriIdle {
    %orig;

    if (!isEnabled)
        return;

	static NSTimer *siriTimer;

    if (isSiriIdle) {
    	siriTimer = [NSTimer scheduledTimerWithTimeInterval:siriDuration
                                            target:self
                                            selector:@selector(siriShouldDismiss:)
                                            userInfo:nil
                                            repeats:NO];
		isCurrentlyIdle = YES;
   }

   else if (siriTimer) {
	 isCurrentlyIdle = NO;
   }

}

%new
- (void)siriShouldDismiss:(NSTimer *)siriTimer {
	if (isCurrentlyIdle == NO) {
		[siriTimer invalidate];
		return;
	}
    [siriTimer invalidate];
	if ([[%c(AXSpringBoardServer) server] isSiriVisible])  {
		[[%c(AXSpringBoardServer) server] dismissSiri];
	}
}
%end

%ctor {
	loadPrefs();
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("com.0xkuj.sirittlprefs.settingschanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
}
