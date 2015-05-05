//
//  DatabaseQueryBuilder.m
//  SmartReceipts
//
//  Created by Jaanus Siim on 02/05/15.
//  Copyright (c) 2015 Will Baumann. All rights reserved.
//

#import "DatabaseQueryBuilder.h"
#import "Constants.h"

typedef NS_ENUM(short, StatementType) {
    InsertStatement = 1,
    UpdateStatement = 2,
    DeleteStatement = 3,
};

@interface DatabaseQueryBuilder ()

@property (nonatomic, assign) StatementType statement;
@property (nonatomic, copy) NSString *tableName;
@property (nonatomic, strong) NSMutableArray *params;
@property (nonatomic, strong) NSMutableArray *values;
@property (nonatomic, strong) NSMutableDictionary *where;

@end

@implementation DatabaseQueryBuilder

- (id)initStatementForTable:(NSString *)tableName statementType:(StatementType)statementType {
    self = [super init];
    if (self) {
        _statement = statementType;
        _tableName = tableName;
        _params = [NSMutableArray array];
        _values = [NSMutableArray array];
        _where = [NSMutableDictionary dictionary];
    }
    return self;
}

+ (DatabaseQueryBuilder *)insertStatementForTable:(NSString *)tableName {
    return [[DatabaseQueryBuilder alloc] initStatementForTable:tableName statementType:InsertStatement];
}

+ (DatabaseQueryBuilder *)deleteStatementForTable:(NSString *)tableName {
    return [[DatabaseQueryBuilder alloc] initStatementForTable:tableName statementType:DeleteStatement];
}

+ (DatabaseQueryBuilder *)updateStatementForTable:(NSString *)tableName {
    return [[DatabaseQueryBuilder alloc] initStatementForTable:tableName statementType:UpdateStatement];
}

- (void)addParam:(NSString *)paramName value:(NSObject *)paramValue {
    [self.params addObject:paramName];
    [self.values addObject:paramValue];
}

- (void)where:(NSString *)paramName value:(NSObject *)paramValue {
    SRAssert(self.where.count == 0, @"Only one where clause parameter supported");
    self.where[paramName] = paramValue;
}

- (NSString *)buildStatement {
    NSMutableString *query = [NSMutableString string];
    if (self.statement == InsertStatement) {
        [query appendString:@"INSERT INTO "];
    } else if (self.statement == DeleteStatement) {
        [query appendString:@"DELETE FROM "];        
    } else if (self.statement == UpdateStatement) {
        [query appendString:@"UPDATE "];
    }
    
    [query appendString:self.tableName];
    [query appendString:@" "];
    
    if (self.statement == InsertStatement) {
        [self appendInsertValues:query];
    } else if (self.statement == DeleteStatement) {
        [self appendDeleteValues:query];
    } else if (self.statement == UpdateStatement) {
        [self appendUpdateValues:query];
    }

    return [NSString stringWithString:query];
}

- (void)appendUpdateValues:(NSMutableString *)query {
    [query appendString:@"SET "];
    NSMutableArray *valuesSet = [NSMutableArray array];
    for (NSString *param in self.params) {
        [valuesSet addObject:[NSString stringWithFormat:@"%@ = :%@", param, param]];
    }
    [query appendString:[valuesSet componentsJoinedByString:@", "]];
    NSString *whereKey = [self.where.keyEnumerator.allObjects firstObject];
    [query appendFormat:@" WHERE %@ = :%@", whereKey, whereKey];
}

- (void)appendDeleteValues:(NSMutableString *)query {
    NSString *param = self.params.firstObject;
    [query appendFormat:@"WHERE %@ = :%@", param, param];
}

- (void)appendInsertValues:(NSMutableString *)query {
    [query appendString:@"("];

    NSMutableString *columnsString = [NSMutableString string];
    for (NSString *name in self.params) {
        if ([columnsString length] > 0) {
            [columnsString appendString:@", "];
        }
        [columnsString appendString:name];
    }
    [query appendString:columnsString];

    [query appendString:@") VALUES ("];

    NSMutableString *valuesString = [NSMutableString string];
    for (NSString *name in self.params) {
        if ([valuesString length] > 0) {
            [valuesString appendString:@", "];
        }
        [valuesString appendFormat:@":%@", name];
    }
    [query appendString:valuesString];
    [query appendString:@")"];
}

- (NSDictionary *)parameters {
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    for (NSUInteger index = 0; index < self.params.count; index++) {
        NSString *key = self.params[index];
        id value = self.values[index];
        result[key] = value;
    }
    [result addEntriesFromDictionary:self.where];
    return [NSDictionary dictionaryWithDictionary:result];
}

@end