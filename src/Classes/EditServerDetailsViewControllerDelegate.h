//
//  Copyright 2009 High Order Bit, Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ServerReport;

@protocol EditServerDetailsViewControllerDelegate

- (void) userDidAddServerNamed:(NSString *)serverName
        withInitialBuildReport:(ServerReport *)report;

- (void) userDidCancel;

@end
