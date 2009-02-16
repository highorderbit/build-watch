//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XmlObjectBuilder.h"

@interface XmlCompositeObjectBuilder : NSObject
                                       < XmlObjectBuilder >
{
    NSString * className;
    NSString * objectXpath;
    NSDictionary * classAttributes;

}

@property (nonatomic, copy) NSString * className;
@property (nonatomic, copy) NSString * objectXpath;
@property (nonatomic, copy) NSDictionary * classAttributes;

+ (id) builder;
- (id) init;

#pragma mark XmlObjectBuilder protocol

- (id) constructObjectFromXml:(CXMLNode *)xmlNode error:(NSError **)error;

@end
