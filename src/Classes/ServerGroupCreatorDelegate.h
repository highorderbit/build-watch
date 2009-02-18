//
//  Copyright 2009 High Order Bit, Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ServerReport;

@protocol ServerGroupCreatorDelegate

- (void) serverGroupCreatedWithDisplayName:(NSString *)serverDisplayName
                     andInitialBuildReport:(ServerReport *)report;

- (BOOL) isServerGroupUrlValid:(NSString *)url;

@end