//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XmlObjectBuilder.h"

@class CXMLNode;

@interface XmlSimpleObjectBuilder : NSObject
                                    < XmlObjectBuilder >
{
    NSString * xpath;
}

@property (nonatomic, copy) NSString * xpath;

+ (id) builder;
+ (id) builderWithXpath:(NSString *)anXpath;

- (id) init;
- (id) initWithXpath:(NSString *)anXpath;

#pragma mark XmlObjectBuilder protocol implementation

- (id) constructObjectFromXml:(CXMLNode *)xmlNode error:(NSError **)error;

@end
