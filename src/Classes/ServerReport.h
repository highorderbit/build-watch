//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ServerReport : NSObject {
    NSString * name;
    NSString * link;
    NSString * dashboardLink;
    NSArray * projectReports;
}

@property (nonatomic, copy) NSString * name;
@property (nonatomic, copy) NSString * link;
@property (nonatomic, copy) NSString * dashboardLink;
@property (nonatomic, copy) NSArray * projectReports;

+ (id)report;
+ (id)reportWithName:(NSString *)aName
                link:(NSString *)aLink;
+ (id)reportWithName:(NSString *)aName
                link:(NSString *)aLink
       dashboardLink:(NSString *)aDashboardLink
      projectReports:(NSArray *)someReports;

- (id)init;
- (id)initWithName:(NSString *)aName
              link:(NSString *)aLink;
- (id)initWithName:(NSString *)aName
              link:(NSString *)aLink
     dashboardLink:(NSString *)aDashboardLink
           reports:(NSArray *)someReports;

- (NSString *) longDescription;

@end
