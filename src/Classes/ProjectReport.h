//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProjectReport : NSObject {
    NSString * name;
    NSString * label;
    NSString * description;
    NSDate * pubDate;
    NSString * link;
    NSString * forceBuildLink;
    BOOL buildSucceeded;
}

@property (nonatomic, copy) NSString * name;
@property (nonatomic, copy) NSString * label;
@property (nonatomic, copy) NSString * description;
@property (nonatomic, copy) NSDate * pubDate;
@property (nonatomic, copy) NSString * link;
@property (nonatomic, copy) NSString * forceBuildLink;
@property (nonatomic, assign) BOOL buildSucceeded;

+ (id)report;

@end
