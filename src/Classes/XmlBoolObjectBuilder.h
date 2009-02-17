//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XmlObjectBuilder.h"
#import "XmlRegexObjectBuilder.h"

@interface XmlBoolObjectBuilder : XmlRegexObjectBuilder
                                  < XmlObjectBuilder >
{
    NSString * equalityString;
}

@property (nonatomic, copy) NSString * equalityString;

- (id) init;
- (id) initWithXpath:(NSString *)anXpath
               regex:(NSString *)aRegex 
      equalityString:(NSString *)anEqualityString;

+ (id) builder;
+ (id) builderWithXpath:(NSString *)anXpath
                  regex:(NSString *)aRegex 
         equalityString:(NSString *)anEqualityString;

#pragma mark XmlObjectBuilder protocol

- (id) constructObjectFromXml:(CXMLNode *)xmlNode error:(NSError **)error;

@end
