//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ServerReport;

@protocol ServerReportBuilder

- (ServerReport *) serverReportFromUrl:(NSString *)url
                                  data:(NSData *)data
                                 error:(NSError **)error;
@end
