//
//  NSDictionary+SBJSON.m
//  instagram4iPad
//
//  Created by Markus Emrich on 27.10.10.
//  Copyright 2010 Markus Emrich. All rights reserved.
//

#import "NSDictionary+SBJSON.h"

#import "SBJSON.h"

@implementation NSDictionary (SBJSON)


+ (NSDictionary*) dictionaryWithJSONString: (NSString*) jsonString
{
	id result = [jsonString JSONValue];
	
	if (result == nil) {
		return nil;
	}
	
	return (NSDictionary*)result;
}


- (NSString *) jsonStringValue
{
	SBJSON* JSON = [[SBJSON alloc] init];
	NSString* jsonString = [JSON stringWithObject: self];
	[JSON release];
	
	return jsonString;
}

@end
