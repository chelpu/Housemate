//
//  Necessity.m
//  Housemate
//
//  Created by Chelsea Pugh on 9/30/14.
//  Copyright (c) 2014 Chelsea Pugh. All rights reserved.
//

#import "Necessity.h"

@implementation Necessity

-(id)initWithDictionary:(NSDictionary *)dictionary {
    if(self = [super init]) {
        self.name = [dictionary objectForKey:@"name"];
        self.dateNeeded = [dictionary objectForKey:@"dateNeeded"];
    }
    return self;
}

@end
