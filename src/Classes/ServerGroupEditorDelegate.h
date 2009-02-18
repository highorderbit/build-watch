//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol ServerGroupEditorDelegate

- (void) changeDisplayName:(NSString *)serverGroupDisplayName
        forServerGroupName:(NSString *)serverGroupName;

@end
