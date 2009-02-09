//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PListUtils : NSObject {
}

+ (NSDictionary *) readDictionaryFromPList:(NSString *)pList;

+ (void) writeDictionary:(NSDictionary *)dictionary toPList:(NSString *)pList;

@end
