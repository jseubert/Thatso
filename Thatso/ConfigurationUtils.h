//
//  ConfigurationUtils.h
//  Thatso
//
//  Created by John  Seubert on 6/29/15.
//  Copyright (c) 2015 John Seubert. All rights reserved.
//

typedef NS_ENUM(NSInteger, EnvironmentType) {
    EnvironmentTypeInvalid,
    EnvironmentTypeUnknown,
    EnvironmentTypeProduction,
    EnvironmentTypeTesting,
};

@interface ConfigurationUtils : NSObject

+ (EnvironmentType) environmentType;

+ (NSString *) parseClientId;
+ (NSString *) parseApplicationId;

+ (NSString *) sinchApplicationId;
+ (NSString *) sinchApplicationSecret;
+ (NSString *) sinchEnvironmentHost;

@end