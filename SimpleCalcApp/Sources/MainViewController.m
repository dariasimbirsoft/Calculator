//
//  MainViewController.m
//  SimpleCalcApp
//
//  Created by Alexey Yukin on 30.10.13.
//  Copyright (c) 2013 Simbirsoft Ltd. All rights reserved.
//

#import "MainViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <AudioToolbox/AudioToolbox.h>
#import "Expression.h"
#import "Equation.h"
#import "ConstantToken.h"
#import "LOGToken.h"
#import "AdditionToken.h"
#import "SubtractionToken.h"
#import "MultiplicationToken.h"
#import "DivisionToken.h"
#import "ZVariableToken.h"
#import "EquationTokens.h"

//----------------------------------------------------------------
#define BUTTON_TAG_CLEAR        100
#define BUTTON_TAG_SOLVE        200
#define BUTTON_TAG_CALCULATE    300

//----------------------------------------------------------------
@implementation MainViewController
{
    Expression* _expression;
    Equation*   _equation;

    __weak id<ExpressionProcessor> _activeProcessor;
}

#pragma mark - Initialization

//----------------------------------------------------------------
- (id) initWithCoder:(NSCoder*)coder
{
    if ((self = [super initWithCoder:coder]))
    {
        _expression = [Expression new];

        [_expression setupWithAllowedTokens:@[[ConstantToken new], [LOGToken new], [AdditionToken new], [SubtractionToken new], [MultiplicationToken new], [DivisionToken new]]];

        _equation = [Equation new];

        [_equation setupWithAllowedTokens:@[[ConstantToken new], [ZVariableToken new], [EquationAdditionToken new], [EquationMultiplicationToken new], [EquationEqualityToken new]]];
    }

    return self;
}

#pragma mark - View lifecycle

//----------------------------------------------------------------
- (void) viewDidLoad
{
    [super viewDidLoad];

    // buttons and display style
    for (UIButton* button in _buttons)
    {
        button.layer.cornerRadius      = 3.0;
        button.layer.shadowColor       = [UIColor blackColor].CGColor;
        button.layer.shadowOffset      = CGSizeMake(0.0, 1.5);
        button.layer.shadowOpacity     = 0.9;
        button.layer.shadowRadius      = 1.0;
        button.titleLabel.shadowOffset = CGSizeMake(0.0, 0.5);
    }

    _displayView.layer.borderWidth   = 1.0;
    _displayView.layer.borderColor   = [UIColor colorWithWhite:0.0 alpha:0.75].CGColor;
    _displayView.layer.shadowColor   = [UIColor blackColor].CGColor;
    _displayView.layer.shadowOffset  = CGSizeMake(0.0, 1.5);
    _displayView.layer.shadowOpacity = 0.5;
    _displayView.layer.shadowRadius  = 2.5;

    _displayTextLabel.shadowOffset = CGSizeMake(0.0, 0.5);
    _resultTextLabel.shadowOffset  = CGSizeMake(0.0, 0.5);

    // prepare for new calculations
    [self clear];
}

#pragma mark - Autorotation

//----------------------------------------------------------------
- (BOOL) shouldAutorotate
{
    return NO;
}

#pragma mark - Actions

//----------------------------------------------------------------
- (void) buttonPressed:(UIButton*)sender
{
    AudioServicesPlaySystemSound(1104);

    NSString* input = [sender titleForState:UIControlStateNormal];

    switch (sender.tag)
    {
        case BUTTON_TAG_CLEAR:
        {
            [self clear];

            break;
        }
        case BUTTON_TAG_SOLVE:
        {
            if (![self displayingResult])
            {
                if (_activeProcessor == _equation)
                {
                    NSString* result = nil;

                    if ([_equation evaluate:&result] == errCodeNoError)
                    {
                        [self setupDisplayWithResultText:result resultTextHidden:NO];
                    }
                    else
                    {
                        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                    }
                }
            }

            break;
        }
        case BUTTON_TAG_CALCULATE:
        {
            if (![self displayingResult])
            {
                if (_activeProcessor == _equation)
                {
                    [_equation processNewInput:input];

                    [self setupDisplayWithResultText:nil resultTextHidden:YES];
                }
                else
                {
                    NSString* result = nil;

                    if ([_expression evaluate:&result] == errCodeNoError)
                    {
                        [self setupDisplayWithResultText:result resultTextHidden:NO];
                    }
                    else
                    {
                        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                    }
                }
            }

            break;
        }
        default:
        {
            if (![self displayingResult])
            {
                if (_activeProcessor)
                {
                    [_activeProcessor processNewInput:input];
                }
                else
                {
                    NSUInteger exErr = [_expression processNewInput:input];
                    NSUInteger eqErr = [_equation   processNewInput:input];

                    if (exErr == errCodeNotAllowed)
                    {
                        _activeProcessor = _equation;
                    }
                    else if (eqErr == errCodeNotAllowed)
                    {
                        _activeProcessor = _expression;
                    }
                }

                [self setupDisplayWithResultText:nil resultTextHidden:YES];
            }

            break;
        }
    }
}

#pragma mark - Private methods

//----------------------------------------------------------------
- (void) setupDisplayWithResultText:(NSString*)resultText resultTextHidden:(BOOL)resultTextHidden
{
    _resultTextLabel.text   = resultText;
    _resultTextLabel.hidden = resultTextHidden;

    _displayTextLabel.text   = (_activeProcessor ? _activeProcessor.displayString : _expression.displayString);
    _displayTextLabel.hidden = !resultTextHidden;
}

//----------------------------------------------------------------
- (BOOL) displayingResult
{
    return !_resultTextLabel.hidden;
}

//----------------------------------------------------------------
- (void) clear
{
    [_expression clear];
    [_equation clear];

    _activeProcessor = nil;

    [self setupDisplayWithResultText:nil resultTextHidden:YES];
}

@end
