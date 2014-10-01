//
//  Chore.h
//  Housemate
//
//  Created by Chelsea Pugh on 9/30/14.
//  Copyright (c) 2014 Chelsea Pugh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface Chore : NSObject

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) User *assignee;
@property (strong, nonatomic) NSDate *dueDate;

-(id)initWithDictionary:(NSDictionary *)dictionary;

@end
