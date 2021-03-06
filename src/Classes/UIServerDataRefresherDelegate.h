//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ServerDataRefresherDelegate.h"
#import "ServerGroupPropertyProvider.h"

@interface UIServerDataRefresherDelegate : NSObject
                                         < ServerDataRefresherDelegate >
{
    NSInteger numOutstandingRequests;
    UILabel * refreshLabel;
    UIActivityIndicatorView * activityIndicator;
    UILabel * updateLabel;
    IBOutlet UIView * view;

    NSMutableDictionary * failedServerRequests;
    NSMutableDictionary * serverDisplayNames;

    IBOutlet NSObject<ServerGroupPropertyProvider> *
        serverGroupPropertyProvider;
}

@end
