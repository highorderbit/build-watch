//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import "XmlDateObjectBuilder.h"
#import "TouchXML.h"

@implementation XmlDateObjectBuilder

@synthesize formatString;

+ (id) builder
{
    return [[[[self class] alloc] init] autorelease];
}

+ (id) builderWithXpath:(NSString *)anXpath
                  regex:(NSString *)aRegex
           formatString:(NSString *)aFormatString
{
    return [[[[self class] alloc] initWithXpath:anXpath
                                          regex:aRegex
                                   formatString:aFormatString] autorelease];
}

- (id) init
{
    return [self initWithXpath:nil regex:nil formatString:nil];
}

- (id) initWithXpath:(NSString *)anXpath
               regex:(NSString *)aRegex
        formatString:(NSString *)aFormatString
{
    if (self = [super initWithXpath:anXpath regex:aRegex])
        self.formatString = aFormatString;

    return self;
}

#pragma mark XmlObjectBuilder protocol implementation

- (id) constructObjectFromXml:(CXMLNode *)xmlNode error:(NSError **)error
{
    NSString * match = [super constructObjectFromXml:xmlNode error:error];

    if (!*error) {
        NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = formatString;
        NSDate * date = [formatter dateFromString:match];
        [formatter release];

        return date;
    }

    return [NSDate distantPast];  // returning nil will cause a crash
}

@end
