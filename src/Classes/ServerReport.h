//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ServerReport : NSObject {
    NSString * name;
    NSString * link;
    NSArray * projectReports;
}

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSArray * projectReports;

+ (id)report;
+ (id)reportWithName:(NSString *)aName
                link:(NSString *)aLink;
+ (id)reportWithName:(NSString *)aName
                link:(NSString *)aLink
      projectReports:(NSArray *)someReports;

- (id)init;
- (id)initWithName:(NSString *)aName
              link:(NSString *)aLink;
- (id)initWithName:(NSString *)aName
              link:(NSString *)aLink
           reports:(NSArray *)someReports;

@end
