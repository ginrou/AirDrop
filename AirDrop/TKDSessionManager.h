//
//  TKDSessionManager.h
//  AirDrop
//
//  Created by yuichi.takeda on 8/7/14.
//  Copyright (c) 2014 mixi, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
@import MultipeerConnectivity;

@protocol TKDSessionManagerDelegate;

@interface TKDSessionManager : NSObject

@property (nonatomic, readonly) MCPeerID *myPeer;
@property (nonatomic, readonly) NSArray *currentPeers;
@property (atomic, readonly) BOOL isFinding;

+ (TKDSessionManager *)sharedManager;

- (void)startFindingPeers;
- (NSProgress *)sendDataForURL:(NSURL *)url
                      withName:(NSString *)name
                        toPeer:(MCPeerID *)peer
             completionHandler:(void(^)(NSError *error))completionHandler;


- (void)startObserving:(id<TKDSessionManagerDelegate>)observer;
- (void)stopObserving:(id<TKDSessionManagerDelegate>)observer;

@end

@protocol TKDSessionManagerDelegate <NSObject>
@optional
- (void)peerFound:(MCPeerID *)peerID;
- (void)peerLost:(MCPeerID *)peerID;
- (void)didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peer progress:(NSProgress *)progress;
- (void)didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error;
@end