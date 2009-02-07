//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AboutDisplayer : NSObject {
    UINavigationController * navController;
    UIViewController * aboutViewController;
}

@property (nonatomic, retain) IBOutlet UINavigationController * navController;
@property (nonatomic, retain) IBOutlet UIViewController * aboutViewController;

- (IBAction) displayAboutView:(id)sender;

@end
