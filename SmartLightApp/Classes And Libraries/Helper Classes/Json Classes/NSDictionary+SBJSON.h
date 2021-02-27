//
//  NSDictionary+SBJSON.h
//  instagram4iPad
//
//  Created by Markus Emrich on 27.10.10.
//  Copyright 2010 Markus Emrich. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NSString+SBJSON.h"

@interface NSDictionary (SBJSON)

+ (NSDictionary*) dictionaryWithJSONString: (NSString*) jsonString;

- (NSString *) jsonStringValue;

@end
