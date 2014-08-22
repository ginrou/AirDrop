//
//  TKDAssetHelper.h
//  AirDrop
//
//  Created by yuichi.takeda on 8/8/14.
//  Copyright (c) 2014 mixi, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
@import AssetsLibrary;

@interface TKDAssetHelper : NSObject
+ (NSURL *)writeAssetToDocumentDirectory:(ALAsset *)asset;
+ (void)writeImageToPhotoAlbum:(NSURL *)fileURL deleteWhenDone:(BOOL)deleteWhenDone;
+ (void)removeSavedAsset:(NSURL *)fileURL;
@end
