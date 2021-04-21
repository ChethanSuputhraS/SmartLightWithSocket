//
//  DataBaseManager.h
//  Secure Windows App
//
//  Created by i-MaC on 10/15/16.
//  Copyright © 2016 Oneclick. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import <sqlite3.h>
@interface DataBaseManager : NSObject
{
    NSString *path;
	NSString* _dataBasePath;
	sqlite3 *_database;
	BOOL copyDb;
    BOOL ret;
    BOOL status;
    BOOL querystatus;
}
+(DataBaseManager*)dataBaseManager;
-(NSString*) getDBPath;
-(void)openDatabase;
-(BOOL)execute:(NSString*)sqlQuery resultsArray:(NSMutableArray*)dataTable;
-(BOOL)execute:(NSString*)sqlStatement;
-(int)executeSw:(NSString*)sqlStatement;


#pragma mark- ***************
-(NSInteger)getScalar:(NSString*)sqlStatement;
-(NSString*)getValue1:(NSString*)sqlStatement;

-(BOOL)updateMessage:(NSDictionary *)dictInfo with:(NSString *)user_id;
- (NSMutableArray *)getHistoryData;
-(BOOL)executeAddress:(NSString*)sqlQuery resultsArray:(NSMutableArray*)dataTable;
-(BOOL)updateQuery:(NSDictionary *)dictInfo with:(NSString *)user_id;

-(BOOL)getJustValues:(NSString*)sqlQuery resultsArray:(NSMutableArray*)dataTable;

-(BOOL)Create_Device_Table;
-(BOOL)Create_UserAccount_Table;
-(BOOL)Create_History;
-(BOOL)Create_GroupsTable;
-(BOOL)Create_GroupDevices;
-(BOOL)Create_SocketStrip_Table;
-(BOOL)Create_Socket_AlarmDetail_Table;
-(void)addnewBrigthcolumnstoDevice; 
-(BOOL)Create_Socket_NameAndImg_Table;
-(BOOL)Create_YoutubeLink_Table;


#pragma mark - SOCKET METHODS
-(void)AddIdentifierColumntoDeviceTable;
-(void)AddWifi_ConfigureColumntoDeviceTable;
-(void)AddSocketStatusColumntoDeviceTable;


@end







