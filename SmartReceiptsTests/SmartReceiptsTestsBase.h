//
//  SmartReceiptsTestsBase.h
//  SmartReceipts
//
//  Created by Jaanus Siim on 28/04/15.
//  Copyright (c) 2015 Will Baumann. All rights reserved.
//

#import <XCTest/XCTest.h>

@class FMDatabaseQueue;
@class Database;
@class DatabaseTestsHelper;

@interface SmartReceiptsTestsBase : XCTestCase

@property (nonatomic, copy) NSString *testDBPath;
@property (nonatomic, strong) DatabaseTestsHelper *db;

- (void)deleteTestDatabase;
- (DatabaseTestsHelper *)createAndOpenUnmigratedDatabaseWithPath:(NSString *)path;
- (DatabaseTestsHelper *)createAndOpenDatabaseWithPath:(NSString *)path migrated:(BOOL)migrated;
- (DatabaseTestsHelper *)createTestDatabase;
- (void)checkDatabasesSame:(NSString *)pathToReferenceDB checked:(NSString *)pathToCheckedDB;
- (DatabaseTestsHelper *)createMigratedDatabaseFromTemplate:(NSString *)templateName;

@end
