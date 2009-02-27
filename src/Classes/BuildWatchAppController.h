//
//  Copyright 2009 High Order Bit, Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BuildWatchPersistentStore.h"
#import "ServerGroupSelector.h"
#import "ServerGroupSelectorDelegate.h"
#import "ProjectSelector.h"
#import "ProjectSelectorDelegate.h"
#import "ProjectReporter.h"
#import "BuildService.h"
#import "BuildServiceDelegate.h"
#import "ServerDataRefresher.h"
#import "ServerDataRefresherDelegate.h"
#import "ServerGroupCreator.h"
#import "ServerGroupEditor.h"
#import "ServerGroupEditorDelegate.h"
#import "ProjectPropertyProvider.h"
#import "ServerGroupPropertyProvider.h"
#import "ConfigReader.h"

@interface BuildWatchAppController : NSObject
                                     < ServerGroupSelectorDelegate,
                                       ServerGroupPropertyProvider,
                                       ProjectPropertyProvider,
                                       BuildServiceDelegate,
                                       ServerDataRefresher,
                                       ServerGroupEditorDelegate >
{
    NSMutableArray * serverKeys;

    // Mapping of:
    //     server url -> server dashboard link
    NSMutableDictionary * serverDashboardLinks;
    
    // Server names are mapped as follows:
    //     (NSString *) server url -> (NSString *) server name
    NSMutableDictionary * serverGroupNames;
    
    // Server groups are mapped as follows:
    //     (NSString *) groupName -> (NSString *) reg ex of matching servers
    NSMutableDictionary * serverGroupPatterns;
    
    NSMutableDictionary * serverGroupRemovableStates;

    // List of server group names (URLs) in the order configured by the user.
    NSMutableArray * serverGroupSortOrder;
    
    NSMutableDictionary * serverUsernames;
    NSMutableDictionary * serverPasswords;
    
    NSMutableArray * projectKeys;
    NSMutableDictionary * projectNames;
    NSMutableDictionary * projectServerKeys;
    NSMutableDictionary * projectForceBuildLinks;
    
    NSMutableDictionary * buildLabels;
    NSMutableDictionary * buildDescriptions;
    NSMutableDictionary * buildPubDates;
    NSMutableDictionary * buildSucceededStates;
    NSMutableDictionary * buildReportLinks;
    
    // Project tracked states, set by user, mapped as follows:
    //     (NSString *) project id -> (NSNumber *) tracked
    NSMutableDictionary * projectTrackedStates;

    // Objects to parse reports received from various build servers
    NSMutableDictionary * serverReportBuilders;

    NSObject<BuildWatchPersistentStore> * persistentStore;

    NSObject<ServerGroupSelector> * serverGroupNameSelector;
    NSObject<ProjectSelector> * projectSelector;
    NSObject<ProjectReporter> * projectReporter;

    NSObject<ServerGroupCreator> * serverGroupCreator;
    NSObject<ServerGroupEditor> * serverGroupEditor;

    NSObject<BuildService> * buildService;
    
    NSObject<ServerDataRefresherDelegate> * serverDataRefresherDelegate;
    
    NSString * activeServerGroupName;
    NSString * activeProjectId;
}

@property (nonatomic, retain) IBOutlet NSObject<BuildWatchPersistentStore> *
    persistentStore;

@property (nonatomic, retain) IBOutlet NSObject<ServerGroupSelector> *
    serverGroupNameSelector;
@property (nonatomic, retain) IBOutlet NSObject<ProjectSelector> *
    projectSelector;
@property (nonatomic, retain) IBOutlet NSObject<ProjectReporter> *
    projectReporter;

@property (nonatomic, retain) IBOutlet NSObject<ServerGroupCreator> *
    serverGroupCreator;
@property (nonatomic, retain) IBOutlet NSObject<ServerGroupEditor> *
    serverGroupEditor;

@property (nonatomic, retain) IBOutlet NSObject<BuildService> * buildService;

@property (nonatomic, retain) IBOutlet NSObject<ServerDataRefresherDelegate> *
    serverDataRefresherDelegate;

- (void) start;
- (void) refreshDataAndDisplayInitialView;
- (void) persistState;
 
@end
