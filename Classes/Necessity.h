//
//  Necessity.h
//  Housemate
//
//  Created by Chelsea Pugh on 9/30/14.
//  Copyright (c) 2014 Chelsea Pugh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Necessity : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSDate *dateNeeded;
@property (strong, nonatomic) NSString *necID;

-(id)initWithDictionary:(NSDictionary *)dictionary objId:(NSString *)objId;

@end
