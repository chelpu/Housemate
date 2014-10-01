//
//  Chore.m
//  Housemate
//
//  Created by Chelsea Pugh on 9/30/14.
//  Copyright (c) 2014 Chelsea Pugh. All rights reserved.
//

#import "Chore.h"

@implementation Chore

-(id)initWithDictionary:(NSDictionary *)dictionary {
    if(self = [super init]) {
        self.title = [dictionary objectForKey:@"title"];
        self.assignee = [dictionary objectForKey:@"assignee"];
        self.dueDate = [dictionary objectForKey:@"dueDate"];
    }
    return self;
}

@end
