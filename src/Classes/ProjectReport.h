//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProjectReport : NSObject {
    NSString * title;
    NSString * description;
    NSDate * pubDate;
    NSString * link;
}

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * description;
@property (nonatomic, retain) NSDate * pubDate;
@property (nonatomic, retain) NSString * link;

@end
