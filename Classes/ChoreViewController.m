//
//  ChoreViewController.m
//  Housemate
//
//  Created by Chelsea Pugh on 10/1/14.
//  Copyright (c) 2014 Chelsea Pugh. All rights reserved.
//

#import "ChoreViewController.h"
#import "ChoreTableViewCell.h"
#import <Parse/Parse.h>
#import "Chore.h"

@interface ChoreViewController ()

@end

@implementation ChoreViewController {
    NSMutableArray *_chores;
}

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
    _chores = [[NSMutableArray alloc] init];
    UINib *nib = [UINib nibWithNibName:@"ChoreTableViewCell" bundle:nil];
    [[self tableView] registerNib:nib forCellReuseIdentifier:@"ChoreTableViewCell"];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Chore"];
    [query whereKey:@"houseID" equalTo:@"houseID"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %lu chores.", (unsigned long)[objects count]);
            // Do something with the found objects
            for (PFObject *object in objects) {
                Chore *c = [[Chore alloc] initWithDictionary:(NSDictionary *)object];
                [_chores addObject:c];
            }
            [self.tableView reloadData];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - TableView

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_chores count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ChoreTableViewCell *cell =  [tableView dequeueReusableCellWithIdentifier:@"ChoreTableViewCell"];
    Chore *c = [_chores objectAtIndex:indexPath.row];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd/yyyy"];
    
    cell.title.text = c.title;
    cell.assigneeName.text = c.assignee.name;
    cell.dueDate.text = [formatter stringFromDate:c.dueDate];
    
    return cell;
}

@end
