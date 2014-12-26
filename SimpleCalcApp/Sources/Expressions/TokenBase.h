//
//  TokenBase.h
//  SimpleCalcApp
//
//  Created by Alexey Yukin on 31.10.13.
//  Copyright (c) 2013 Simbirsoft Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

//----------------------------------------------------------------
enum
{
    ttUnknown = 0,
    ttConstant,
    ttVariable,
    ttOperator,
    ttFunction
};

enum
{
    tstUnknown = 0,
    tstEquationMultiplication,
    tstEquationAddition,
    tstEquationEquality
};

//----------------------------------------------------------------
@interface TokenBase : NSObject
{
    @protected

    NSInteger  _type;
    NSInteger  _subtype;
    NSString*  _identifiers;
    NSInteger  _priority;
    TokenBase* _nestedToken;
    NSDecimal  _decimalValue;
}

@property (nonatomic, assign) NSInteger  type;
@property (nonatomic, assign) NSInteger  subtype;       // used in equation tokens only
@property (nonatomic, strong) NSString*  identifiers;
@property (nonatomic, assign) NSInteger  priority;      // operators only feature
@property (nonatomic, strong) TokenBase* nestedToken;   // may contain function or constant
@property (nonatomic, assign) NSDecimal  decimalValue;

// constants only
- (void) updateWithInput:(NSString*)input;

// operators only
- (NSDecimal) performOperationWithLeftOperand:(NSDecimal)leftOperand rightOperand:(NSDecimal)rightOperand;

@end
