//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XmlObjectBuilder.h"

@interface ServerReportBuilderFactory : NSObject

+ (NSObject<XmlObjectBuilder> *) builderForServerUrl:(NSString *)serverUrl;

@end
