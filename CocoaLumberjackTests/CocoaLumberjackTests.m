#import "CocoaLumberjackTests.h"

#import <CocoaLumberjack/DDLog.h>

@implementation CocoaLumberjackTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testExample
{
    int ddLogLevel = LOG_LEVEL_OFF;
    DDLogVerbose(@"Logging");
}

@end
