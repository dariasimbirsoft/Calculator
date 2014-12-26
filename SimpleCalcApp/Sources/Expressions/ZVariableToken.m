//
//  ZVariableToken.m
//  SimpleCalcApp
//
//  Created by Alexey Yukin on 31.10.13.
//  Copyright (c) 2013 Simbirsoft Ltd. All rights reserved.
//

#import "ZVariableToken.h"
#import "DDDecimalFunctions.h"

//----------------------------------------------------------------
@implementation ZVariableToken

#pragma mark - Initialization

//----------------------------------------------------------------
- (id) init
{
    if ((self = [super init]))
    {
        _type         = ttVariable;
        _identifiers  = @"Z";
        _decimalValue = DDDecimalOne();
    }

    return self;
}

#pragma mark - Overrides

//----------------------------------------------------------------
- (NSString*) description
{
    NSDecimal one = DDDecimalOne();

    if (NSDecimalCompare(&_decimalValue, &one) == NSOrderedDescending)
    {
        return [NSString stringWithFormat:@"%@×%@", DDDecimalToString(_decimalValue), _identifiers];
    }
    else
    {
        return _identifiers;
    }
}

@end
