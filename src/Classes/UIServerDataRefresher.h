//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ServerDataRefresher.h"

@interface UIServerDataRefresher : NSObject {
    IBOutlet NSObject<ServerDataRefresher> * refresher;
}

- (IBAction) refreshAllServerData:(id)sender;

@end
