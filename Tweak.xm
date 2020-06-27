#define PLIST_PATH @"/var/mobile/Library/Preferences/com.0xkuj.sirittlprefs.plist"
#define LOCKSCREEN 10 /* we are in lockscreen */
static BOOL isEnabled;
static BOOL lockscreenDurationEnabled;
static float siriDuration;
static float siriLSDuration;
static unsigned long long currLockState = 0;
static BOOL timerStarted = NO;

@interface AXSpringBoardServer
- (void)dismissSiri;
- (bool)isSiriVisible;
+ (id)server;
@end

@interface SBLockStateAggregator
-(unsigned long long)lockState;
@end


static void loadPrefs() {
	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:PLIST_PATH];
	
	/* is tweak enabled */
	isEnabled = [prefs objectForKey:@"isEnabled"] ? [[prefs objectForKey:@"isEnabled"] boolValue] : YES;
	/* siri normal duration */
	siriDuration = [prefs objectForKey:@"siriDuration"] ? [[prefs objectForKey:@"siriDuration"] floatValue] : 5;
	/* is siri lockscreen duration needed */
	lockscreenDurationEnabled = [prefs objectForKey:@"lockscreenDurationEnabled"] ? 
								[[prefs objectForKey:@"lockscreenDurationEnabled"] boolValue] : NO;

	/* siri lockscreen duration */
	siriLSDuration = [prefs objectForKey:@"siriLSDuration"] ? [[prefs objectForKey:@"siriLSDuration"] floatValue] : 5;
}

/* keep current status of siri idle mode */
static BOOL isCurrentlyIdle = NO;
/* status of siri has changed from normal to idle or the opposite */
%hook SiriPresentationViewController
- (void)siriViewController:(id)arg1 siriIdleAndQuietStatusDidChange:(BOOL)isSiriIdle {
    %orig;

    if (!isEnabled)
        return;	

	static NSTimer *siriTimer;

    if (isSiriIdle) {
		//if we wish to cancel the tweak on lockscreen when device is locked / unlocked
		if (lockscreenDurationEnabled && siriLSDuration == 0 && currLockState == LOCKSCREEN) {
			return;
		}
		float finalDuration;
		//lockstate == 3 means device is locked / unlocked but we are in lockscreen
		finalDuration = (currLockState == LOCKSCREEN && lockscreenDurationEnabled) ?
							siriLSDuration : siriDuration;
		

		/* start siri timer */
    	siriTimer = [NSTimer scheduledTimerWithTimeInterval:finalDuration
                                            target:self
                                            selector:@selector(siriShouldDismiss:)
                                            userInfo:nil
                                            repeats:NO];
		/* safe var to prevent crash */
		timerStarted = YES;
		isCurrentlyIdle = YES;
   }

   else {
	 isCurrentlyIdle = NO;
	 if (timerStarted) {
		[siriTimer invalidate];
		timerStarted = NO; 
	 }
   }

}

%new
- (void)siriShouldDismiss:(NSTimer *)siriTimer {
	/* siri got released without being idle, reset the timer and dont do anything */
	/* this was created in order to reset the timer when siri is activated again before she is dismissed */
	if (isCurrentlyIdle == NO) {
		[siriTimer invalidate];
		timerStarted = NO; 
		return;
	}
    [siriTimer invalidate];
	timerStarted = NO; 
	if ([[%c(AXSpringBoardServer) server] isSiriVisible])  {
		[[%c(AXSpringBoardServer) server] dismissSiri];
	}
}
%end

%hook SBLockStateAggregator
-(void)_updateLockState{
 %orig;
 if ([self lockState] == 3 || [self lockState] == 1) {
	  currLockState = LOCKSCREEN;
 }
 else {
	currLockState = 0;
 }
}
%end

%ctor {
	loadPrefs();
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("com.0xkuj.sirittlprefs.settingschanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
}
