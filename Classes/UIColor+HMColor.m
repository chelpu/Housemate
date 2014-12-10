//
//  UIColor+HMColor.m
//  Housemate
//
//  Created by Chelsea Pugh on 11/21/14.
//  Copyright (c) 2014 Chelsea Pugh. All rights reserved.
//

#import "UIColor+HMColor.h"

@implementation UIColor (HMColor)

+ (UIColor *)HMbloodOrangeColor {
    return [UIColor colorWithRed:250.0/255.0 green:54.0/255.0 blue:53.0/255.0 alpha:1.0f];
}

+ (UIColor *)HMbloodOrangeColorTranslucent {
    return [UIColor colorWithRed:250.0/255.0 green:54.0/255.0 blue:53.0/255.0 alpha:0.7f];
}

+ (UIColor *)HMtangerineColor {
    return [UIColor colorWithRed:255.0/255.0 green:169.0/255.0 blue:64.0/255.0 alpha:1.0f];

}
+ (UIColor *)HMpeachColor {
    return [UIColor colorWithRed:235.0/255.0 green:78.0/255.0 blue:57.0/255.0 alpha:0.8f];

}
+ (UIColor *)HMcharcoalColor {
    return [UIColor colorWithRed:51.0 / 255.0 green:51.0 / 255.0 blue:51.0 / 255.0 alpha:1.0];
}

+ (UIColor *)HMlightPeachColor {
    return [UIColor colorWithRed:247.0 / 255.0 green:235.0 / 255.0 blue:219.0 / 242.0 alpha:1.0];
}
@end
