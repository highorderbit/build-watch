//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XmlObjectBuilder.h"

@interface XmlConstantValueObjectBuilder : NSObject
                                           < XmlObjectBuilder >
{
    NSString * constantValue;
}

@property (nonatomic, copy) NSString * constantValue;

+ (id) builder;
+ (id) builderWithConstantValue:(NSString *)aConstantValue;

- (id) init;
- (id) initWithConstantValue:(NSString *)aConstantValue;

#pragma mark XmlObjectBuilder protocol

- (id) constructObjectFromXml:(CXMLNode *)xmlNode error:(NSError **)error;

@end
