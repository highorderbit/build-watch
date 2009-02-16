//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XmlObjectBuilder.h"

@class CXMLNode;

@interface XmlRegexObjectBuilder : NSObject
                                   < XmlObjectBuilder >
{
    NSString * xpath;
    NSString * regex;
    NSString * replacementString;
}

@property (nonatomic, copy) NSString * xpath;
@property (nonatomic, copy) NSString * regex;
@property (nonatomic, copy) NSString * replacementString;

+ (id) builder;
+ (id) builderWithXpath:(NSString *)anXpath
                  regex:(NSString *)aRegex;
+ (id) builderWithXpath:(NSString *)anXpath
                  regex:(NSString *)aRegex
      replacementString:(NSString *)aReplacementString;

- (id) init;
- (id) initWithXpath:(NSString *)anXpath
               regex:(NSString *)aRegex;
- (id) initWithXpath:(NSString *)anXpath
               regex:(NSString *)aRegex
   replacementString:(NSString *)aReplacementString;

#pragma mark XmlObjectBuilder protocol

- (id) constructObjectFromXml:(CXMLNode *)xmlNode error:(NSError **)error;

@end
