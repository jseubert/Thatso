//
//  ConfigurationUtils.m
//  Thatso
//
//  Created by John  Seubert on 6/29/15.
//  Copyright (c) 2015 John Seubert. All rights reserved.
//

#import "ConfigurationUtils.h"

NSString * const ParseClientIdProduction = @"RRLGVt4cvUEEv1o1pU1a4s78O9FdKS7TQk4A3lfv";
NSString * const ParseClientIdTesting = @"Xceuugh2wcGDs4bQ5mPt87gwJCuNl7tyUulWHWeV";

NSString * const ParseApplicationIdProduction = @"Riu6PqKr6bUkHTPDqZ7l8Z9YKCCgPD9ginQbW5Bh";
NSString * const ParseApplicationIdTesting= @"pSIZJTLx1s9w6TzozqIBMYeZGjQyk9XvbqyzoztM";

NSString * const SinchSecretProduction = @"LOMXots80kuiW5ylT5rkcA==";
NSString * const SinchSecretTesting = @"6mBCmMuQVk+XwssEuElGxQ==";

NSString * const SinchApplicationIdProduction = @"69afe682-76bb-4f1b-8801-e74e65ec2183";
NSString * const SinchApplicationIdTesting= @"dbc9af86-a638-4c44-a244-02f263c3e4a7";

NSString * const SinchEnvironmentHostProduction = @"clientapi.sinch.com";
NSString * const SinchEnvironmentHostTesting = @"sandbox.sinch.com";

@implementation ConfigurationUtils

+ (EnvironmentType) environmentType {
    static EnvironmentType environmentType = EnvironmentTypeUnknown;
    
    if (environmentType == EnvironmentTypeUnknown) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Config" ofType:@"plist"];
        NSDictionary *config = [NSDictionary dictionaryWithContentsOfFile:path];
        NSString * environment = [[config objectForKey:@"EnvironmentType"] lowercaseString];
        
        if([environment isEqualToString:@"production"]) {
            environmentType = EnvironmentTypeProduction;
        } else if([environment isEqualToString:@"testing"]) {
            environmentType = EnvironmentTypeTesting;
        } else {
            environmentType = EnvironmentTypeInvalid;
        }
    }
    return environmentType;
}

#pragma mark Parse variables
+ (NSString *) parseClientId {
    EnvironmentType environmentType = [ConfigurationUtils environmentType];
    NSString *parseClientId = @"";
    
    if(environmentType == EnvironmentTypeProduction) {
        parseClientId = ParseClientIdProduction;
    } else if(environmentType == EnvironmentTypeTesting) {
        parseClientId = ParseClientIdTesting;
    }
    return parseClientId;
}

+ (NSString *) parseApplicationId
{
    EnvironmentType environmentType = [ConfigurationUtils environmentType];
    NSString *parseApplicationId = @"";
    
    if(environmentType == EnvironmentTypeProduction) {
        parseApplicationId = ParseApplicationIdProduction;
    } else if(environmentType == EnvironmentTypeTesting) {
        parseApplicationId = ParseApplicationIdTesting;
    }
    return parseApplicationId;
}

#pragma mark Sinch variables
+ (NSString *) sinchApplicationId
{
    EnvironmentType environmentType = [ConfigurationUtils environmentType];
    NSString *sinchApplicationId = @"";
    
    if(environmentType == EnvironmentTypeProduction) {
        sinchApplicationId = SinchApplicationIdProduction;
    } else if(environmentType == EnvironmentTypeTesting) {
        sinchApplicationId = SinchApplicationIdTesting;
    }
    return sinchApplicationId;
}

+ (NSString *) sinchApplicationSecret
{
    EnvironmentType environmentType = [ConfigurationUtils environmentType];
    NSString *sinchApplicationSecret = @"";
    
    if(environmentType == EnvironmentTypeProduction) {
        sinchApplicationSecret = SinchSecretProduction;
    } else if(environmentType == EnvironmentTypeTesting) {
        sinchApplicationSecret = SinchSecretTesting;
    }
    return sinchApplicationSecret;
}

+ (NSString *) sinchEnvironmentHost
{
    EnvironmentType environmentType = [ConfigurationUtils environmentType];
    NSString *sinchEnvironmentHost = @"";
    
    if(environmentType == EnvironmentTypeProduction) {
        sinchEnvironmentHost = SinchEnvironmentHostProduction;
    } else if(environmentType == EnvironmentTypeTesting) {
        sinchEnvironmentHost = SinchEnvironmentHostTesting;
    }
    return sinchEnvironmentHost;
}


@end