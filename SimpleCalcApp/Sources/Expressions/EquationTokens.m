//
//  EquationTokens.m
//  SimpleCalcApp
//
//  Created by Alexey Yukin on 31.10.13.
//  Copyright (c) 2013 Simbirsoft Ltd. All rights reserved.
//

#import "EquationTokens.h"

//----------------------------------------------------------------
@implementation EquationEqualityToken

//----------------------------------------------------------------
- (id) init
{
    if ((self = [super init]))
    {
        _type        = ttOperator;
        _subtype     = tstEquationEquality;
        _identifiers = @"=";
    }

    return self;
}

//----------------------------------------------------------------
- (NSString*) description
{
    return _identifiers;
}

@end

//----------------------------------------------------------------
@implementation EquationAdditionToken

//----------------------------------------------------------------
- (id) init
{
    if ((self = [super init]))
    {
        _subtype = tstEquationAddition;
    }

    return self;
}

@end

//----------------------------------------------------------------
@implementation EquationMultiplicationToken

//----------------------------------------------------------------
- (id) init
{
    if ((self = [super init]))
    {
        _subtype = tstEquationMultiplication;
    }

    return self;
}

@end
