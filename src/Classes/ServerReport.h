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

@end
