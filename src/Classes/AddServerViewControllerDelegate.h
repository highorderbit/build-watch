//
//  Copyright 2009 High Order Bit, Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AddServerViewControllerDelegate

- (void) addServerWithUrl:(NSString *)url;

- (void) userDidCancelAddingServerWithUrl:(NSString *)url;

- (BOOL) isServerGroupUrlValid:(NSString *)serverUrl;

- (void) userDidSelectServerType;

@end
