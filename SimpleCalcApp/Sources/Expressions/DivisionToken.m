//
//  DivisionToken.m
//  SimpleCalcApp
//
//  Created by Alexey Yukin on 31.10.13.
//  Copyright (c) 2013 Simbirsoft Ltd. All rights reserved.
//

#import "DivisionToken.h"
#import "DDDecimalFunctions.h"

//----------------------------------------------------------------
@implementation DivisionToken

#pragma mark - Initialization

//----------------------------------------------------------------
- (id) init
{
    if ((self = [super init]))
    {
        _type        = ttOperator;
        _identifiers = @"÷";
        _priority    = 1000;
    }

    return self;
}

#pragma mark - Overrides

//----------------------------------------------------------------
- (NSString*) description
{
    return _identifiers;
}

//----------------------------------------------------------------
- (NSDecimal) performOperationWithLeftOperand:(NSDecimal)leftOperand rightOperand:(NSDecimal)rightOperand
{
    return DDDecimalDiv(leftOperand, rightOperand);
}

@end
