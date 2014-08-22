//
//  TKDImageCell.m
//  AirDrop
//
//  Created by yuichi.takeda on 8/7/14.
//  Copyright (c) 2014 mixi, Inc. All rights reserved.
//

#import "TKDImageCell.h"

@implementation TKDImageCellItem
@end

@interface TKDImageCell ()
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIImageView *checkIcon;

@end

@implementation TKDImageCell

- (void)setItem:(TKDImageCellItem *)item {
    if (_item != item) {
        _item = item;

        self.checkIcon.hidden = !item.selected;
        self.imageView.image = item.image;

    }
}

- (void)updateSelection {
    self.checkIcon.hidden = !self.item.selected;
}

@end
