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

- (void)viewDidLoad
{
    [super viewDidLoad];
    _chores = [[NSMutableArray alloc] init];
    self.cellsCurrentlyEditing = [NSMutableSet new];
    
    UINib *nib = [UINib nibWithNibName:@"ChoreTableViewCell" bundle:nil];
    [[self tableView] registerNib:nib forCellReuseIdentifier:@"ChoreTableViewCell"];
}

- (void)viewWillAppear:(BOOL)animated {
    [self getNewData]; 
}

- (void)cellDidOpen:(UITableViewCell *)cell {
    NSIndexPath *currentEditingIndexPath = [self.tableView indexPathForCell:cell];
    [self.cellsCurrentlyEditing addObject:currentEditingIndexPath];
}

- (void)cellDidClose:(UITableViewCell *)cell {
    [self.cellsCurrentlyEditing removeObject:[self.tableView indexPathForCell:cell]];
}

// TODO: actually get ONLY new data
- (void)getNewData {
    PFQuery *query = [PFQuery queryWithClassName:@"Chore"];
    [query whereKey:@"houseID" equalTo:@"houseID"];
    [query includeKey:@"assignee"];
    [query orderByAscending:@"dueDate"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            for (PFObject *object in objects) {
                Chore *c = [[Chore alloc] initWithDictionary:(NSDictionary *)object];
                PFObject *user = [object objectForKey:@"assignee"];
                c.assignee = [[User alloc] initWithDictionary:(NSDictionary *)user];
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
    return 100.0f;
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
    
    if ([self.cellsCurrentlyEditing containsObject:indexPath]) {
        [cell openCell];
    }
    
    Chore *c = [_chores objectAtIndex:indexPath.row];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd/yyyy"];
    
    cell.title.text = c.title;
    cell.assigneeName.text = c.assignee.name;
    cell.dueDate.text = [formatter stringFromDate:c.dueDate];
    
    return cell;
}

@end
