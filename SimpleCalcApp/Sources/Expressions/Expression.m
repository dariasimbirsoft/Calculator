//
//  Expression.m
//  SimpleCalcApp
//
//  Created by Alexey Yukin on 31.10.13.
//  Copyright (c) 2013 Simbirsoft Ltd. All rights reserved.
//

#import "Expression.h"
#import "TokenBase.h"
#import "DDDecimalFunctions.h"

//----------------------------------------------------------------
@implementation Expression
{
    NSMutableArray* _tokens;
    NSArray*        _allowedTokens;
}

#pragma mark - Initialization

//----------------------------------------------------------------
- (id) init
{
    if ((self = [super init]))
    {
        _tokens = [NSMutableArray new];
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

    TokenBase* lastToken = [_tokens lastObject];

    if (token.type == ttConstant)
    {
        if (lastToken.type == ttUnknown || lastToken.type == ttOperator)
        {
            TokenBase* constant = [[token class] new];

            [constant updateWithInput:input];

            _tokens[_tokens.count] = constant;
        }
        else if (lastToken.type == ttConstant)
        {
            [lastToken updateWithInput:input];
        }
    }
    else if (token.type == ttFunction)
    {
        if (lastToken.type == ttConstant || lastToken.type == ttFunction)
        {
            TokenBase* function = [[token class] new];

            function.nestedToken = lastToken;

            _tokens[_tokens.count - 1] = function;
        }
    }
    else if (token.type == ttOperator)
    {
        if (lastToken.type == ttConstant || lastToken.type == ttFunction)
        {
            _tokens[_tokens.count] = [[token class] new];
        }
        else if (lastToken.type == ttOperator)
        {
            _tokens[_tokens.count - 1] = [[token class] new];
        }
    }

    return errCodeNoError;
}

//----------------------------------------------------------------
- (NSString*) displayString
{
    return [_tokens componentsJoinedByString:@""];
}

//----------------------------------------------------------------
- (NSUInteger) evaluate:(NSString**)result
{
    TokenBase* lastToken = [_tokens lastObject];

    if (lastToken.type != ttConstant && lastToken.type != ttFunction)
    {
        if (result)
        {
            *result = nil;
        }

        return errCodeIncomplete;
    }

    NSMutableArray* objects = [_tokens mutableCopy];

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

    if (result)
    {
        *result = DDDecimalToString([objects.lastObject decimalValue]);
    }

    return errCodeNoError;
}

//----------------------------------------------------------------
- (void) clear
{
    [_tokens removeAllObjects];
}

//----------------------------------------------------------------
- (void) setupWithAllowedTokens:(NSArray*)tokens
{
    _allowedTokens = [tokens copy];
}

@end
