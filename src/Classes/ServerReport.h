//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ServerReport : NSObject {
    NSString * name;
    NSString * key;
    NSString * dashboardLink;
    NSArray * projectReports;
}

@property (nonatomic, copy) NSString * name;
@property (nonatomic, copy) NSString * key;
@property (nonatomic, copy) NSString * dashboardLink;
@property (nonatomic, copy) NSArray * projectReports;

+ (id)report;
+ (id)reportWithName:(NSString *)aName
                key:(NSString *)aKey;
+ (id)reportWithName:(NSString *)aName
                key:(NSString *)aKey
       dashboardLink:(NSString *)aDashboardLink
      projectReports:(NSArray *)someReports;

- (id)init;
- (id)initWithName:(NSString *)aName
              key:(NSString *)aKey;
- (id)initWithName:(NSString *)aName
              key:(NSString *)aKey
     dashboardLink:(NSString *)aDashboardLink
           reports:(NSArray *)someReports;

- (NSString *) longDescription;

@end
