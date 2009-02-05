//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ServerReport;

@protocol BuildServiceDelegate
- (void) report:(ServerReport *)report receivedFrom:(NSString *)server;
@end
