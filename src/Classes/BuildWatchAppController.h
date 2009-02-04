//
//  Copyright 2009 High Order Bit, Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ServerPersistentStore.h"
#import "ServerSelector.h"
#import "ServerSelectorDelegate.h"
#import "ProjectSelector.h"
#import "ProjectSelectorDelegate.h"

@interface BuildWatchAppController : NSObject
                                     < ServerSelectorDelegate,
                                       ProjectSelectorDelegate >
{
    // Servers are a list of URL strings.
    //     (NSString *) server url -> (NSArray *) project names (NSString *)
    NSDictionary * servers;

    // Server names are mapped as follows:
    //     (NSString *) server url -> (NSString *) server name
    NSDictionary * serverNames;

    NSObject<ServerPersistentStore> * serverPersistentStore;

    NSObject<ServerSelector> * serverSelector;
    NSObject<ProjectSelector> * projectSelector;
}

@property (nonatomic, retain) IBOutlet NSObject<ServerPersistentStore> *
    serverPersistentStore;
@property (nonatomic, retain) IBOutlet NSObject<ServerSelector> *
    serverSelector;
@property (nonatomic, retain) IBOutlet NSObject<ProjectSelector> *
    projectSelector;


- (void) start;
 
@end
