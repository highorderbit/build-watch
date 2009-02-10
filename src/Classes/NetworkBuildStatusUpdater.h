//
//  Copyright High Order Bit, Inc. 2009 . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BuildStatusUpdaterDelegate.h"

@interface NetworkBuildStatusUpdater : NSObject
                                       < BuildStatusUpdater >
{
    NSObject<BuildStatusUpdaterDelegate> * delegate;

    NSURL * url;
    NSURLConnection * connection;
    NSMutableData * data;
}

@property (nonatomic, readonly) NSURL * url;
@property (nonatomic, retain) NSObject<BuildStatusUpdaterDelegate> * delegate;

- (id) initWithUrl:(NSURL *)url
          delegate:(NSObject<BuildStatusUpdaterDelegate> *)aDelegate;

@end
