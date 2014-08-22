//
//  TKDSessionManager.m
//  AirDrop
//
//  Created by yuichi.takeda on 8/7/14.
//  Copyright (c) 2014 mixi, Inc. All rights reserved.
//

#import "TKDSessionManager.h"
#import "TKDAssetHelper.h"

@interface TKDSessionManager () <
MCSessionDelegate,
MCNearbyServiceAdvertiserDelegate,
MCNearbyServiceBrowserDelegate
>

@property (nonatomic, strong) MCSession *session;
@property (nonatomic, strong) MCNearbyServiceAdvertiser *advertiser;
@property (nonatomic, strong) MCNearbyServiceBrowser *browser;

@property (nonatomic, strong) NSMutableSet *observers;

@end

static NSString * const serviceName = @"ihrihr";

@implementation TKDSessionManager

+ (TKDSessionManager *)sharedManager {
    static dispatch_once_t onceToken;
    static TKDSessionManager *shared;
    dispatch_once(&onceToken, ^{
        shared = [[TKDSessionManager alloc] init];
    });
    return shared;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSString *name = [[UIDevice currentDevice] name];
        _myPeer = [[MCPeerID alloc] initWithDisplayName:name];
        _session = [[MCSession alloc] initWithPeer:_myPeer];
        _observers = [NSMutableSet set];
    }
    return self;
}

- (NSArray *)currentPeers {
    return self.session.connectedPeers;
}

#pragma mark - observer management
- (void)startObserving:(id<TKDSessionManagerDelegate>)observer {
    [self.observers addObject:observer];
}

- (void)stopObserving:(id<TKDSessionManagerDelegate>)observer {
    [self.observers removeObject:observer];
}

#pragma mark - Coonection managements
- (void)startFindingPeers
{
    if (self.isFinding == NO) {

        self.session = [[MCSession alloc] initWithPeer:_myPeer];
        self.session.delegate = self;

        self.advertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:_myPeer discoveryInfo:nil serviceType:serviceName];
        self.advertiser.delegate = self;
        [self.advertiser startAdvertisingPeer];

        self.browser = [[MCNearbyServiceBrowser alloc] initWithPeer:_myPeer serviceType:serviceName];
        self.browser.delegate = self;
        [self.browser startBrowsingForPeers];

        _isFinding = YES;
    }
}

- (NSProgress *)sendDataForURL:(NSURL *)url withName:(NSString *)name toPeer:(MCPeerID *)peer completionHandler:(void (^)(NSError *))completionHandler
{
    return [self.session sendResourceAtURL:url withName:name toPeer:peer withCompletionHandler:completionHandler];
}

#pragma mark Advertiser Delegate
- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didNotStartAdvertisingPeer:(NSError *)error
{
    NSLog(@"advertiser:didNotStartAdvertisingPeer becouse of :\n%@", error);
}

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void (^)(BOOL, MCSession *))invitationHandler
{
    if ([peerID.displayName compare:_myPeer.displayName] == NSOrderedDescending) {
        invitationHandler(YES, self.session);
    }
}

#pragma mark - Browser Delegate
- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info
{
    if ([peerID.displayName compare:_myPeer.displayName] == NSOrderedAscending) {
        NSLog(@"%@ inviting %@", _myPeer.displayName, peerID.displayName);
        [browser invitePeer:peerID toSession:self.session withContext:nil timeout:10];
    }
}

- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID
{
    // do nothing
}

- (void)browser:(MCNearbyServiceBrowser *)browser didNotStartBrowsingForPeers:(NSError *)error
{
    // do nothing
}


#pragma mark MCSessionDelegate

- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    if (state == MCSessionStateConnected) {
        NSLog(@"connected with %@", peerID.displayName);
        for (id<TKDSessionManagerDelegate> observer in self.observers) {
            if ([observer respondsToSelector:@selector(peerFound:)]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [observer peerFound:peerID];
                });
            }
        }
    } else if (state == MCSessionStateNotConnected) {
        NSLog(@"not connected with %@", peerID.displayName);
        for (id<TKDSessionManagerDelegate> observer in self.observers) {
            if ([observer respondsToSelector:@selector(peerLost:)]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [observer peerLost:peerID];
                });
            }
        }
    }
}

- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress
{
    for (id<TKDSessionManagerDelegate> observer in self.observers) {
        if ([observer respondsToSelector:@selector(didStartReceivingResourceWithName:fromPeer:progress:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [observer didStartReceivingResourceWithName:resourceName fromPeer:peerID progress:progress];
            });
        }
    }
}

- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error
{
    [TKDAssetHelper writeImageToPhotoAlbum:localURL deleteWhenDone:YES];

    for (id<TKDSessionManagerDelegate> observer in self.observers) {
        if ([observer respondsToSelector:@selector(didFinishReceivingResourceWithName:fromPeer:atURL:withError:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [observer didFinishReceivingResourceWithName:resourceName fromPeer:peerID atURL:localURL withError:error];
            });
        }
    }

}

- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
    // do nothing
}

- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID
{
    // do nothing
}


- (void) session:(MCSession *)session didReceiveCertificate:(NSArray *)certificate fromPeer:(MCPeerID *)peerID certificateHandler:(void (^)(BOOL accept))certificateHandler
{
    // walk around for apple's bug
    certificateHandler(YES);
}
@end
