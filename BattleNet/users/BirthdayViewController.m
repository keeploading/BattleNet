
//
//  BirthdayViewController.m
//  BattleNet
//
//  Created by yrliu on 14-6-4.
//  Copyright (c) 2014年 yrliu. All rights reserved.
//

#import "BirthdayViewController.h"

@interface BirthdayViewController ()
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

@end

@implementation BirthdayViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (self.date != nil){
        [self.datePicker setDate:self.date animated:NO];
    }
    if (_dateAndTime){
        [self.datePicker setDatePickerMode:UIDatePickerModeDateAndTime];
        [self.datePicker setMinuteInterval:15];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    self.date = self.datePicker.date;
}


@end
