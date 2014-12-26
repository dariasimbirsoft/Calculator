//
//  ExpressionProcessor.h
//  SimpleCalcApp
//
//  Created by Alexey Yukin on 31.10.13.
//  Copyright (c) 2013 Simbirsoft Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

//----------------------------------------------------------------
enum
{
    errCodeNoError = 0,
    errCodeNotAllowed,
    errCodeIncomplete
};

//----------------------------------------------------------------
@protocol ExpressionProcessor <NSObject>

@required

- (NSUInteger) processNewInput:(NSString*)input; // returns error code
- (NSUInteger) evaluate:(NSString**)result;      // returns error code, result will be set to nil if any error occurs while evaluating expression
- (NSString*) displayString;
- (void) clear;
- (void) setupWithAllowedTokens:(NSArray*)tokens;

@end
