//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServerReportBuilder.h"

@class ProjectReport;
@class CXMLNode;

@interface AbstractServerReportBuilder : NSObject
                                         < ServerReportBuilder >
{
}

+ (NSString *) serverNameFromNode:(CXMLNode *)serverNode
                        sourceUrl:(NSString *)sourceUrl
                            error:(NSError **)error;
+ (NSString *) serverDashboardLinkFromNode:(CXMLNode *)serverNode
                                 sourceUrl:(NSString *)sourceUrl
                                     error:(NSError **)error;

+ (ProjectReport *) projectReportFromNode:(CXMLNode *)projectNode
                                    error:(NSError **)error;
+ (NSString *) projectNameFromNode:(CXMLNode *)node
                             error:(NSError **)error;
+ (NSString *) projectDescriptionFromNode:(CXMLNode *)node
                                    error:(NSError **)error;
+ (NSString *) projectBuildLabelFromNode:(CXMLNode *)node
                                   error:(NSError **)error;
+ (NSDate *) projectPubDateFromNode:(CXMLNode *)node
                              error:(NSError **)error;
+ (NSString *) projectLinkFromNode:(CXMLNode *)node
                             error:(NSError **)error;
+ (BOOL) projectBuildSucceededFromNode:(CXMLNode *)node
                                 error:(NSError **)error;
+ (NSString *) projectForceBuildLinkFromNode:(CXMLNode *)node
                                       error:(NSError **)error;

+ (NSString *) stringValueAtXpath:(NSString *)xpath
                         fromNode:(CXMLNode *)node
                            error:(NSError **)error;
+ (id) xmlParsingFailed:(NSError **)error;
+ (id) xmlParsingFailedWithRootCause:(NSError **)error;

@end
