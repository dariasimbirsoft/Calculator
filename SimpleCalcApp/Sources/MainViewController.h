//
//  MainViewController.h
//  SimpleCalcApp
//
//  Created by Alexey Yukin on 30.10.13.
//  Copyright (c) 2013 Simbirsoft Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

//----------------------------------------------------------------
@interface MainViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView*  displayView;
@property (weak, nonatomic) IBOutlet UILabel* displayTextLabel;
@property (weak, nonatomic) IBOutlet UILabel* resultTextLabel;

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray* buttons;

- (IBAction) buttonPressed:(UIButton*)sender;

@end
