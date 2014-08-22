//
//  TKDAssetHelper.m
//  AirDrop
//
//  Created by yuichi.takeda on 8/8/14.
//  Copyright (c) 2014 mixi, Inc. All rights reserved.
//

#import "TKDAssetHelper.h"

@implementation TKDAssetHelper
+ (NSURL *)writeAssetToDocumentDirectory:(ALAsset *)asset {

    ALAssetRepresentation *defaultRep = [asset defaultRepresentation];

    NSString *dir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *path = [dir stringByAppendingPathComponent:defaultRep.filename];

    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return [NSURL fileURLWithPath:path];
    }

    size_t buf_size = (size_t)defaultRep.size;
    Byte *buf = (Byte *)malloc(buf_size);
    NSUInteger bufferd = [defaultRep getBytes:buf fromOffset:0 length:buf_size error:nil];
    NSData *data = [NSData dataWithBytesNoCopy:buf length:bufferd freeWhenDone:YES];
    [data writeToFile:path atomically:YES];

    return [NSURL fileURLWithPath:path];
}


+ (void)writeImageToPhotoAlbum:(NSURL *)fileURL deleteWhenDone:(BOOL)deleteWhenDone
{
    NSData *data = [NSData dataWithContentsOfURL:fileURL];
    ALAssetsLibrary *assetLib = [[ALAssetsLibrary alloc] init];
    [assetLib writeImageDataToSavedPhotosAlbum:data metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
        if (error) {
            NSLog(@"error on writing image %@", error);
        } else {
            if (deleteWhenDone) {
                [[NSFileManager defaultManager] removeItemAtURL:fileURL error:nil];
            }
        }
    }];
}

+ (void)removeSavedAsset:(NSURL *)fileURL {
    NSFileManager *fm = [NSFileManager new];
    [fm removeItemAtURL:fileURL error:nil];
}

@end
