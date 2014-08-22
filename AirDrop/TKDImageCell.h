//
//  TKDImageCell.h
//  AirDrop
//
//  Created by yuichi.takeda on 8/7/14.
//  Copyright (c) 2014 mixi, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TKDImageCellItem : NSObject
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSURL *resourceURL;
@property (nonatomic, assign) BOOL selected;
@end

@interface TKDImageCell : UICollectionViewCell
@property (nonatomic, strong) TKDImageCellItem *item;

- (void)updateSelection;
@end
