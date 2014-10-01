//
//  SignupTableViewController.m
//  BattleNet
//
//  Created by yrliu on 14-6-3.
//  Copyright (c) 2014年 yrliu. All rights reserved.
//

#import "SignupTableViewController.h"
#import "SexViewController.h"
#import "BirthdayViewController.h"
#import "PositionViewController.h"
#import "FootViewController.h"
#import "LoginViewController.h"
#import "AlbumContentsViewController.h"

@interface SignupTableViewController ()

@property (weak, nonatomic) IBOutlet UITextField *email;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UITextField *repassword;
@property (weak, nonatomic) IBOutlet UITextField *user_name;

@property (weak, nonatomic) IBOutlet UILabel *wrong_email;
@property (weak, nonatomic) IBOutlet UILabel *wrong_password;
@property (weak, nonatomic) IBOutlet UILabel *wrong_repassword;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *done;
@property (weak, nonatomic) IBOutlet UILabel *gender;
@property (weak, nonatomic) IBOutlet UILabel *birth;
@property (weak, nonatomic) IBOutlet UILabel *fieldPosition;
@property (weak, nonatomic) IBOutlet UILabel *foot;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UILabel *errorMessage;
@property (weak, nonatomic) IBOutlet UIImageView *avatar;

@property (weak, nonatomic) UITextField *currentResponder;

@end

@implementation SignupTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _password.delegate = self;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    [self.birth setText:[dateFormatter stringFromDate:[self.userManager.me birth]]];

    [self.fieldPosition setText:[self getPositionString:self.userManager.me.position]];
    
    self.email.delegate = self;
    self.password.delegate = self;
    self.repassword.delegate = self;
    self.user_name.delegate = self;

    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignOnTap:)];
    [singleTap setNumberOfTapsRequired:1];
    [singleTap setNumberOfTouchesRequired:1];
    //[self.view addGestureRecognizer:singleTap];
}

- (void)resignOnTap:(id)sender {
    [self.currentResponder resignFirstResponder];
}

- (NSString*)getPositionString:(BNUserPosition) pos
{
    switch (pos) {
        case BNUserPosition_Fan:
            return @"打酱油的";
        case BNUserPosition_GK:
            return @"守门员";
        case BNUserPosition_CB:
            return @"中后卫";
        case BNUserPosition_LSB:
            return @"左后卫";
        case BNUserPosition_RSB:
            return @"右后卫";
        case BNUserPosition_DMF:
            return @"后腰";
        case BNUserPosition_LMF:
            return @"左前卫";
        case BNUserPosition_RMF:
            return @"右前卫";
        case BNUserPosition_OMF:
            return @"前腰";
        case BNUserPosition_CF:
            return @"中锋";
        case BNUserPosition_SS:
            return @"第二前锋";
        case BNUserPosition_LWF:
            return @"左边锋";
        case BNUserPosition_RWF:
            return @"右边锋";
            
        default:
            return nil;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
        return 3;
    else
        return 6;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.currentResponder resignFirstResponder];
}

-(NSIndexPath*)tableView:(UITableView*)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.currentResponder resignFirstResponder];
    return indexPath;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)doneAction:(id)sender {
    self.errorMessage.hidden = YES;
    BOOL we = YES;
    
    NSString *str = [self.email text];
    if (str == nil || str.length < 4 || [str rangeOfString:@"@"].location == NSNotFound){
        we = NO;
        [self.wrong_email setText:@"请正确填写邮件地址。"];
    }
    [self.wrong_email setHidden:we];
    
    str = [self.password text];
    BOOL wp = YES;
    if (str.length < 6){
        wp = NO;
    }
    [self.wrong_password setHidden:wp];
    
    BOOL wr = YES;
    if ([str compare:[self.repassword text]] != NSOrderedSame){
        wr = NO;
    }
    [self.wrong_repassword setHidden:wr];
    
    if (we & wp & wr)
    {
        self.userManager.me.email = self.email.text;
        self.userManager.me.password = self.password.text;
        self.userManager.me.name = self.user_name.text;
        
        self.spinner.hidden = NO;
        self.done.enabled = NO;
        [self.userManager signup:^(NSDictionary *response) {
            self.spinner.hidden = YES;
            self.done.enabled = YES;
            
            if (response == nil){
                [self.errorMessage setText:@"网络连接错误，请稍后重试！"];
                self.errorMessage.hidden = NO;
            }else{
                if ([@"succeeded" compare:[response objectForKey:@"result"]] == NSOrderedSame){
                    [self dismissViewControllerAnimated:YES completion:nil];
                    //[self performSegueWithIdentifier:@"UserSignUp" sender:self];
                }else if ([@"duplicated_email" compare:[response objectForKey:@"result"]] == NSOrderedSame){
                    [self.wrong_email setText:@"邮箱已被使用"];
                    self.wrong_email.hidden = NO;
                }else if ([@"server_error" compare:[response objectForKey:@"result"]] == NSOrderedSame){
                    [self.errorMessage setText:@"服务器内部错误，请稍后重试！"];
                    self.errorMessage.hidden = NO;
                }
            }
        }];
    }
}
/*
- (BOOL)textField:(UITextField *) textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    NSUInteger oldLength = [textField.text length];
    NSUInteger replacementLength = [string length];
    NSUInteger rangeLength = range.length;
    
    NSUInteger newLength = oldLength - rangeLength + replacementLength;
    
    BOOL returnKey = [string rangeOfString: @"\n"].location != NSNotFound;
    
    return newLength <= 14 || returnKey;
}*/

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    _currentResponder = textField;
}


- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue destinationViewController] isKindOfClass:[SexViewController class]]){
        SexViewController *sex = [segue destinationViewController];
        [sex setGender:[self.userManager.me gender]];
    }else if ([[segue destinationViewController] isKindOfClass:[BirthdayViewController class]]){
        BirthdayViewController *birth = [segue destinationViewController];
        if (self.userManager.me.birth != nil){
            //[birth.datePicker setDate:self.me.birth animated:NO];
            birth.date = self.userManager.me.birth;
        }
    }else if ([[segue destinationViewController] isKindOfClass:[PositionViewController class]]){
        ((PositionViewController*)segue.destinationViewController).position = self.userManager.me.position;
    }else if ([[segue destinationViewController] isKindOfClass:[FootViewController class]]){
        ((FootViewController*)segue.destinationViewController).foot = self.userManager.me.foot;
    }
}

- (IBAction)sexSelected:(UIStoryboardSegue *)segue
{
    SexViewController *sex = [segue sourceViewController];
    [self.userManager.me setGender:[sex gender]];
    [self.gender setText:[sex gender] ? @"女": @"男"];
}

- (IBAction)footSelected:(UIStoryboardSegue *)segue
{
    FootViewController *footController = segue.sourceViewController;
    self.userManager.me.foot = footController.foot;
    switch (self.userManager.me.foot) {
        case BNUserFoot_Left:
            [self.foot setText:@"左脚"];
            break;
        case BNUserFoot_Right:
            [self.foot setText:@"右脚"];
            break;
        case BNUserFoot_Both:
            [self.foot setText:@"左右开弓"];
            break;
        default:
            break;
    }
}

- (IBAction)positionSelected:(UIStoryboardSegue *)segue
{
    PositionViewController *positionController = segue.sourceViewController;
    self.userManager.me.position = positionController.position;
    [self.fieldPosition setText:[self getPositionString:self.userManager.me.position]];
}

- (IBAction)birthdaySelected:(UIStoryboardSegue *)segue
{
    BirthdayViewController *birthViewController = [segue sourceViewController];
    [self.userManager.me setBirth:birthViewController.date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    [self.birth setText:[dateFormatter stringFromDate:[self.userManager.me birth]]];
}

- (IBAction)avatarCreated:(UIStoryboardSegue *)segue
{
    AlbumContentsViewController *controller = segue.sourceViewController;
    _avatar.image = controller.avatar;
}

@end
