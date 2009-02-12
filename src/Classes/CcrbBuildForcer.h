//
//  Copyright 2009 High Order Bit, Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BuildForcer.h"
#import "BuildForcerDelegate.h"

@interface CcrbBuildForcer : NSObject
                             < BuildForcer >
{
    NSObject<BuildForcerDelegate> * delegate;

    NSMutableDictionary * projectsForConnections;
    NSMutableDictionary * forceBuildUrlsForConnections;
}

@property (nonatomic, retain) IBOutlet NSObject<BuildForcerDelegate> * delegate;

@end
