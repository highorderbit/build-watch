//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import "XmlRegexObjectBuilder.h"
#import "TouchXML.h"
#import "RegexKitLite.h"
#import "NSString+BuildWatchAdditions.h"
#import "NSError+BuildWatchAdditions.h"

@implementation XmlRegexObjectBuilder

@synthesize xpath;
@synthesize regex;
@synthesize replacementString;

+ (id) builder
{
    return [[[[self class] alloc] init] autorelease];
}

+ (id) builderWithXpath:(NSString *)anXpath
                  regex:(NSString *)aRegex
{
    return [[[[self class] alloc] initWithXpath:anXpath
                                          regex:aRegex] autorelease];
}

+ (id) builderWithXpath:(NSString *)anXpath
                  regex:(NSString *)aRegex
      replacementString:(NSString *)aReplacementString
{
    return [[[[self class] alloc] initWithXpath:anXpath
                                          regex:aRegex
                              replacementString:aReplacementString]
            autorelease];
}

- (void) dealloc
{
    [xpath release];
    [regex release];
    [replacementString release];
    [super dealloc];
}

- (id) init
{
    return [self initWithXpath:nil regex:nil];
}

- (id) initWithXpath:(NSString *)anXpath
               regex:(NSString *)aRegex
{
    return [self initWithXpath:anXpath
                         regex:aRegex
             replacementString:nil];
}

- (id) initWithXpath:(NSString *)anXpath
               regex:(NSString *)aRegex
   replacementString:(NSString *)aReplacementString
{
    if (self = [super init]) {
        self.xpath = anXpath;
        self.regex = aRegex;
        self.replacementString = aReplacementString;
    }

    return self;
}

#pragma mark XmlObjectBuilder protocol implementation

- (id) constructObjectFromXml:(CXMLNode *)xmlNode error:(NSError **)error
{
    NSArray * nodes = [xmlNode nodesForXPath:xpath error:error];
    if (*error || nodes.count != 1)
        return nil;

    NSString * xmlValue = [[nodes lastObject] stringValue];
    if (replacementString)
        return [xmlValue stringByReplacingOccurrencesOfRegex:regex
                                                  withString:replacementString];
    else {
        NSString * result = [xmlValue stringByMatchingRegex:regex];
        return result ? result : @"";
    }
}

@end