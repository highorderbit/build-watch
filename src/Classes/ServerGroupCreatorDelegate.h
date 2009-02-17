//
//  Copyright 2009 High Order Bit, Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ServerReport;

@protocol ServerGroupCreatorDelegate

- (void) serverGroupCreatedWithName:(NSString *)server
              andInitialBuildReport:(ServerReport *)report;

- (BOOL) isServerGroupNameValid:(NSString *)server;

@end
