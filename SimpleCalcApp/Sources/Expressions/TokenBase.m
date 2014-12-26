//
//  TokenBase.m
//  SimpleCalcApp
//
//  Created by Alexey Yukin on 31.10.13.
//  Copyright (c) 2013 Simbirsoft Ltd. All rights reserved.
//

#import "TokenBase.h"
#import "DDDecimalFunctions.h"

//----------------------------------------------------------------
@implementation TokenBase

#pragma mark - Initialization

//----------------------------------------------------------------
- (id) init
{
    if ((self = [super init]))
    {
        _type         = ttUnknown;
        _subtype      = tstUnknown;
        _decimalValue = DDDecimalZero();
    }

    return self;
}

#pragma mark - NSObject

//----------------------------------------------------------------
- (NSString*) description
{
    return @"";
}

#pragma mark - Public API

//----------------------------------------------------------------
- (void) updateWithInput:(NSString*)input
{
}

//----------------------------------------------------------------
- (NSDecimal) performOperationWithLeftOperand:(NSDecimal)leftOperand rightOperand:(NSDecimal)rightOperand
{
    return DDDecimalZero();
}

@end
