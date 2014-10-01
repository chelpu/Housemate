//
//  FBGroup.h
//  Housemate
//
//  Created by Chelsea Pugh on 9/21/14.
//  Copyright (c) 2014 Chelsea Pugh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FBGroup : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *groupID;
-(id)initWithDict:(NSDictionary *)dict;

@end
