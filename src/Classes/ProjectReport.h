//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProjectReport : NSObject {
    NSString * name;
    NSString * description;
    NSDate * pubDate;
    NSString * link;
    BOOL buildSucceeded;
}

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * description;
@property (nonatomic, retain) NSDate * pubDate;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, assign) BOOL buildSucceeded;

+ (id)report;

@end
