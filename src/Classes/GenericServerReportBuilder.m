//
//  Copyright High Order Bit, Inc. 2009. All rights reserved.
//

#import "GenericServerReportBuilder.h"
#import "ServerReport.h"
#import "ProjectReport.h"
#import "TouchXML.h"
#import "ServerReportBuilderFactory.h"
#import "NSString+BuildWatchAdditions.h"
#import "NSError+BuildWatchAdditions.h"

@interface GenericServerReportBuilder (Private)
+ (CXMLDocument *) xmlDocumentWithString:(NSString *)xmlString
                                   error:(NSError **)error;
@end

@implementation GenericServerReportBuilder

#pragma mark ServerReportBuilder protocol implementation

- (ServerReport *) serverReportFromUrl:(NSString *)url
                                  data:(NSData *)data
                                 error:(NSError **)error
{
    NSString * xmlString =
        [NSString stringWithData:data encoding:NSUTF8StringEncoding];

    CXMLDocument * xmlDoc =
        [[self class] xmlDocumentWithString:xmlString error:error];
    if (*error) return nil;

    NSObject<XmlObjectBuilder> * builder =
        [ServerReportBuilderFactory builderForServerUrl:url];
    if (!builder) {
        NSString * errormsg =
            [NSString stringWithFormat:
             NSLocalizedString(@"ccserver.unrecognized.formatstring", @""),
             url];
        *error = [NSError errorWithLocalizedDescription:errormsg];

        return nil;
    }

    ServerReport * report =
        [[builder constructObjectFromXml:[xmlDoc rootElement] error:error]
         lastObject];
    report.key = url;

    NSLog(@"Constructed: '%@'.", report);
    return report;
}

#pragma mark Helper functions

+ (CXMLDocument *) xmlDocumentWithString:(NSString *)xmlString
                                   error:(NSError **)error
{
    CXMLDocument * xmlDoc = [[[CXMLDocument alloc]
         initWithXMLString:xmlString options:0 error:error] autorelease];

    if (*error) {
        *error = [NSError errorWithLocalizedDescription:
            NSLocalizedString(@"xml.parse.failed", @"")
            rootCause:*error];
        NSLog(@"Failed to parse XML: '%@', returning error: '%@'.", xmlString,
            *error);

        return nil;
    }

    return xmlDoc;
}

@end