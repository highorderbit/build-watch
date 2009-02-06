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

@interface BuildWatchAppController : NSObject
                                     < ServerGroupNameSelectorDelegate,
                                       ProjectSelectorDelegate,
                                       ProjectReporterDelegate >
{
    // Servers are a list of URL strings.
    //     (NSString *) server url -> (NSArray *) project names (NSString *)
    NSMutableDictionary * servers;

    // Server names are mapped as follows:
    //     (NSString *) server url -> (NSString *) server name
    NSMutableDictionary * serverNames;
    
    NSMutableDictionary * projectDisplayNames;

    NSObject<BuildWatchPersistentStore> * persistentStore;

    NSObject<ServerGroupNameSelector> * serverGroupNameSelector;
    NSObject<ProjectSelector> * projectSelector;
    NSObject<ProjectReporter> * projectReporter;
    
    NSObject<BuildService> * buildService;
    
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

@property (nonatomic, retain) IBOutlet NSObject<BuildService> * buildService;

- (void) start;
 
@end
