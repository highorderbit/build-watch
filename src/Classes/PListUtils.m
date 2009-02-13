//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import "PlistUtils.h"

@implementation PlistUtils

+ (NSDictionary *) readDictionaryFromPlist:(NSString *)path
{
    NSString * errorDesc = nil;
    NSPropertyListFormat format;
    NSData * plistXml = [[NSFileManager defaultManager] contentsAtPath:path];
    
    NSDictionary * temp =
        (NSDictionary *)
        [NSPropertyListSerialization
        propertyListFromData:plistXml
        mutabilityOption:NSPropertyListMutableContainersAndLeaves
        format:&format
        errorDescription:&errorDesc];
    
    if (!temp)
        NSLog(errorDesc);
    
    return temp;
}

+ (void) writeDictionary:(NSDictionary *)dictionary toPlist:(NSString *)path
{
    NSString * errorDesc;
    NSData * plistData =
        [NSPropertyListSerialization
        dataFromPropertyList:dictionary
        format:NSPropertyListXMLFormat_v1_0
        errorDescription:&errorDesc];
    
    if (plistData)
        [plistData writeToFile:path atomically:YES];
    else
        NSLog(errorDesc);
}

+ (NSString *) fullDocumentPathForPlist:(NSString *)plist
{
    NSString * file = [plist stringByAppendingString:@".plist"];
    NSArray * paths =
        NSSearchPathForDirectoriesInDomains(
        NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentsDirectory = [paths objectAtIndex:0];
    
    return [documentsDirectory stringByAppendingPathComponent:file];
}

+ (NSString *) fullBundlePathForPlist:(NSString *)plist
{    
    return [[NSBundle mainBundle] pathForResource:plist ofType:@"plist"];
}

@end
