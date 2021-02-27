//
//  DataBaseManager.m
//  Secure Windows App
//
//  Created by i-MaC on 10/15/16.
//  Copyright © 2016 Oneclick. All rights reserved.
//

#import "DataBaseManager.h"
static DataBaseManager * dataBaseManager = nil;

@implementation DataBaseManager
#pragma mark - DataBaseManager initialization
-(id) init
{
    self = [super init];
    if (self)
    {
        // get full path of database in documents directory
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        path = [paths objectAtIndex:0];
        _dataBasePath = [path stringByAppendingPathComponent:@"smartLight.sqlite"];
        
//        NSLog(@"data base path:%@",path);
        [self openDatabase];
    }
    return self;
    
}
+(DataBaseManager*)dataBaseManager
{
    static dispatch_once_t _singletonPredicate;
    dispatch_once(&_singletonPredicate, ^{
        if (!dataBaseManager)
        {
            dataBaseManager = [[super alloc]init];
        }
    });
    
    return dataBaseManager;
}

- (NSString *) getDBPath
{
    
    //Search for standard documents using NSSearchPathForDirectoriesInDomains
    //First Param = Searching the documents directory
    //Second Param = Searching the Users directory and not the System
    //Expand any tildes and identify home directories.
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    return [documentsDir stringByAppendingPathComponent:@"smartLight.sqlite"];
    
}
-(void)openDatabase
{
    BOOL ok;
    NSError *error;
    
    /*
     * determine if database exists.
     * create a file manager object to test existence
     *
     */
    NSFileManager *fm = [NSFileManager defaultManager]; // file manager
    ok = [fm fileExistsAtPath:_dataBasePath];
    
    // if database not there, copy from resource to path
    if (!ok)
    {
        // location in resource bundle
        NSString *appPath = [[[NSBundle mainBundle] resourcePath]
                             stringByAppendingPathComponent:@"smartLight.sqlite"];
        if ([fm fileExistsAtPath:appPath])
        {
            // copy from resource to where it should be
            copyDb = [fm copyItemAtPath:appPath toPath:_dataBasePath error:&error];
            
            if (error!=nil)
            {
                copyDb = FALSE;
            }
            ok = copyDb;
        }
    }
    
    
    // open database
    if (sqlite3_open([_dataBasePath UTF8String], &_database) != SQLITE_OK)
    {
        sqlite3_close(_database); // in case partially opened
        _database = nil; // signal open error
    }
    
    if (!copyDb && !ok)
    { // first time and database not copied
        ok = [self Create_Device_Table]; // create empty database
        if (ok)
        {
            // Populating Table first time from the keys.plist
            /*	NSString *pListPath = [[NSBundle mainBundle] pathForResource:@"ads" ofType:@"plist"];
             NSArray *contents = [NSArray arrayWithContentsOfFile:pListPath];
             for (NSDictionary* dictionary in contents) {
             
             NSArray* keys = [dictionary allKeys];
             [self execute:[NSString stringWithFormat:@"insert into ads values('%@','%@','%@')",[dictionary objectForKey:[keys objectAtIndex:0]], [dictionary objectForKey:[keys objectAtIndex:1]],[dictionary objectForKey:[keys objectAtIndex:2]]]];
             }*/
        }
    }
    
    if (!ok)
    {
        // problems creating database
        NSAssert1(0, @"Problem creating database [%@]",
                  [error localizedDescription]);
    }
    
}
/*
 alter table yourTableName
 change yourOldColumnName1 yourNewColumnName1 dataType,
 yourOldColumnName2 yourNewColumnName2 dataType,
 .
 identifier, mac_address, socket_status, wifi_configured

 */
#pragma mark - Change Device_Table Table
-(void)addnewBrigthcolumnstoDevice
{
    sqlite3_stmt *createStmt = nil;
    
    NSString *query = [NSString stringWithFormat:@"ALTER TABLE Device_Table ADD COLUMN manualBrightness TEXT"];
    
    if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &createStmt, NULL) == SQLITE_OK)
    {
        sqlite3_exec(_database, [query UTF8String], NULL, NULL, NULL);
    }
    else
    {
//        NSLog(@"The succor_device_id table already exist in tbl_uninstall");
    }
    
    sqlite3_finalize(createStmt);
}
-(void)AddIdentifierColumntoDeviceTable
{
    sqlite3_stmt *createStmt = nil;
    
    NSString *query = [NSString stringWithFormat:@"ALTER TABLE Device_Table ADD COLUMN identifier TEXT "];
    
    if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &createStmt, NULL) == SQLITE_OK)
    {
        sqlite3_exec(_database, [query UTF8String], NULL, NULL, NULL);
    }
    else
    {
//        NSLog(@"The succor_device_id table already exist in tbl_uninstall");
    }
    
    sqlite3_finalize(createStmt);
}
-(void)AddSocketStatusColumntoDeviceTable
{
    sqlite3_stmt *createStmt = nil;
    
    NSString *query = [NSString stringWithFormat:@"ALTER TABLE Device_Table ADD COLUMN socket_status TEXT "];
    
    if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &createStmt, NULL) == SQLITE_OK)
    {
        sqlite3_exec(_database, [query UTF8String], NULL, NULL, NULL);
    }
    else
    {
//        NSLog(@"The succor_device_id table already exist in tbl_uninstall");
    }
    
    sqlite3_finalize(createStmt);
}
-(void)AddWifi_ConfigureColumntoDeviceTable
{
    sqlite3_stmt *createStmt = nil;
    
    NSString *query = [NSString stringWithFormat:@"ALTER TABLE Device_Table ADD COLUMN wifi_configured TEXT "];
    
    if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &createStmt, NULL) == SQLITE_OK)
    {
        sqlite3_exec(_database, [query UTF8String], NULL, NULL, NULL);
    }
    else
    {
//        NSLog(@"The succor_device_id table already exist in tbl_uninstall");
    }
    
    sqlite3_finalize(createStmt);
}


-(BOOL)Create_Device_Table
{
    int rc;
    
    // SQL to create new database
    NSArray* queries = [NSArray arrayWithObjects:@"CREATE TABLE 'Device_Table' ('id' INTEGER PRIMARY KEY  NOT NULL, 'device_id' VARCHAR,'hex_device_id' VARCHAR, 'device_name' VARCHAR, 'real_name' VARCHAR, 'BLE_Add' VARCHAR, 'device_type' VARCHAR,'connect_status' VARCHAR,'switch_status' VARCHAR)",nil];
    
    if(queries != nil)
    {
        for (NSString* sql in queries)
        {
            
            sqlite3_stmt *stmt;
            rc = sqlite3_prepare_v2(_database, [sql UTF8String], -1, &stmt, NULL);
            ret = (rc == SQLITE_OK);
            if (ret)
            {
                // statement built, execute
                rc = sqlite3_step(stmt);
                ret = (rc == SQLITE_DONE);
                sqlite3_finalize(stmt); // free statement
                //sqlite3_reset(stmt);
            }
        }
    }
    return ret;
}
-(BOOL)Create_UserAccount_Table
{
    int rc;
    
    // SQL to create new database
    NSArray* queries = [NSArray arrayWithObjects:@"CREATE TABLE 'UserAccount_Table' ('local_user_id' INTEGER PRIMARY KEY  NOT NULL, 'server_user_id' VARCHAR,'user_name' VARCHAR, 'account_name' VARCHAR, 'user_email' VARCHAR, 'user_mobile_no' VARCHAR, 'user_pw' VARCHAR,'user_token' VARCHAR,'is_active' VARCHAR)",nil];
    
    if(queries != nil)
    {
        for (NSString* sql in queries)
        {
            
            sqlite3_stmt *stmt;
            rc = sqlite3_prepare_v2(_database, [sql UTF8String], -1, &stmt, NULL);
            ret = (rc == SQLITE_OK);
            if (ret)
            {
                // statement built, execute
                rc = sqlite3_step(stmt);
                ret = (rc == SQLITE_DONE);
                sqlite3_finalize(stmt); // free statement
                //sqlite3_reset(stmt);
            }
        }
    }
    return ret;
}

-(BOOL)Create_GroupsTable
{
    int rc;
    
    // SQL to create new database
    NSArray* queries = [NSArray arrayWithObjects:@"CREATE TABLE 'GroupsTable' ('id' INTEGER PRIMARY KEY  NOT NULL, 'groupID' VARCHAR,'Hex_groupID' VARCHAR, 'group_name' VARCHAR, 'hexDeviceID' VARCHAR,'DeviceID' VARCHAR,'device_name' VARCHAR, 'BLE_Add' VARCHAR,'device_type' VARCHAR,'switch_status' VARCHAR)",nil];
    
    if(queries != nil)
    {
        for (NSString* sql in queries)
        {
            
            sqlite3_stmt *stmt;
            rc = sqlite3_prepare_v2(_database, [sql UTF8String], -1, &stmt, NULL);
            ret = (rc == SQLITE_OK);
            if (ret)
            {
                // statement built, execute
                rc = sqlite3_step(stmt);
                ret = (rc == SQLITE_DONE);
                sqlite3_finalize(stmt); // free statement
                //sqlite3_reset(stmt);
            }
        }
    }
    return ret;
}
-(BOOL)Create_History
{
    int rc;
    
    // SQL to create new database
    NSArray* queries = [NSArray arrayWithObjects:@"CREATE TABLE 'History' ('id' INTEGER PRIMARY KEY  NOT NULL, 'lastColor' VARCHAR, 'lastDeviceName' VARCHAR, 'lastDeviceId' VARCHAR, 'time' VARCHAR)",nil];
    
    if(queries != nil)
    {
        for (NSString* sql in queries)
        {
            
            sqlite3_stmt *stmt;
            rc = sqlite3_prepare_v2(_database, [sql UTF8String], -1, &stmt, NULL);
            ret = (rc == SQLITE_OK);
            if (ret)
            {
                // statement built, execute
                rc = sqlite3_step(stmt);
                ret = (rc == SQLITE_DONE);
                sqlite3_finalize(stmt); // free statement
                //sqlite3_reset(stmt);
            }
        }
    }
    return ret;
}

-(BOOL)Create_GroupDevices
{
    int rc;
    
    // SQL to create new database
    NSArray* queries = [NSArray arrayWithObjects:@"CREATE TAB LE 'GroupDevices' ('id' INTEGER PRIMARY KEY  NOT NULL, 'groupID' VARCHAR, 'device_id' VARCHAR, 'device_name' VARCHAR, 'real_name' VARCHAR,'BLE_Add' VARCHAR)",nil];
    
    if(queries != nil)
    {
        for (NSString* sql in queries)
        {
            
            sqlite3_stmt *stmt;
            rc = sqlite3_prepare_v2(_database, [sql UTF8String], -1, &stmt, NULL);
            ret = (rc == SQLITE_OK);
            if (ret)
            {
                // statement built, execute
                rc = sqlite3_step(stmt);
                ret = (rc == SQLITE_DONE);
                sqlite3_finalize(stmt); // free statement
                //sqlite3_reset(stmt);
            }
        }
    }
    return ret;
}

-(BOOL)Create_SocketStrip_Table
{
    int rc;
    
    // SQL to create new database
    NSArray* queries = [NSArray arrayWithObjects:@"CREATE TABLE 'SocketStrip' ('id' INTEGER PRIMARY KEY  NOT NULL,'table_id' VARCHAR ,'device_id' VARCHAR,'hex_device_id' VARCHAR,'socket_name' VARCHAR,'switch_status' VARCHAR)",nil];
    
    if(queries != nil)
    {
        for (NSString* sql in queries)
        {
            
            sqlite3_stmt *stmt;
            rc = sqlite3_prepare_v2(_database, [sql UTF8String], -1, &stmt, NULL);
            ret = (rc == SQLITE_OK);
            if (ret)
            {
                // statement built, execute
                rc = sqlite3_step(stmt);
                ret = (rc == SQLITE_DONE);
                sqlite3_finalize(stmt); // free statement
                //sqlite3_reset(stmt);
            }
        }
    }
    return ret;
}
-(BOOL)Create_Socket_AlarmDetail_Table
{
    int rc;
    
    // SQL to create new database
    NSArray* queries = [NSArray arrayWithObjects:@"CREATE TABLE 'Socket_Alarm_Table' ('id' INTEGER PRIMARY KEY  NOT NULL, 'alarm_id' VARCHAR,'socket_id' VARCHAR, 'day_value' VARCHAR, 'OnTimestamp' VARCHAR, 'OffTimestamp' VARCHAR, 'On_original' VARCHAR, 'Off_original' VARCHAR, 'alarm_state' VARCHAR, 'ble_address' VARCHAR, 'day_selected' VARCHAR)",nil];
    
    if(queries != nil)
    {
        for (NSString* sql in queries)
        {
            
            sqlite3_stmt *stmt;
            rc = sqlite3_prepare_v2(_database, [sql UTF8String], -1, &stmt, NULL);
            ret = (rc == SQLITE_OK);
            if (ret)
            {
                // statement built, execute
                rc = sqlite3_step(stmt);
                ret = (rc == SQLITE_DONE);
                sqlite3_finalize(stmt); // free statement
                //sqlite3_reset(stmt);
            }
        }
    }
    return ret;
}

#pragma mark - Insert Query
/*
 * Method to execute the simple queries
 */
-(BOOL)execute:(NSString*)sqlStatement
{
    sqlite3_stmt *statement = nil;
    status = FALSE;
    //NSLog(@"%@",sqlStatement);
    const char *sql = (const char*)[sqlStatement UTF8String];
    
    
    if(sqlite3_prepare_v2(_database, sql, -1, &statement, NULL) != SQLITE_OK) {
        NSAssert1(0, @"Error while preparing  statement. '%s'", sqlite3_errmsg(_database));
        status = FALSE;
    } else {
        status = TRUE;
    }
    if (sqlite3_step(statement)!=SQLITE_DONE) {
        NSAssert1(0, @"Error while deleting. '%s'", sqlite3_errmsg(_database));
        status = FALSE;
    } else {
        status = TRUE;
    }
    
    sqlite3_finalize(statement);
    return status;
}
-(int)executeSw:(NSString*)sqlStatement
{
    sqlite3_stmt *statement = nil;
    status = FALSE;
    //NSLog(@"%@",sqlStatement);
    const char *sql = (const char*)[sqlStatement UTF8String];
    
    
    if(sqlite3_prepare_v2(_database, sql, -1, &statement, NULL) != SQLITE_OK) {
        NSAssert1(0, @"Error while preparing  statement. '%s'", sqlite3_errmsg(_database));
        status = FALSE;
    } else {
        status = TRUE;
    }
    if (sqlite3_step(statement)!=SQLITE_DONE) {
        NSAssert1(0, @"Error while deleting. '%s'", sqlite3_errmsg(_database));
        status = FALSE;
    } else {
        status = TRUE;
    }
    
    sqlite3_finalize(statement);
    int  returnValue = sqlite3_last_insert_rowid(_database);
    
    return returnValue;
}

#pragma mark - SQL query methods
/*
 * Method to get the data table from the database
 */
-(BOOL) execute:(NSString*)sqlQuery resultsArray:(NSMutableArray*)dataTable
{
    
    char** azResult = NULL;
    int nRows = 0;
    int nColumns = 0;
    querystatus = FALSE;
    char* errorMsg; //= malloc(255); // this is not required as sqlite do it itself
    const char* sql = [sqlQuery UTF8String];
    sqlite3_get_table(
                      _database,  /* An open database */
                      sql,     /* SQL to be evaluated */
                      &azResult,          /* Results of the query */
                      &nRows,                 /* Number of result rows written here */
                      &nColumns,              /* Number of result columns written here */
                      &errorMsg      /* Error msg written here */
                      );
    
    if(azResult != NULL)
    {
        nRows++; //because the header row is not account for in nRows
        
        for (int i = 1; i < nRows; i++)
        {
            NSMutableDictionary* row = [[NSMutableDictionary alloc]initWithCapacity:nColumns];
            for(int j = 0; j < nColumns; j++)
            {
                NSString*  value = nil;
                NSString* key = [NSString stringWithUTF8String:azResult[j]];
                if (azResult[(i*nColumns)+j]==NULL)
                {
                    value = [NSString stringWithUTF8String:[[NSString string] UTF8String]];
                }
                else
                {
                    value = [NSString stringWithUTF8String:azResult[(i*nColumns)+j]];
                }
                
                [row setValue:value forKey:key];
            }
            [dataTable addObject:row];
        }
        querystatus = TRUE;
        sqlite3_free_table(azResult);
    }
    else
    {
        NSAssert1(0,@"Failed to execute query with message '%s'.",errorMsg);
        querystatus = FALSE;
    }
    
    return 0;
}

-(BOOL) getJustValues:(NSString*)sqlQuery resultsArray:(NSMutableArray*)dataTable
{
    
    char** azResult = NULL;
    int nRows = 0;
    int nColumns = 0;
    querystatus = FALSE;
    char* errorMsg; //= malloc(255); // this is not required as sqlite do it itself
    const char* sql = [sqlQuery UTF8String];
    sqlite3_get_table(
                      _database,  /* An open database */
                      sql,     /* SQL to be evaluated */
                      &azResult,          /* Results of the query */
                      &nRows,                 /* Number of result rows written here */
                      &nColumns,              /* Number of result columns written here */
                      &errorMsg      /* Error msg written here */
                      );
    
    if(azResult != NULL)
    {
        nRows++; //because the header row is not account for in nRows
        
        for (int i = 1; i < nRows; i++)
        {
            NSMutableDictionary* row = [[NSMutableDictionary alloc]initWithCapacity:nColumns];
            for(int j = 0; j < nColumns; j++)
            {
                NSString*  value = nil;
                NSString* key = [NSString stringWithUTF8String:azResult[j]];
                if (azResult[(i*nColumns)+j]==NULL)
                {
                    value = [NSString stringWithUTF8String:[[NSString string] UTF8String]];
                }
                else
                {
                    value = [NSString stringWithUTF8String:azResult[(i*nColumns)+j]];
                }
                [dataTable addObject:value];

//                [row setValue:value forKey:key];
            }
        }
        querystatus = TRUE;
        sqlite3_free_table(azResult);
    }
    else
    {
        NSAssert1(0,@"Failed to execute query with message '%s'.",errorMsg);
        querystatus = FALSE;
    }
    
    return 0;
}
-(NSInteger)getScalar:(NSString*)sqlStatement
{
    NSInteger count = -1;
    
    const char* sql= (const char *)[sqlStatement UTF8String];
    sqlite3_stmt *selectstmt;
    if(sqlite3_prepare_v2(_database, sql, -1, &selectstmt, NULL) == SQLITE_OK)
    {
        while(sqlite3_step(selectstmt) == SQLITE_ROW)
        {
            count = sqlite3_column_int(selectstmt, 0);
        }
    }
    sqlite3_finalize(selectstmt);
    
    return count;
}

-(NSString*)getValue1:(NSString*)sqlStatement
{
    
    NSString* value = nil;
    const char* sql= (const char *)[sqlStatement UTF8String];
    sqlite3_stmt *selectstmt;
    if(sqlite3_prepare_v2(_database, sql, -1, &selectstmt, NULL) == SQLITE_OK)
    {
        while(sqlite3_step(selectstmt) == SQLITE_ROW)
        {
            if ((char *)sqlite3_column_text(selectstmt, 0)!=nil)
            {
                value = [NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 0)];
            }
        }
    }
    return value;
}



#pragma mark - Insert Query
/*
 * Method to execute the simple queries
 */
-(int)executeCatch:(NSString*)sqlStatement
{
    sqlite3_stmt *statement = nil;
    status = FALSE;
    //NSLog(@"%@",sqlStatement);
    const char *sql = (const char*)[sqlStatement UTF8String];
    
    
    if(sqlite3_prepare_v2(_database, sql, -1, &statement, NULL) != SQLITE_OK) {
        NSAssert1(0, @"Error while preparing  statement. '%s'", sqlite3_errmsg(_database));
        status = FALSE;
    } else {
        status = TRUE;
    }
    if (sqlite3_step(statement)!=SQLITE_DONE) {
        NSAssert1(0, @"Error while deleting. '%s'", sqlite3_errmsg(_database));
        status = FALSE;
    } else {
        status = TRUE;
    }
    
    sqlite3_finalize(statement);
    int  returnValue = sqlite3_last_insert_rowid(_database);
    
    return returnValue;
}

/*
 Create table statement :
 
 CREATE TABLE "Device_Table" ( `id` INTEGER NOT NULL, `user_id` TEXT, `device_id` VARCHAR, `hex_device_id` VARCHAR, `server_device_id` TEXT, `device_name` VARCHAR, `real_name` VARCHAR, `ble_address` VARCHAR, `device_type` VARCHAR, `device_type_name` TEXT, `connect_status` VARCHAR, `switch_status` VARCHAR, `is_favourite` TEXT, `created_at` TEXT, `updated_at` TEXT, `timestamp` TEXT, PRIMARY KEY(`id`) )
 
 
 CREATE TABLE `Device_types` ( `id` INTEGER NOT NULL, `device_type_name` TEXT, `status` TEXT, `created_date` TEXT, PRIMARY KEY(`id`) )
 
 CREATE TABLE "GroupsTable" ( `id` INTEGER NOT NULL, `user_id` TEXT, `group_name` VARCHAR, `local_group_id` VARCHAR, `local_group_hex_id` VARCHAR, `server_group_id` TEXT, `device_name` VARCHAR, `device_id` VARCHAR, `hex_device_id` VARCHAR, `server_device_id` TEXT, `ble_address` VARCHAR, `device_type` VARCHAR, `device_type_name` TEXT, `switch_status` VARCHAR, `status` TEXT, `created_date` TEXT, `updated_date` TEXT, `timestamp` TEXT, PRIMARY KEY(`id`) )
 
 CREATE TABLE 'History' ('id' INTEGER PRIMARY KEY NOT NULL, 'lastColor' VARCHAR, 'lastDeviceName' VARCHAR, 'lastDeviceId' VARCHAR, 'time' VARCHAR)
 
 CREATE TABLE 'SocketStrip' ('id' INTEGER PRIMARY KEY NOT NULL,'table_id' VARCHAR ,'device_id' VARCHAR,'hex_device_id' VARCHAR,'socket_name' VARCHAR,'switch_status' VARCHAR)
 
 CREATE TABLE `VoiceColors` ( `id` INTEGER NOT NULL, `name` TEXT, `value` TEXT, PRIMARY KEY(`id`) )
 
 */
@end
