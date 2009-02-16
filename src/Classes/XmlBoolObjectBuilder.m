//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import "XmlBoolObjectBuilder.h"
#import "TouchXML.h"
#import "NSString+BuildWatchAdditions.h"

@implementation XmlBoolObjectBuilder

@synthesize equalityString;

+ (id) builder
{
    return [[[[self class] alloc] init] autorelease];
}

+ (id) builderWithXpath:(NSString *)anXpath
                  regex:(NSString *)aRegex 
         equalityString:(NSString *)anEqualityString
{
    return [[[[self class] alloc] initWithXpath:anXpath
                                          regex:aRegex
                                 equalityString:anEqualityString] autorelease];
}

- (void) dealloc
{
    [equalityString release];
    [super dealloc];
}

- (id) init
{
    return [self initWithXpath:nil regex:nil equalityString:nil];
}

- (id) initWithXpath:(NSString *)anXpath
               regex:(NSString *)aRegex 
      equalityString:(NSString *)anEqualityString
{
    if (self = [super initWithXpath:anXpath regex:aRegex])
        self.equalityString = anEqualityString;

    return self;
}

#pragma mark XmlObjectBuilder protocol implementation

- (id) constructObjectFromXml:(CXMLNode *)xmlNode error:(NSError **)error
{
    NSString * match = [super constructObjectFromXml:xmlNode error:error];
    BOOL matches = (!*error && match && [match isEqualToString:equalityString]);

    return [NSNumber numberWithBool:matches];
}

@end
