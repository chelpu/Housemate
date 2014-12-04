//
//  Necessity.m
//  Housemate
//
//  Created by Chelsea Pugh on 9/30/14.
//  Copyright (c) 2014 Chelsea Pugh. All rights reserved.
//

#import "Necessity.h"

@implementation Necessity

-(id)initWithDictionary:(NSDictionary *)dictionary objId:(NSString *)objId {
    if(self = [super init]) {
        self.name = [dictionary objectForKey:@"name"];
        self.dateNeeded = [dictionary objectForKey:@"dateNeeded"];
        self.necID = objId;
    }
    return self;
}

@end
