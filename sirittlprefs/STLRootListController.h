#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>

@interface STLRootListController : PSListController {
    NSArray* _allSpecifiers;
}
- (void)applyModificationsToSpecifiers:(NSMutableArray*)specifiers;
- (void)removeDisabledGroups:(NSMutableArray*)specifiers;
- (void)openTwitter;
- (void)respring:(id)sender;
- (void)donationLink;
@end
