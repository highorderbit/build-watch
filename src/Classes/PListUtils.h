//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlistUtils : NSObject {
}

+ (NSDictionary *) readDictionaryFromPlist:(NSString *)path;

+ (void) writeDictionary:(NSDictionary *)dictionary toPlist:(NSString *)path;

+ (NSArray *) readArrayFromPlist:(NSString *)path;

+ (void) writeArray:(NSArray *)array toPlist:(NSString *)path;

+ (NSString *) fullDocumentPathForPlist:(NSString *)plist;

+ (NSString *) fullBundlePathForPlist:(NSString *)plist;

@end
