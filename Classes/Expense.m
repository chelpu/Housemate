//
//  Expense.m
//  Housemate
//
//  Created by Chelsea Pugh on 9/30/14.
//  Copyright (c) 2014 Chelsea Pugh. All rights reserved.
//

#import "Expense.h"
#import "User.h"

@implementation Expense

-(id)initWithDictionary:(NSDictionary *)dictionary {
    if(self = [super init]) {
        self.amount = [[dictionary objectForKey:@"amount"] doubleValue];
        self.title = [dictionary objectForKey:@"title"];
        self.dueDate = [dictionary objectForKey:@"dueDate"];
    }
    return self;
}

@end
