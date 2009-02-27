//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProjectReport : NSObject {
    NSString * name;
    NSString * forceBuildLink;
    
    NSString * buildLabel;
    NSString * buildDescription;
    NSDate * buildPubDate;
    NSString * buildDashboardLink;
    BOOL buildSucceededState;
}

@property (nonatomic, copy) NSString * name;
@property (nonatomic, copy) NSString * forceBuildLink;

@property (nonatomic, copy) NSString * buildLabel;
@property (nonatomic, copy) NSString * buildDescription;
@property (nonatomic, copy) NSDate * buildPubDate;
@property (nonatomic, copy) NSString * buildDashboardLink;
@property (nonatomic, assign) BOOL buildSucceededState;

+ (id)report;

- (NSString *) longDescription;

@end
