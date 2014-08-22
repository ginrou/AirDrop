//
//  TKDUserSelectionViewController.m
//  AirDrop
//
//  Created by yuichi.takeda on 8/7/14.
//  Copyright (c) 2014 mixi, Inc. All rights reserved.
//

#import "TKDUserSelectionViewController.h"
#import "TKDUserCell.h"
#import "TKDSessionManager.h"
#import "TKDSendViewController.h"

@interface TKDUserSelectionViewController () <
UICollectionViewDataSource,
UICollectionViewDelegate,
TKDSessionManagerDelegate
>
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSMutableArray *items;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *actionButton;
@end

@implementation TKDUserSelectionViewController

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

    NSString *name = [[UIDevice currentDevice] name];
    UIBarButtonItem *nameButton = [[UIBarButtonItem alloc] initWithTitle:name style:UIBarButtonItemStylePlain target:nil action:nil];
    nameButton.enabled = NO;
    [self setToolbarItems:@[nameButton]];

    [self.collectionView registerNib:[UINib nibWithNibName:@"TKDUserCell" bundle:nil]
          forCellWithReuseIdentifier:@"cell"];

    self.items = [NSMutableArray array];
    [[TKDSessionManager sharedManager] startObserving:self];
    [[TKDSessionManager sharedManager] startFindingPeers];

    [self updateTitle];
}

- (void)dealloc {
    [[TKDSessionManager sharedManager] stopObserving:self];
}

- (void)updateTitle {
    if (self.items.count == 0) {
        self.title = @"検索中...";
    } else {
        self.title = @"送信先を選択";
    }
    [self updateActionButton];
}

- (void)updateActionButton {
    BOOL hasSelection = NO;
    hasSelection = YES;
    for (TKDUserCellItem *item in self.items) {
        if (item.selected == YES) {
            hasSelection = YES;
        }
    }

    self.actionButton.enabled = hasSelection;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showSendViewController"]) {
        TKDSendViewController *sendVC = segue.destinationViewController;
        NSMutableArray *toSend = [NSMutableArray array];
        for (TKDUserCellItem *item in self.items) {
            if (item.selected) {
                [toSend addObject:item.peer];
            }
        }
        sendVC.peersToSend = toSend;
    }
}

- (IBAction)sendImagesCompletedSegue:(UIStoryboardSegue *)sender {

}

- (void)peerFound:(MCPeerID *)peerID
{
    TKDUserCellItem *item = [[TKDUserCellItem alloc] init];
    item.peer = peerID;
    item.selected = NO;
    [self.items addObject:item];
    NSIndexPath *ip = [NSIndexPath indexPathForRow:[self.items indexOfObject:item] inSection:0];
    [self.collectionView insertItemsAtIndexPaths:@[ip]];
    [self updateTitle];
}

- (void)peerLost:(MCPeerID *)peerID
{
    NSIndexPath *ip;
    for (NSInteger i = 0; i < self.items.count; ++i) {
        TKDUserCellItem *item = self.items[i];
        if (item.peer == peerID) {
            ip = [NSIndexPath indexPathForRow:i inSection:0];
        }
    }

    if (ip) {
        [self.items removeObjectAtIndex:ip.row];
        [self.collectionView deleteItemsAtIndexPaths:@[ip]];
        [self updateTitle];
    }
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TKDUserCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.item = self.items[indexPath.row];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    TKDUserCell *cell = (TKDUserCell *)[collectionView cellForItemAtIndexPath:indexPath];
    TKDUserCellItem *item = self.items[indexPath.row];
    item.selected = !item.selected;
    [cell selectionUpdated];
    [cell setNeedsLayout];
    [self updateActionButton];
}

- (void)didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peer progress:(NSProgress *)progress
{
    self.navigationItem.prompt = [NSString stringWithFormat:@"%@から%@を受信中", peer.displayName, resourceName];
}

- (void)didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error
{
    self.navigationItem.prompt = @"受信が完了しました。";
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.navigationItem.prompt = nil;
    });
}


@end
