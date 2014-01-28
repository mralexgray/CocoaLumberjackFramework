
#import <SenTestingKit/SenTestingKit.h>
#import <CocoaLumberjack/DDAbstractDatabaseLogger.h>
#import <CocoaLumberjack/DDASLLogger.h>
#import <CocoaLumberjack/DDFileLogger.h>
#import <CocoaLumberjack/DDLog.h>
#import <CocoaLumberjack/DDTTYLogger.h>


@interface CocoaLumberjackTests : SenTestCase @end

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
