//
//  LOGToken.m
//  SimpleCalcApp
//
//  Created by Alexey Yukin on 31.10.13.
//  Copyright (c) 2013 Simbirsoft Ltd. All rights reserved.
//

#import "LOGToken.h"
#import "DDDecimalFunctions.h"

//----------------------------------------------------------------
@implementation LOGToken

#pragma mark - Initialization

//----------------------------------------------------------------
- (id) init
{
    if ((self = [super init]))
    {
        _type         = ttFunction;
        _identifiers  = @"log";
        _decimalValue = DDDecimalNAN();
    }

    return self;
}

#pragma mark - Properties

//----------------------------------------------------------------
- (void) setNestedToken:(TokenBase*)nestedToken
{
    _nestedToken  = ((nestedToken.type == ttFunction || nestedToken.type == ttConstant) ? nestedToken : nil);
    _decimalValue = (_nestedToken ? DDDecimalLog10(_nestedToken.decimalValue) : DDDecimalNAN());
}

#pragma mark - Overrides

//----------------------------------------------------------------
- (NSString*) description
{
    return [NSString stringWithFormat:@"log(%@)", _nestedToken];
}

@end
