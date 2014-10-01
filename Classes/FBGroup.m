//
//  FBGroup.m
//  Housemate
//
//  Created by Chelsea Pugh on 9/21/14.
//  Copyright (c) 2014 Chelsea Pugh. All rights reserved.
//

#import "FBGroup.h"

@implementation FBGroup

-(id)initWithDict:(NSDictionary *)dict {
    if([super init]) {
        self.name = [dict objectForKey:@"name"];
        self.groupID = [dict objectForKey:@"id"];
    }
    return self;
}

@end
