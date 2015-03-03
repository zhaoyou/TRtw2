//
//  PublicTimelineViewController.m
//  TRtw2
//
//  Created by zhaoyou on 2/28/15.
//  Copyright (c) 2015 zhaoyou. All rights reserved.
//

#import "PublicTimelineViewController.h"
#import "AppDelegate.h"
#import "Social/SLRequest.h"
#import "Twitter/TWRequest.h"
#import "TweetCell.h"

@interface PublicTimelineViewController ()


@property  (strong, nonatomic) NSArray *tweetsArray;
-(void) getFeed;
-(void) updateFeed: (id)feed;

@end

@implementation PublicTimelineViewController


-(void) getFeed
{
    // build url
    NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/home_timeline.json"];
    
    // paramters for request
    
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"15", @"count", nil];
    
    // TODO should using Social framework instead Twitter Framework.
    // create a request
    TWRequest *twitterFeed = [[TWRequest alloc]initWithURL:url parameters:dictionary requestMethod:TWRequestMethodGET];
    
    
    
    UIApplication *application = [UIApplication sharedApplication];
    
    application.networkActivityIndicatorVisible = YES;
    
    AppDelegate *delegate = [application delegate];
    
    //SLRequest *request = [[SLRequest alloc]init];
    //[request setAccount:delegate.userAccount];
    
    //[SLRequest ]

    
    twitterFeed.account = delegate.userAccount;
    
    NSLog(@"get twitter feed before");
    
    // get twitter feed.
    
    [twitterFeed performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        
        NSLog(@"%@", error);
        if (!error) {
            // updateFeed.
            NSError *jsonError = nil;
            
            id feedData = [NSJSONSerialization JSONObjectWithData:responseData options:nil error:&jsonError];
            
            if (!jsonError) {
                [self updateFeed:feedData];
            } else {
                // show alert view.
                UIAlertView *alarmView = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alarmView show];
            }
        } else {
            // show alert view.
            UIAlertView *alarmView = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alarmView show];
        }
        
        application.networkActivityIndicatorVisible = NO;
    }];
    
    
}

-(void) updateFeed: (id)feed
{
    self.tweetsArray = feed;
    [self.tableView reloadData];
    NSLog(@"%@", feed);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    AppDelegate *delete = [[UIApplication sharedApplication] delegate];
    
    if (delete.userAccount) {
        [self getFeed];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(getFeed)
                                                 name:@"TwitterAccountAcquiredNotification"
                                               object:nil];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(BOOL) canBecomeFirstResponder
{
    return YES;
}

#pragma mark - view didAppear
-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self becomeFirstResponder];
}

-(void) viewDidDisappear:(BOOL)animated
{
    [self resignFirstResponder];
    [super viewDidDisappear:animated];
}

- (void) motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    [self getFeed];
}

-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return  UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [self.tweetsArray count];
}

/***/
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
     TweetCell *cell = [tableView dequeueReusableCellWithIdentifier:@"contentCell" forIndexPath:indexPath];
    
    // Configure the cell...
    
    NSDictionary *currentTweet = [self.tweetsArray objectAtIndex:indexPath.row];
    
    NSDictionary *currentUser = [currentTweet objectForKey:@"user"];
    
    cell.usernameLabel.text = [currentUser objectForKey:@"name"];
    cell.tweetLabel.text = [currentTweet objectForKey:@"text"];
    
    
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    
    NSString *username = cell.usernameLabel.text;
    
    if ([delegate.profileImages objectForKey:username]) {
        
        cell.userImage.image = [delegate.profileImages objectForKey:username];
    } else {
        
        dispatch_queue_t currentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        
        dispatch_async(currentQueue, ^{
            
            // get user image url.
            NSURL *imageUrl = [NSURL URLWithString:[currentUser objectForKey:@"profile_image_url"]];
            // NSData for imageView
            __block NSData *imageData;
            
            dispatch_async(currentQueue, ^{
                imageData = [NSData dataWithContentsOfURL:imageUrl];
                
                [delegate.profileImages setObject:[UIImage imageWithData:imageData]  forKey:username];
                
                // main queue for update UI.
                dispatch_async(dispatch_get_main_queue(), ^{
                    cell.userImage.image = [delegate.profileImages objectForKey:username];
                });
                
            });
            
            
            
        });
    }
    
    
 //   cell.userImage.image = [UIImage imageNamed:@"Go.jpg"];
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
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
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
