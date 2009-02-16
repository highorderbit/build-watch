//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XmlRegexObjectBuilder.h"

@class CXMLNode;

@interface XmlDateObjectBuilder : XmlRegexObjectBuilder
                                  < XmlObjectBuilder >
{
    NSString * formatString;
}

@property (nonatomic, copy) NSString * formatString;

+ (id) builder;
+ (id) builderWithXpath:(NSString *)anXpath
                  regex:(NSString *)aRegex
           formatString:(NSString *)aFormatString;

- (id) init;
- (id) initWithXpath:(NSString *)anXpath
               regex:(NSString *)aRegex
        formatString:(NSString *)aFormatString;

#pragma mark XmlObjectBuilder protocol

- (id) constructObjectFromXml:(CXMLNode *)xmlNode error:(NSError **)error;

@end
