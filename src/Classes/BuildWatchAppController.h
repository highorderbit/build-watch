//
//  Copyright 2009 High Order Bit, Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BuildWatchPersistentStore.h"
#import "ServerSelector.h"
#import "ServerSelectorDelegate.h"
#import "ProjectSelector.h"
#import "ProjectSelectorDelegate.h"
#import "BuildService.h"

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
    
    NSDictionary * projectDisplayNames;

    NSObject<BuildWatchPersistentStore> * persistentStore;

    NSObject<ServerSelector> * serverSelector;
    NSObject<ProjectSelector> * projectSelector;
    
    NSObject<BuildService> * buildService;
    
    NSString * activeServer;
}

@property (nonatomic, retain) IBOutlet NSObject<BuildWatchPersistentStore> *
    persistentStore;

@property (nonatomic, retain) IBOutlet NSObject<ServerSelector> *
    serverSelector;
@property (nonatomic, retain) IBOutlet NSObject<ProjectSelector> *
    projectSelector;

@property (nonatomic, retain) IBOutlet NSObject<BuildService> * buildService;

- (void) start;
 
@end
