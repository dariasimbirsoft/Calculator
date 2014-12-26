//
//  ConstantToken.m
//  SimpleCalcApp
//
//  Created by Alexey Yukin on 31.10.13.
//  Copyright (c) 2013 Simbirsoft Ltd. All rights reserved.
//

#import "ConstantToken.h"
#import "DDDecimalFunctions.h"

//----------------------------------------------------------------
@implementation ConstantToken
{
    NSMutableString* _valueString;
}

#pragma mark - Initialization

//----------------------------------------------------------------
- (id) init
{
    if ((self = [super init]))
    {
        _type        = ttConstant;
        _identifiers = @"01234.56789";
        _valueString = [NSMutableString stringWithString:@"0"];
    }

    return self;
}

#pragma mark - Overrides

//----------------------------------------------------------------
- (NSString*) description
{
    return [_valueString copy];
}

//----------------------------------------------------------------
- (void) updateWithInput:(NSString*)input
{
    [_valueString appendString:input];

    while (YES)
    {
        NSUInteger location1 = [_valueString rangeOfString:@"." options:0].location;
        NSUInteger location2 = NSNotFound;

        if (location1 != NSNotFound)
        {
            location2 = [_valueString rangeOfString:@"." options:NSBackwardsSearch].location;
        }

        if (location1 != location2)
        {
            [_valueString deleteCharactersInRange:NSMakeRange(location2, _valueString.length - location2)];
        }
        else
        {
            break;
        }
    }

    while ([_valueString hasPrefix:@"0"])
    {
        [_valueString deleteCharactersInRange:NSMakeRange(0, 1)];
    }

    if ([_valueString hasPrefix:@"."])
    {
        [_valueString insertString:@"0" atIndex:0];
    }

    if (_valueString.length == 0)
    {
        [_valueString setString:@"0"];
    }

    _decimalValue = DDDecimalFromString([_valueString copy]);
}

@end
