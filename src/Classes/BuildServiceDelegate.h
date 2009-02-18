//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServerReportBuilder.h"

@class ServerReport;

@protocol BuildServiceDelegate
- (void) report:(ServerReport *)report receivedFrom:(NSString *)serverUrl;
- (void) attemptToGetReportFromServer:(NSString *)serverUrl
                     didFailWithError:(NSError *)error;
- (NSObject<ServerReportBuilder> *) builderForServer:(NSString *)server;
@end