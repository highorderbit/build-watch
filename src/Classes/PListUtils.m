//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import "PListUtils.h"

@implementation PListUtils

+ (NSDictionary *) readDictionaryFromPList:(NSString *)pList
{
    NSString * errorDesc = nil;
    NSPropertyListFormat format;
    NSString * plistPath =
    [[NSBundle mainBundle] pathForResource:pList ofType:@"plist"];
    NSData * plistXML =
    [[NSFileManager defaultManager] contentsAtPath:plistPath];
    
    NSDictionary * temp = 
    (NSDictionary *)[
                     NSPropertyListSerialization
                     propertyListFromData:plistXML
                     mutabilityOption:NSPropertyListMutableContainersAndLeaves
                     format:&format
                     errorDescription:&errorDesc];
    
    if (!temp) {
        NSLog(errorDesc);
        [errorDesc release];
    }
    
    return temp;
}

+ (void) writeDictionary:(NSDictionary *)dictionary toPList:(NSString *)pList
{
    NSString *errorDesc;
    NSString *bundlePath =
    [[NSBundle mainBundle] pathForResource:pList ofType:@"plist"];
    NSData *plistData =
    [NSPropertyListSerialization
     dataFromPropertyList:dictionary
     format:NSPropertyListXMLFormat_v1_0
     errorDescription:&errorDesc];
    
    if (plistData)
        [plistData writeToFile:bundlePath atomically:YES];
    else {
        NSLog(errorDesc);
        [errorDesc release];
    }
}

@end
