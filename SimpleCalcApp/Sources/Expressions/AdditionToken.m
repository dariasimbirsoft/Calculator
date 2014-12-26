//
//  AdditionToken.m
//  SimpleCalcApp
//
//  Created by Alexey Yukin on 31.10.13.
//  Copyright (c) 2013 Simbirsoft Ltd. All rights reserved.
//

#import "AdditionToken.h"
#import "DDDecimalFunctions.h"

//----------------------------------------------------------------
@implementation AdditionToken

#pragma mark - Initialization

//----------------------------------------------------------------
- (id) init
{
    if ((self = [super init]))
    {
        _type        = ttOperator;
        _identifiers = @"+";
        _priority    = 100;
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
    return DDDecimalAdd(leftOperand, rightOperand);
}

@end
