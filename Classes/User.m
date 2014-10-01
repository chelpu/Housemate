//
//  User.m
//  Housemate
//
//  Created by Chelsea Pugh on 9/30/14.
//  Copyright (c) 2014 Chelsea Pugh. All rights reserved.
//

#import "User.h"

@implementation User

-(id)initWithDictionary:(NSDictionary *)dictionary {
    if(self = [super init]) {
        self.phoneNumber = [dictionary objectForKey:@"phoneNumber"];
        self.name = [dictionary objectForKey:@"name"];
    }
    return self;
}

@end
