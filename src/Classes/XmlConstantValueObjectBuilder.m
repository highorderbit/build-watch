//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import "XmlConstantValueObjectBuilder.h"

@implementation XmlConstantValueObjectBuilder

@synthesize constantValue;

+ (id) builder
{
    return [[[[self class] alloc] init] autorelease];
}

+ (id) builderWithConstantValue:(NSString *)aConstantValue
{
    return [[[[self class] alloc]
        initWithConstantValue:aConstantValue] autorelease];
}

- (void) dealloc
{
    [constantValue release];
    [super dealloc];
}

- (id) init
{
    return [self initWithConstantValue:nil];
}

- (id) initWithConstantValue:(NSString *)aConstantValue
{
    if (self = [super init])
        self.constantValue = aConstantValue;

    return self;
}

#pragma mark XmlObjectBuilder protocol

- (id) constructObjectFromXml:(CXMLNode *)xmlNode error:(NSError **)error
{
    return self.constantValue;
}

@end
