//
//  TKDTableViewController.m
//  AirDrop
//
//  Created by yuichi.takeda on 8/13/14.
//  Copyright (c) 2014 mixi, Inc. All rights reserved.
//

#import <Bolts.h>

#import "TKDTableViewController.h"

@interface TKDTableViewController ()

@end

@implementation TKDBoltsCell
@end

@implementation TKDTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;


    [[self fetchData] continueWithBlock:^id(BFTask *task) {

        if (task.isCancelled) {
            NSLog(@"canceled");
        } else if (task.error) {
            NSLog(@"%@", task.error);
        } else {
            NSLog(@"%@", task.result);
        }
        return nil;
    }];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TKDBoltsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.myLabel.text = [NSString stringWithFormat:@"%lu", (long)indexPath.row];
    return cell;
}

- (BFTask *)fetchData {
    BFTaskCompletionSource *source = [BFTaskCompletionSource new];
    NSURL *url = [NSURL URLWithString:@"http://weather.livedoor.com/forecast/webservice/json/v1?city=130010"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {

        if (connectionError) {
            [source setError:connectionError];
        } else {
            NSError *jsonError;
            id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            if (jsonError) {
                [source setError:jsonError];
            } else {
                [source setResult:json];
            }
        }

    }];

    return source.task;
}

- (BFTask *)setFetchedData {
    return nil;
}





















@end
