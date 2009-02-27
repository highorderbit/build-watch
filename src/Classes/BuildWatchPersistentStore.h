//
//  Copyright 2009 High Order Bit, Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BuildWatchPersistentStore

- (void) saveServerKeys:(NSArray *)serverKeys;

- (NSArray *) getServerKeys;

- (void) saveServerGroupPatterns:(NSDictionary *)serverGroupPatterns;

- (NSDictionary *) getServerGroupPatterns;

- (void) saveServerGroupNames:(NSDictionary *)serverGroupNames;

- (NSDictionary *) getServerGroupNames;

- (void) saveServerGroupRemovableStates:
    (NSDictionary *)serverGroupRemovableStates;

- (NSDictionary *) getServerGroupRemovableStates;

- (void) saveServerDashboardLinks:(NSDictionary *)dashboardLinks;

- (NSDictionary *) getServerDashboardLinks;

- (void) saveServerGroupSortOrder:(NSArray *)serverGroupNames;

- (NSArray *) getServerGroupSortOrder;

- (void) saveServerUsernames:(NSDictionary *)serverUsernames;

- (NSDictionary *) getServerUsernames;

- (void) saveProjectKeys:(NSArray *)projectKeys;

- (NSArray *) getProjectKeys;

- (void) saveProjectNames:(NSDictionary *)projectNames;

- (NSDictionary *) getProjectNames;

- (void) saveProjectServerKeys:(NSDictionary *)projectServerKeys;

- (NSDictionary *) getProjectServerKeys;

- (void) saveBuildLabels:(NSDictionary *)buildLabels;

- (NSDictionary *) getBuildLabels;

- (void) saveBuildDescriptions:(NSDictionary *)buildDescriptions;

- (NSDictionary *) getBuildDescriptions;

- (void) saveBuildPubDates:(NSDictionary *)buildPubDates;

- (NSDictionary *) getBuildPubDates;

- (void) saveBuildReportLinks:(NSDictionary *)buildReportLinks;

- (NSDictionary *) getBuildReportLinks;

- (void) saveProjectForceBuildLinks:(NSDictionary *)projectForceBuildLinks;

- (NSDictionary *) getProjectForceBuildLinks;

- (void) saveBuildSucceededStates:(NSDictionary *)buildSucceededStates;

- (NSDictionary *) getBuildSucceededStates;

- (void) saveProjectTrackedStates:(NSDictionary *)projectTrackedStates;

- (NSDictionary *) getProjectTrackedStates;

- (void) saveActiveServerGroupName:(NSString *)activeServerGroupName;

- (NSString *) getActiveServerGroupName;

- (void) saveActiveProjectId:(NSString *)activeProjectId;

- (NSString *) getActiveProjectId;

- (void) restoreToDefaultState;

@end
