//
//  TKDUserCell.h
//  AirDrop
//
//  Created by yuichi.takeda on 8/7/14.
//  Copyright (c) 2014 mixi, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@import MultipeerConnectivity;


@interface TKDUserCellItem : NSObject
@property (nonatomic, strong) MCPeerID *peer;
@property (nonatomic, assign) BOOL selected;
@end



@interface TKDUserCell : UICollectionViewCell
@property (nonatomic, strong) TKDUserCellItem *item;
- (void)selectionUpdated;
@end
