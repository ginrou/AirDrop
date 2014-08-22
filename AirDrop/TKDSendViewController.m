//
//  TKDSendViewController.m
//  AirDrop
//
//  Created by yuichi.takeda on 8/7/14.
//  Copyright (c) 2014 mixi, Inc. All rights reserved.
//

@import AssetsLibrary;

#import "TKDSendViewController.h"

#import "TKDSessionManager.h"

#import "TKDMinUserCell.h"
#import "TKDImageCell.h"
#import "TKDAssetHelper.h"

@interface TKDSendViewController () <
UICollectionViewDelegate,
UICollectionViewDataSource,
TKDSessionManagerDelegate
>
@property (strong, nonatomic) IBOutlet UICollectionView *imagesCollectionView;
@property (strong, nonatomic) IBOutlet UICollectionView *usersCollectionView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *sendButton;
@property (strong, nonatomic) ALAssetsLibrary *assetLib;

@property (strong, nonatomic) NSMutableArray *items;

@end

@implementation TKDSendViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.items = [NSMutableArray array];

    [self.usersCollectionView registerNib:[UINib nibWithNibName:@"TKDMinUserCell" bundle:nil]
               forCellWithReuseIdentifier:@"user"];

    [self.imagesCollectionView registerNib:[UINib nibWithNibName:@"TKDImageCell" bundle:nil]
                forCellWithReuseIdentifier:@"image"];

    self.assetLib = [[ALAssetsLibrary alloc] init];
    [self loadImages];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateSendButton];
}

- (void)updateSendButton {
    BOOL selected = NO;
    for (TKDImageCellItem *item in self.items) {
        if (item.selected) selected = YES;
    }

    self.sendButton.enabled = selected;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadImages {

    [self.assetLib enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {

        NSInteger itemCount = self.items.count;
        [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            TKDImageCellItem *item = [[TKDImageCellItem alloc] init];
            item.image = [UIImage imageWithCGImage:result.thumbnail];
            item.resourceURL = [result valueForProperty:ALAssetPropertyAssetURL];
            item.selected = NO;
            [self.items addObject:item];
        }];

        if (itemCount != self.items.count) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.imagesCollectionView reloadData];
            });
        }

    } failureBlock:^(NSError *error) {

    }];

}

/*
 #pragma mark - Navigation

 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (collectionView == self.imagesCollectionView) {
        return self.items.count;
    } else {
        return self.peersToSend.count;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{

    if (collectionView == self.usersCollectionView) {

        TKDMinUserCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"user" forIndexPath:indexPath];
        MCPeerID *peer = self.peersToSend[indexPath.row];
        cell.nameLabel.text = peer.displayName;
        return cell;

    } else {

        TKDImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"image" forIndexPath:indexPath];
        cell.item = self.items[indexPath.row];
        return cell;

    }

}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == self.imagesCollectionView) {
        TKDImageCellItem *item = self.items[indexPath.row];
        item.selected = !item.selected;
        TKDImageCell *cell = (TKDImageCell *)[collectionView cellForItemAtIndexPath:indexPath];
        [cell updateSelection];
        [self updateSendButton];
    }
}

- (IBAction)sendButtonTapped:(id)sender {

    for (TKDImageCellItem *item in self.items) {
        if (item.selected == NO) continue;

        [self.assetLib assetForURL:item.resourceURL resultBlock:^(ALAsset *asset) {

            NSURL *url = [TKDAssetHelper writeAssetToDocumentDirectory:asset];
            for (MCPeerID *peer in self.peersToSend) {
                [[TKDSessionManager sharedManager] sendDataForURL:url withName:asset.defaultRepresentation.filename toPeer:peer completionHandler:^(NSError *error) {

                    if (error) {
                        NSLog(@"Failed to send to %@ reason %@", peer.displayName, error);
                    } else {
                        NSLog(@"success to send to %@", peer.displayName);
                    }

                }];
            }
            
            
        } failureBlock:^(NSError *error) {
            NSLog(@"failed to load %@", error);
        }];
        
    }
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
