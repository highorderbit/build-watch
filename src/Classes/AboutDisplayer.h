//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PListUtils.h"
#import "ConfigReader.h"

@interface AboutDisplayer : UIViewController {
    UIViewController * rootView;
    UIBarButtonItem * aboutButton;
    UILabel * versionLabel;
    NSObject<ConfigReader> * configReader;
    
    BOOL displayed;
}

@property (nonatomic, retain) IBOutlet UIViewController * rootView;
@property (nonatomic, retain) IBOutlet UIBarButtonItem * aboutButton;
@property (nonatomic, retain) IBOutlet UILabel * versionLabel;
@property (nonatomic, retain) IBOutlet NSObject<ConfigReader> * configReader;

- (IBAction) displayAboutView:(id)sender;
- (IBAction) displayWebsite:(id)sender;
- (IBAction) sendFeedback:(id)sender;

@end
