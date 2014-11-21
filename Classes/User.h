//
//  User.h
//  Housemate
//
//  Created by Chelsea Pugh on 9/30/14.
//  Copyright (c) 2014 Chelsea Pugh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

@property (strong, nonatomic) NSString *phoneNumber;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *userID;
-(id)initWithDictionary:(NSDictionary *)dictionary;

@end
