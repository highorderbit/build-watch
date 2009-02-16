//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import "XmlCompositeObjectBuilder.h"
#import "TouchXML.h"
#import "NSError+BuildWatchAdditions.h"

@interface XmlCompositeObjectBuilder (Private)
- (id) constructionFailed:(NSError **)error;
@end

@implementation XmlCompositeObjectBuilder

@synthesize className;
@synthesize objectXpath;
@synthesize classAttributes;

+ (id) builder
{
    return [[[[self class] alloc] init] autorelease];
}

- (void) dealloc
{
    [className release];
    [objectXpath release];
    [classAttributes release];
    [super dealloc];
}

- (id) init
{
    return (self = [super init]);
}

#pragma mark XmlObjectBuilder protocol implementation

- (id) constructObjectFromXml:(CXMLNode *)node
                        error:(NSError **)error
{
    NSArray * nodes = [node nodesForXPath:self.objectXpath error:error];
    if (*error)
        return [self constructionFailed:error];

    NSMutableArray * objects = [NSMutableArray arrayWithCapacity:nodes.count];
    for (CXMLNode * objectNode in nodes) {
        Class class = NSClassFromString(self.className);
        id obj = [[[class alloc] init] autorelease];

        NSEnumerator * enumerator = [classAttributes keyEnumerator];
        for (NSString * attrName = [enumerator nextObject];
             attrName;
             attrName = [enumerator nextObject])
        {
            NSObject<XmlObjectBuilder> * builder =
                [classAttributes objectForKey:attrName];

            id attrValue =
                [builder constructObjectFromXml:objectNode error:error];

            if (*error)
                return [self constructionFailed:error];

            NSLog(@"%@: Setting key: '%@' = '%@'.", obj, attrName, attrValue);
            [obj setValue:attrValue forKey:attrName];
        }

        [objects addObject:obj];
    }

    return objects;
}

- (id) constructionFailed:(NSError **)error
{
    *error = [NSError
         errorWithLocalizedDescription:
            NSLocalizedString(@"xml.parse.failed", @"")
                             rootCause:*error];

    return nil;
}

@end
