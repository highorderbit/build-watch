//
//  Copyright 2009 High Order Bit, Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AddServerViewControllerDelegate

- (void) addServerWithUrl:(NSString *)url;

- (void) userDidCancel;

- (BOOL) isServerGroupNameValid:(NSString *)server;

@end
