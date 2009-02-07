//
//  Copyright 2009 High Order Bit, Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ServerReport;

@protocol ServerReportBuilder

- (ServerReport *)serverReportFromData:(NSData *)data error:(NSError **)error;

@end
