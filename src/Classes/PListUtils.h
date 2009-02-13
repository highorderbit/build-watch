//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PListUtils : NSObject {
}

+ (NSDictionary *) readDictionaryFromPlist:(NSString *)path;

+ (void) writeDictionary:(NSDictionary *)dictionary toPlist:(NSString *)path;

+ (NSString *) fullDocumentPathForPlist:(NSString *)plist;

+ (NSString *) fullBundlePathForPlist:(NSString *)plist;

@end
