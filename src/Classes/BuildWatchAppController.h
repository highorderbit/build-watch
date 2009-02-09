//
//  Copyright 2009 High Order Bit, Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BuildWatchPersistentStore.h"
#import "ServerGroupNameSelector.h"
#import "ServerGroupNameSelectorDelegate.h"
#import "ProjectSelector.h"
#import "ProjectSelectorDelegate.h"
#import "ProjectReporter.h"
#import "ProjectReporterDelegate.h"
#import "BuildService.h"
#import "BuildServiceDelegate.h"
#import "ServerDataRefresher.h"
#import "ServerDataRefresherDelegate.h"
#import "ServerGroupCreator.h"

@interface BuildWatchAppController : NSObject
                                     < ServerGroupNameSelectorDelegate,
                                       ProjectSelectorDelegate,
                                       ProjectReporterDelegate,
                                       BuildServiceDelegate,
                                       ServerDataRefresher >
{
    // Servers are a list of URL strings.
    //     (NSString *) server url -> (NSArray *) project names (NSString *)
    NSMutableDictionary * servers;

    // Server groups are mapped as follows:
    //     (NSString *) groupName -> (NSString *) reg ex of matching servers
    NSMutableDictionary * serverGroupPatterns;
    
    // Server names are mapped as follows:
    //     (NSString *) server url -> (NSString *) server name
    NSMutableDictionary * serverNames;
    
    NSMutableDictionary * projectDisplayNames;
    NSMutableDictionary * projectTrackedStates;
    NSMutableDictionary * projectLinks;

    NSObject<BuildWatchPersistentStore> * persistentStore;

    NSObject<ServerGroupNameSelector> * serverGroupNameSelector;
    NSObject<ProjectSelector> * projectSelector;
    NSObject<ProjectReporter> * projectReporter;

    NSObject<ServerGroupCreator> * serverGroupCreator;

    NSObject<BuildService> * buildService;
    
    NSObject<ServerDataRefresherDelegate> * serverDataRefresherDelegate;
    
    NSString * activeServerGroupName;
}

@property (nonatomic, retain) IBOutlet NSObject<BuildWatchPersistentStore> *
    persistentStore;

@property (nonatomic, retain) IBOutlet NSObject<ServerGroupNameSelector> *
    serverGroupNameSelector;
@property (nonatomic, retain) IBOutlet NSObject<ProjectSelector> *
    projectSelector;
@property (nonatomic, retain) IBOutlet NSObject<ProjectReporter> *
    projectReporter;

@property (nonatomic, retain) IBOutlet NSObject<ServerGroupCreator> *
    serverGroupCreator;

@property (nonatomic, retain) IBOutlet NSObject<BuildService> * buildService;

@property (nonatomic, retain) IBOutlet NSObject<ServerDataRefresherDelegate> *
    serverDataRefresherDelegate;

- (void) start;

- (void) persistState;
 
@end
