//
//  TKDUserCell.m
//  AirDrop
//
//  Created by yuichi.takeda on 8/7/14.
//  Copyright (c) 2014 mixi, Inc. All rights reserved.
//

#import "TKDUserCell.h"

@implementation TKDUserCellItem
@end

@interface TKDUserCell ()
@property (strong, nonatomic) IBOutlet UIImageView *iconImageView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UIImageView *checkIcon;

@end

@implementation TKDUserCell

- (void)setItem:(TKDUserCellItem *)item {
    if (_item != item) {
        _item = item;
        self.nameLabel.text = item.peer.displayName;
        self.checkIcon.hidden = !item.selected;
    }
}

- (void)selectionUpdated
{
    self.checkIcon.hidden = !self.item.selected;
}

@end
