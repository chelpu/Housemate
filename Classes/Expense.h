//
//  Expense.h
//  Housemate
//
//  Created by Chelsea Pugh on 9/30/14.
//  Copyright (c) 2014 Chelsea Pugh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface Expense : NSObject

@property (assign, nonatomic) double amount;
@property (strong, nonatomic) User *payer;
@property (strong, nonatomic) User *charger;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *expenseID;

-(id)initWithDictionary:(NSDictionary *)dictionary objId:(NSString *)objId;

@end
