//
//  NSArray+SBJSON.m
//  instagram4iPad
//
//  Created by Markus Emrich on 08.11.10.
//  Copyright 2010 Markus Emrich. All rights reserved.
//

#import "NSArray+SBJSON.h"

#import "SBJSON.h"


@implementation NSArray (SBJSON)

- (NSString *) jsonStringValue
{
	SBJSON* JSON = [[SBJSON alloc] init];
	NSString* jsonString = [JSON stringWithObject: self];
	[JSON release];
	
	return jsonString;
}

@end
