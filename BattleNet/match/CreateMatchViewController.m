//
//  CreateMatchViewController.m
//  BattleNet
//
//  Created by Yiru Liu on 14-9-28.
//  Copyright (c) 2014年 yrliu. All rights reserved.
//

#import "CreateMatchViewController.h"
#import "BirthdayViewController.h"

@interface CreateMatchViewController ()
@property (weak, nonatomic) IBOutlet UITextField *comments;
@property (weak, nonatomic) IBOutlet UILabel *courtLabel;
@property (weak, nonatomic) IBOutlet UILabel *feeLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *placeLabel;
@property (weak, nonatomic) IBOutlet UILabel *orgnizerLabel;
@property (nonatomic) Match *match;

@end

@implementation CreateMatchViewController

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
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

    _match = [[Match alloc] init];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    switch (_match.courtType) {
        case CourtType_5:
            _courtLabel.text = @"五人制";
            break;
        case CourtType_7:
            _courtLabel.text = @"七人制";
            break;
        case CourtType_11:
            _courtLabel.text = @"十一人制";
            break;
        default:
            break;
    }
    
    switch (_match.feeType) {
        case FeeType_AA:
            _feeLabel.text = @"A-A";
            break;
        case FeeType_Loser:
            _feeLabel.text = @"败者支付";
            break;
        case FeeType_Home:
            _feeLabel.text = @"主队支付";
            break;
        case FeeType_Away:
            _feeLabel.text = @"客队支付";
            break;
        default:
            break;
    }
    if (_match.time != nil){
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"M月d日 HH:mm"];
        _timeLabel.text = [dateFormatter stringFromDate:_match.time];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelCreating:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)doneWithCreating:(id)sender {
    [_comments resignFirstResponder];
}

- (IBAction)birthdaySelected:(UIStoryboardSegue *)segue
{
    _match.time = ((BirthdayViewController*)segue.sourceViewController).date;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 6;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.comments resignFirstResponder];
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

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([@"SetMatchTime" isEqualToString:segue.identifier]){
        BirthdayViewController* controller = segue.destinationViewController;
        controller.title = @"比赛时间";
        controller.dateAndTime = YES;
        if (_match.time != nil){
            controller.date = _match.time;
        }
    }/*else if ([@"SetCourt" isEqualToString:segue.identifier]){
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_match.courtType inSection:0];
        int i = [indexPath row];
        UITableViewCell *cell = [((UITableViewController*)segue.destinationViewController).tableView cellForRowAtIndexPath:indexPath];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }*/
}

- (IBAction)courtSelected:(UIStoryboardSegue *)segue
{
    self.match.courtType = [((UITableViewController*)segue.sourceViewController).tableView indexPathForSelectedRow].row;
}

- (IBAction)feeSelected:(UIStoryboardSegue *)segue
{
    self.match.feeType = [((UITableViewController*)segue.sourceViewController).tableView indexPathForSelectedRow].row;
}

@end
