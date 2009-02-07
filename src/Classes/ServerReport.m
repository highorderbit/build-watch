//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import "ServerReport.h"

@implementation ServerReport

@synthesize name;
@synthesize link;
@synthesize projectReports;

- (void)dealloc
{
    [name release];
    [link release];
    [projectReports release];
    [super dealloc];
}

+ (id)report
{
    return [[[[self class] alloc] init] autorelease];
}

+ (id)reportWithName:(NSString *)aName
                link:(NSString *)aLink
{
    return [[[[self class] alloc] reportWithName:aName link:aLink] autorelease];
}

+ (id)reportWithName:(NSString *)aName
                link:(NSString *)aLink
      projectReports:(NSArray *)someReports
{
    return [[[[self class] alloc] initWithName:aName
                                          link:aLink
                                       reports:someReports]
            autorelease];
}

- (id)init
{
    return [self initWithName:nil link:nil];
}

- (id)initWithName:(NSString *)aName
              link:(NSString *)aLink
{
    return [self initWithName:aName link:aLink reports:nil];
}

- (id)initWithName:(NSString *)aName
              link:(NSString *)aLink
           reports:(NSArray *)someReports
{
    if (self = [super init]) {
        self.name = aName;
        self.link = aLink;
        self.projectReports = someReports;
    }

    return self;
}

@end
