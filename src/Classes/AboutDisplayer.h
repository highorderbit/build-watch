//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PListUtils.h"

@interface AboutDisplayer : UIViewController {
    UINavigationController * navController;
    UIBarButtonItem * aboutButton;
    UILabel * versionLabel;
    
    BOOL displayed;
}

@property (nonatomic, retain) IBOutlet UINavigationController * navController;
@property (nonatomic, retain) IBOutlet UIBarButtonItem * aboutButton;
@property (nonatomic, retain) IBOutlet UILabel * versionLabel;

- (IBAction) displayAboutView:(id)sender;
- (IBAction) displayWebsite:(id)sender;
- (IBAction) sendFeedback:(id)sender;

@end
