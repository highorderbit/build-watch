//
//  Copyright 2009 High Order Bit, Inc.. All rights reserved.
//

#import "XmlSimpleObjectBuilder.h"
#import "TouchXML.h"

@implementation XmlSimpleObjectBuilder

@synthesize xpath;

+ (id) builder
{
    return [[[[self class] alloc] init] autorelease];
}

+ (id) builderWithXpath:(NSString *)anXpath
{
    return [[[[self class] alloc] initWithXpath:anXpath] autorelease];
}

- (void) dealloc
{
    [xpath release];
    [super dealloc];
}

- (id) init
{
    return [self initWithXpath:nil];
}

- (id) initWithXpath:(NSString *)anXpath
{
    if (self = [super init])
        self.xpath = anXpath;

    return self;
}

#pragma mark XmlObjectBuilder protocol implementation

- (id) constructObjectFromXml:(CXMLNode *)xmlNode error:(NSError **)error
{
    NSArray * nodes = [xmlNode nodesForXPath:xpath error:error];
    if (*error || nodes.count != 1)
        return nil;

    NSString * result = [[nodes lastObject] stringValue];
    return result ? result : @"";
}

@end