//
//  Equation.m
//  SimpleCalcApp
//
//  Created by Alexey Yukin on 31.10.13.
//  Copyright (c) 2013 Simbirsoft Ltd. All rights reserved.
//

#import "Equation.h"
#import "TokenBase.h"
#import "DDDecimalFunctions.h"

//----------------------------------------------------------------
@implementation Equation
{
    NSMutableArray* _lhsTokens;
    NSMutableArray* _rhsTokens;
    NSArray*        _allowedTokens;

    __weak NSMutableArray* _inputSide;
}

#pragma mark - Initialization

//----------------------------------------------------------------
- (id) init
{
    if ((self = [super init]))
    {
        _lhsTokens = [NSMutableArray new];
        _rhsTokens = [NSMutableArray new];
        _inputSide = _lhsTokens;
    }

    return self;
}

#pragma mark - ExpressionProcessor

//----------------------------------------------------------------
- (NSUInteger) processNewInput:(NSString*)input
{
    TokenBase* token = [[_allowedTokens filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"identifiers CONTAINS %@", input]] lastObject];

    if (!token)
    {
        return errCodeNotAllowed;
    }

    TokenBase* lastToken = [_inputSide lastObject];

    if (token.type == ttConstant)
    {
        if (lastToken.type == ttUnknown || lastToken.type == ttOperator)
        {
            TokenBase* constant = [[token class] new];

            [constant updateWithInput:input];

            _inputSide[_inputSide.count] = constant;
        }
        else if (lastToken.type == ttConstant)
        {
            [lastToken updateWithInput:input];
        }
    }
    else if (token.type == ttOperator)
    {
        if (token.subtype == tstEquationEquality)
        {
            if (_inputSide == _lhsTokens && (lastToken.type == ttConstant || lastToken.type == ttVariable) && _inputSide.count > 1)
            {
                _inputSide = _rhsTokens;
            }
        }
        else
        {
            if (lastToken.type == ttConstant || lastToken.type == ttVariable)
            {
                _inputSide[_inputSide.count] = [[token class] new];
            }
            else if (lastToken.type == ttOperator)
            {
                _inputSide[_inputSide.count - 1] = [[token class] new];
            }
        }
    }
    else if (token.type == ttVariable)
    {
        if (_inputSide == _lhsTokens)
        {
            if (lastToken.type == ttUnknown)
            {
                _inputSide[_inputSide.count] = [[token class] new];
            }
            else if (lastToken.type == ttOperator)
            {
                __block BOOL add = YES;

                if (lastToken.subtype == tstEquationMultiplication)
                {
                    [_inputSide enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(TokenBase* token, NSUInteger index, BOOL* stop)
                    {
                        if (token.type == ttVariable)
                        {
                            add = NO;

                            *stop = YES;
                        }
                        else if (token.type == ttOperator && token.subtype != tstEquationMultiplication)
                        {
                            *stop = YES;
                        }
                    }];
                }

                if (add)
                {
                    _inputSide[_inputSide.count] = [[token class] new];
                }
            }
        }
    }

    return errCodeNoError;
}

//----------------------------------------------------------------
- (NSString*) displayString
{
    NSString* lhsString = [_lhsTokens componentsJoinedByString:@""];

    if (_inputSide == _lhsTokens)
    {
        return lhsString;
    }
    else
    {
        return [NSString stringWithFormat:@"%@=%@", lhsString, ([_rhsTokens componentsJoinedByString:@""] ?: @"")];
    }
}

//----------------------------------------------------------------
- (NSUInteger) evaluate:(NSString**)result
{
    TokenBase* lastToken = [_rhsTokens lastObject];

    if (lastToken.type != ttConstant)
    {
        if (result)
        {
            *result = nil;
        }

        return errCodeIncomplete;
    }

    // calculate right-hand side
    NSMutableArray* objects = [_rhsTokens mutableCopy];

    while (objects.count > 1)
    {
        // search operator with highest priority
        __block NSUInteger tokenIndex = NSUIntegerMax;
        __block NSInteger  priority   = NSIntegerMin;

        [objects enumerateObjectsUsingBlock:^(id object, NSUInteger index, BOOL* stop)
        {
            if ([object isKindOfClass:[TokenBase class]] && ((TokenBase*)object).type == ttOperator && ((TokenBase*)object).priority > priority)
            {
                tokenIndex = index;
                priority   = ((TokenBase*)object).priority;
            }
        }];

        NSDecimal lOperand = [objects[tokenIndex - 1] decimalValue];
        NSDecimal rOperand = [objects[tokenIndex + 1] decimalValue];
        NSDecimal result   = [objects[tokenIndex] performOperationWithLeftOperand:lOperand rightOperand:rOperand];

        [objects replaceObjectsInRange:NSMakeRange(tokenIndex - 1, 3) withObjectsFromArray:@[[NSDecimalNumber decimalNumberWithDecimal:result]]];
    }

    NSDecimal rhsDecimalValue = [objects.lastObject decimalValue];

    // calculate left-hand side
    objects = [_lhsTokens mutableCopy];

    while (objects.count > 1)
    {
        // search operator with highest priority
        __block NSUInteger tokenIndex = NSUIntegerMax;
        __block NSInteger  priority   = NSIntegerMin;

        [objects enumerateObjectsUsingBlock:^(id object, NSUInteger index, BOOL* stop)
        {
            if ([object isKindOfClass:[TokenBase class]] && ((TokenBase*)object).type == ttOperator && ((TokenBase*)object).priority > priority)
            {
                tokenIndex = index;
                priority   = ((TokenBase*)object).priority;
            }
        }];

        TokenBase* operator = objects[tokenIndex];
        id         lOperand = objects[tokenIndex - 1];
        id         rOperand = objects[tokenIndex + 1];
        BOOL       lOpVar   = ([lOperand isKindOfClass:[TokenBase class]] && ((TokenBase*)lOperand).type == ttVariable);
        BOOL       rOpVar   = ([rOperand isKindOfClass:[TokenBase class]] && ((TokenBase*)rOperand).type == ttVariable);

        if (lOpVar && rOpVar)
        {
            NSDecimal result = [operator performOperationWithLeftOperand:[lOperand decimalValue] rightOperand:[rOperand decimalValue]];

            [lOperand setDecimalValue:result];

            [objects removeObjectsInRange:NSMakeRange(tokenIndex, 2)];
        }
        else if (!lOpVar && !rOpVar)
        {
            NSDecimal result = [operator performOperationWithLeftOperand:[lOperand decimalValue] rightOperand:[rOperand decimalValue]];

            [objects replaceObjectsInRange:NSMakeRange(tokenIndex - 1, 3) withObjectsFromArray:@[[NSDecimalNumber decimalNumberWithDecimal:result]]];
        }
        else
        {
            if (operator.subtype == tstEquationMultiplication)
            {
                NSDecimal result = [operator performOperationWithLeftOperand:[lOperand decimalValue] rightOperand:[rOperand decimalValue]];

                if (lOpVar)
                {
                    [lOperand setDecimalValue:result];

                    [objects removeObjectsInRange:NSMakeRange(tokenIndex, 2)];
                }
                else
                {
                    [rOperand setDecimalValue:result];

                    [objects removeObjectsInRange:NSMakeRange(tokenIndex - 1, 2)];
                }
            }
            else
            {
                if (!lOpVar)
                {
                    rhsDecimalValue = DDDecimalSub(rhsDecimalValue, [lOperand decimalValue]);

                    [objects removeObjectsInRange:NSMakeRange(tokenIndex - 1, 2)];
                }
                else
                {
                    rhsDecimalValue = DDDecimalSub(rhsDecimalValue, [rOperand decimalValue]);

                    [objects removeObjectsInRange:NSMakeRange(tokenIndex, 2)];
                }
            }
        }
    }

    if (result)
    {
        TokenBase* variable = objects.lastObject;
        NSDecimal  z        = DDDecimalDiv(rhsDecimalValue, variable.decimalValue);

        variable.decimalValue = DDDecimalOne();

        *result = [NSString stringWithFormat:@"%@=%@", variable, DDDecimalToString(z)];
    }

    return errCodeNoError;
}

//----------------------------------------------------------------
- (void) clear
{
    [_lhsTokens removeAllObjects];
    [_rhsTokens removeAllObjects];

    _inputSide = _lhsTokens;
}

//----------------------------------------------------------------
- (void) setupWithAllowedTokens:(NSArray*)tokens
{
    _allowedTokens = [tokens copy];
}

@end
