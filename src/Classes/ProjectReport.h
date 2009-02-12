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

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * label;
@property (nonatomic, retain) NSString * description;
@property (nonatomic, retain) NSDate * pubDate;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSString * forceBuildLink;
@property (nonatomic, assign) BOOL buildSucceeded;

+ (id)report;

@end
