//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import "ServerReportBuilderFactory.h"
#import "XmlCompositeObjectBuilder.h"
#import "XmlRegexObjectBuilder.h"
#import "XmlBoolObjectBuilder.h"
#import "XmlDateObjectBuilder.h"
#import "XmlSimpleObjectBuilder.h"
#import "XmlConstantValueObjectBuilder.h"
#import "NSString+BuildWatchAdditions.h"
#import "RegexKitLite.h"

static NSMutableDictionary * serverUrlMappings;

@implementation ServerReportBuilderFactory

+ (NSObject<XmlObjectBuilder> *) ccrbBuilder
{
    XmlCompositeObjectBuilder * projectReportBuilder =
        [[[XmlCompositeObjectBuilder alloc] init] autorelease];;

    projectReportBuilder.className = @"ProjectReport";
    projectReportBuilder.objectXpath = @"./item";
    projectReportBuilder.classAttributes =
        [NSDictionary dictionaryWithObjectsAndKeys:
         [XmlRegexObjectBuilder builderWithXpath:@"./title"
                                           regex:@"(^.*)\\s+build\\s+\\d+"],
         @"name",
         [XmlRegexObjectBuilder
             builderWithXpath:@"./link"
                        regex:@"^(.*)/builds/(.*)/\\d+\\.*\\d*$"
            replacementString:@"$1/projects/build/$2"],
         @"forceBuildLink",
         [XmlRegexObjectBuilder
          builderWithXpath:@"./title"
                     regex:@"build\\s+(\\d+\\.*\\d*)\\s|(success|failed)$"],
         @"label",
         [XmlSimpleObjectBuilder builderWithXpath:@"./description"],
         @"description",
         [XmlDateObjectBuilder
          builderWithXpath:@"./pubDate"
                     regex:@"(.*)"
              formatString:@"EEE, dd MMM yyyy HH:mm:ss 'Z'"],
         @"pubDate",
         [XmlSimpleObjectBuilder builderWithXpath:@"./link"],
         @"link",
         [XmlBoolObjectBuilder builderWithXpath:@"./title"
                                          regex:@"^.*(success|failed)$"
                                 equalityString:@"success"],
         @"buildSucceeded",
        nil];

    XmlCompositeObjectBuilder * builder = [XmlCompositeObjectBuilder builder];
    builder.className = @"ServerReport";
    builder.objectXpath = @"//channel";
    builder.classAttributes =
        [NSDictionary dictionaryWithObjectsAndKeys:
         [XmlRegexObjectBuilder builderWithXpath:@"./title"
                                           regex:@"(^.*$)"],
         @"name",

         [XmlRegexObjectBuilder builderWithXpath:@"./link"
                                           regex:@"(^.*$)"],
         @"dashboardLink",

         projectReportBuilder,
         @"projectReports",
         nil];

    return builder;
}

+ (NSObject<XmlObjectBuilder> *) ccjavaDashboardBuilder
{
    XmlCompositeObjectBuilder * projectReportBuilder =
        [[[XmlCompositeObjectBuilder alloc] init] autorelease];;

    projectReportBuilder.className = @"ProjectReport";
    projectReportBuilder.objectXpath = @"./item";
    projectReportBuilder.classAttributes =
        [NSDictionary dictionaryWithObjectsAndKeys:
         [XmlRegexObjectBuilder builderWithXpath:@"./title"
                                           regex:@"(^.*)\\s+passed"],
         @"name",
         // Example URL:
         //  http://192.168.1.110:8000/invoke?operation=build&objectname=CruiseControl+Project%3Aname%3DTest Project
         [XmlRegexObjectBuilder
             builderWithXpath:@"./link"
                        regex:@"^(.*):\\d+/cruisecontrol/buildresults/(.*)$"
            replacementString:@"$1:8000/invoke?operation=build&"
                               "objectname=CruiseControl+Project%3Aname%3D$2"],
         @"forceBuildLink",
         [XmlConstantValueObjectBuilder
          builderWithConstantValue:
              NSLocalizedString(@"ccserver.dashboardlink.notprovided.message",
                  @"")],
         @"label",
         [XmlSimpleObjectBuilder builderWithXpath:@"./description"],
         @"description",
         [XmlDateObjectBuilder
          builderWithXpath:@"./pubDate"
                     regex:@"(.*)"
              formatString:@"EEE, dd MMM yyyy HH:mm:ss ZZZ"],
         @"pubDate",
         [XmlSimpleObjectBuilder builderWithXpath:@"./link"],
         @"link",
         [XmlBoolObjectBuilder builderWithXpath:@"./description"
                                          regex:@"^.*(passed|failed)$"
                                 equalityString:@"passed"],
         @"buildSucceeded",
        nil];

    XmlCompositeObjectBuilder * builder = [XmlCompositeObjectBuilder builder];
    builder.className = @"ServerReport";
    builder.objectXpath = @"//channel";
    builder.classAttributes =
        [NSDictionary dictionaryWithObjectsAndKeys:
         [XmlRegexObjectBuilder builderWithXpath:@"./title"
                                           regex:@"(^.*$)"],
         @"name",

         [XmlRegexObjectBuilder builderWithXpath:@"./link"
                                           regex:@"(^.*$)"],
         @"dashboardLink",

         projectReportBuilder,
         @"projectReports",
         nil];

    return builder;
}

+ (NSObject<XmlObjectBuilder> *) ccjavaBuilder
{
    XmlCompositeObjectBuilder * projectReportBuilder =
        [[[XmlCompositeObjectBuilder alloc] init] autorelease];;

    projectReportBuilder.className = @"ProjectReport";
    projectReportBuilder.objectXpath = @"./Project";
    projectReportBuilder.classAttributes =
        [NSDictionary dictionaryWithObjectsAndKeys:
         [XmlSimpleObjectBuilder builderWithXpath:@"./@name"],
         @"name",
         // Example URL:
         //  http://192.168.1.110:8000/invoke?operation=build&objectname=CruiseControl+Project%3Aname%3DTest Project
         [XmlRegexObjectBuilder
             builderWithXpath:@"./@webUrl"
                        regex:@"^(.*):\\d+/dashboard/tab/build/detail/(.*)$"
            replacementString:@"$1:8000/invoke?operation=build&"
                               "objectname=CruiseControl+Project%3Aname%3D$2"],
         @"forceBuildLink",
         [XmlRegexObjectBuilder builderWithXpath:@"./@lastBuildLabel"
                                           regex:@"^build\\.(\\d+.*)$"],
         @"label",
         [XmlConstantValueObjectBuilder

          builderWithConstantValue:
              NSLocalizedString(@"ccserver.description.notprovided.message",
                  @"")],
         @"description",
         [XmlDateObjectBuilder
          builderWithXpath:@"./@lastBuildTime"
                     regex:@"(.*)"
              formatString:@"yyyy-MM-dd'T'HH:mm:ss"],
         @"pubDate",
         [XmlSimpleObjectBuilder builderWithXpath:@"./@webUrl"],
         @"link",
         [XmlBoolObjectBuilder builderWithXpath:@"./@lastBuildStatus"
                                          regex:@"^(.*)$"
                                 equalityString:@"Success"],
         @"buildSucceeded",
        nil];

    XmlCompositeObjectBuilder * builder = [XmlCompositeObjectBuilder builder];
    builder.className = @"ServerReport";
    builder.objectXpath = @"//Projects";
    builder.classAttributes =
        [NSDictionary dictionaryWithObjectsAndKeys:
         [XmlConstantValueObjectBuilder
          builderWithConstantValue:@"CruiseControl"],
         @"name",

         [XmlConstantValueObjectBuilder
          builderWithConstantValue:
              NSLocalizedString(@"ccserver.dashboardlink.notprovided.message",
                  @"")],
         @"dashboardLink",

         projectReportBuilder,
         @"projectReports",
         nil];

    return builder;
}

+ (NSObject<XmlObjectBuilder> *) ccnetBuilder
{
    XmlCompositeObjectBuilder * projectReportBuilder =
        [[[XmlCompositeObjectBuilder alloc] init] autorelease];;

    projectReportBuilder.className = @"ProjectReport";
    projectReportBuilder.objectXpath = @"./Project";
    projectReportBuilder.classAttributes =
        [NSDictionary dictionaryWithObjectsAndKeys:
         [XmlSimpleObjectBuilder builderWithXpath:@"./@name"],
         @"name",
         // Example URL:
         // http://ccnetlive.thoughtworks.com/ccnet/ViewFarmReport.aspx?projectName=CCNet%20security%20branch&serverName=local&ForceBuild=Force
         [XmlRegexObjectBuilder
             builderWithXpath:@"./@webUrl"
                        regex:@"^(.*)/server/(.*)/project/(.*)/ViewLatestBuildReport.aspx"
            replacementString:@"$1/ViewFarmReport.aspx?serverName=$2&projectName=$3&ForceBuild=Force"],
         @"forceBuildLink",
         [XmlSimpleObjectBuilder builderWithXpath:@"./@lastBuildLabel"],
         @"label",
         [XmlConstantValueObjectBuilder
          builderWithConstantValue:
              NSLocalizedString(@"ccserver.description.notprovided.message",
                  @"")],
         @"description",
         [XmlDateObjectBuilder
          builderWithXpath:@"./@lastBuildTime"
                     regex:@"(.*)"
              formatString:@"yyyy-MM-dd'T'HH:mm:ss"],
         @"pubDate",
         [XmlSimpleObjectBuilder builderWithXpath:@"./@webUrl"],
         @"link",
         [XmlBoolObjectBuilder builderWithXpath:@"./@lastBuildStatus"
                                          regex:@"^(.*)$"
                                 equalityString:@"Success"],
         @"buildSucceeded",
        nil];

    XmlCompositeObjectBuilder * builder = [XmlCompositeObjectBuilder builder];
    builder.className = @"ServerReport";
    builder.objectXpath = @"//Projects";
    builder.classAttributes =
        [NSDictionary dictionaryWithObjectsAndKeys:
         [XmlConstantValueObjectBuilder
          builderWithConstantValue:@"CruiseControl"],
         @"name",

         [XmlConstantValueObjectBuilder
          builderWithConstantValue:
              NSLocalizedString(@"ccserver.dashboardlink.notprovided.message",
                  @"")],
         @"dashboardLink",

         projectReportBuilder,
         @"projectReports",
         nil];

    return builder;
}

+ (void) initialize
{
    if (serverUrlMappings == nil) {
        serverUrlMappings = [[NSMutableDictionary alloc] init];

        [serverUrlMappings setObject:[[self class] ccnetBuilder]
                              forKey:@"^.*/XmlServerReport.aspx$"];
        [serverUrlMappings setObject:[[self class] ccjavaBuilder]
                              forKey:@"^.*/cctray.xml$"];
        [serverUrlMappings setObject:[[self class] ccrbBuilder]
                              forKey:@"^.*/projects.rss$"];
    }
}

+ (NSObject<XmlObjectBuilder> *) builderForServerUrl:(NSString *)serverUrl
{
    NSEnumerator * iter = [serverUrlMappings keyEnumerator];

    for (NSString * mapping = [iter nextObject];
         mapping;
         mapping = [iter nextObject])
    {
        if ([serverUrl isMatchedByRegex:mapping])
            return [serverUrlMappings objectForKey:serverUrl];
    }

    return nil;
}

@end
