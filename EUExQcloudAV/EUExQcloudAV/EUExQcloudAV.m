//
//  EUExQcloudAV.m
//  EUExQcloudAV
//
//  Created by 杨广 on 16/3/23.
//  Copyright © 2016年 杨广. All rights reserved.
//

#import "EUExQcloudAV.h"
#import "JSON.h"
#import "EUtility.h"
#import "TCCloudPlayerControlView.h"
#import "TCPlayerBottomView.h"
#import "TCPlayItem.h"

NSString *kUexQCloudTitle = nil;
@implementation EUExQcloudAV
-(id)initWithBrwView:(EBrowserView *) eInBrwView {
    if (self = [super initWithBrwView:eInBrwView]) {
        
    }
    return self;
}
-(void)open:(NSMutableArray *)inArguments{
    NSString *jsonStr = nil;
    if (inArguments.count > 0) {
        jsonStr = [inArguments objectAtIndex:0];
        self.jsonOpenDic = [jsonStr JSONValue];//将JSON类型的字符串转化为可变字典
        
    }else{
        return;
    }
    CGFloat x = [self.jsonOpenDic[@"x"] floatValue];
    CGFloat y = [self.jsonOpenDic[@"y"] floatValue];
    CGFloat width = [self.jsonOpenDic[@"width"] floatValue];
    CGFloat height = [self.jsonOpenDic[@"height"] floatValue];
    NSUInteger index = [self.jsonOpenDic[@"index"] intValue];
    NSUInteger sec = [self.jsonOpenDic[@"startSeconds"] intValue];
    NSArray *data = self.jsonOpenDic[@"data"];
    kUexQCloudTitle = data[0][@"desc"];
    [TCPlayerView setPlayerBottomViewClass:[TCPlayerBottomView class]];
    [TCPlayerView setPlayerCtrlViewClass:[TCCloudPlayerControlView class]];
    _playerView = [[TCPlayerView alloc] init];
    _playerView.frame = CGRectMake(x, y, width, height);
    _playerView.playerDelegate = self;
    _playerView.enableCache = YES;
    _playerView.clearPlayCache = NO;
    [_playerView enableNetworkMonitoring];
    [EUtility brwView:meBrwView addSubview:_playerView];
    
    TCPlayResItem *res = [[TCPlayResItem alloc] init];
    
    for (NSDictionary *dic in data) {
        TCPlayItem* info = [[TCPlayItem alloc]init];
        info.type = dic[@"desc"];
        info.url = dic[@"url"] ;
        [res.items addObject:info];
    }
    [_playerView play:res atIndex:index fromSeconds:sec];
    
}
-(void)play:(NSMutableArray *)inArguments{
    [self.playerView play];
}
-(void)stop:(NSMutableArray *)inArguments{
    [self.playerView stop];
}
-(void)pause:(NSMutableArray *)inArguments{
    [self.playerView pause];
}

-(void)close:(NSMutableArray *)inArguments{
    [self.playerView removeFromSuperview];
    self.playerView = nil;
}

-(void)clear:(NSMutableArray *)inArguments{
    [TCPlayerView clearAllPlayCache];
    
}
-(void)seekTo:(NSMutableArray *)inArguments{
    NSString *jsonStr = nil;
    if (inArguments.count > 0) {
        jsonStr = [inArguments objectAtIndex:0];
    }else{
        return;
    }

    [self.playerView seekToTime:[jsonStr intValue] completion:nil];
}
-(void)getCurrentTime:(NSMutableArray *)inArguments{
    [self onCurrentTime:self.playerView time:0];
    NSString *jsonStr = [self.timeNum JSONFragment];
    NSString *jsString = [NSString stringWithFormat:@"uexQcloudAV.cbGetCurrentTime('%@');",jsonStr];
    [EUtility brwView:self.meBrwView evaluateScript:jsString];
    
}

- (void)onPlayOver:(id<TCPlayerEngine>)player
{
    NSNumber *stateBackText = @5;
    NSString *jsonStr = [stateBackText JSONFragment];
    NSString *jsString = [NSString stringWithFormat:@"uexQcloudAV.onStateChanged('%@');",jsonStr];
    [EUtility brwView:self.meBrwView evaluateScript:jsString];
    NSLog(@"播放结束") ;
}
// 回调当前播放时间
- (void)onCurrentTime:(id<TCPlayerEngine>)player time:(NSInteger)time
{
    self.timeNum = [NSNumber numberWithFloat:(long)[player currentTime]];
    
    
}

// 播放器状态改变
- (void)onStateChanged:(id<TCPlayerEngine>)player toState:(TCPlayerState)state
{
    NSNumber *stateBackText = nil;
    BOOL isShow = YES;
    switch (state)
    {
        case TCPlayerState_Init:
            stateBackText = @0;                          // 初始化
            break;
        case TCPlayerState_Preparing:                    // 准备阶段
            stateBackText = @1;
            break;
        case TCPlayerState_Buffering:                    // 缓冲
            stateBackText = @2;
            break;
        case TCPlayerState_Play:                          // 播放
            stateBackText = @3;
            break;
        case TCPlayerState_Pause:                        // 暂停
            stateBackText = @4;
            break;
        case TCPlayerState_Stop:        //停止
            isShow = NO;
            break;
        case TCPlayerState_PauseByLimitTime:   // 限时暂停
            isShow = NO;
            break;
        default:
            break;
    }
    if (isShow) {
        
        NSString *jsonStr = [stateBackText JSONFragment];
        NSString *jsString = [NSString stringWithFormat:@"uexQcloudAV.onStateChanged('%@');",jsonStr];
        [EUtility brwView:self.meBrwView evaluateScript:jsString];
    }
}
- (void)onPlayerFailed:(id<TCPlayerEngine>)player errorType:(TCPlayerErrorType)errType{
    NSNumber *stateBackText = nil;
    switch (errType) {
        case TCPlayerError_UnKnowError:
        stateBackText = @(-1);
        break;
        case TCPlayerError_MediaFormat_Error:
        stateBackText = @(-1);
        break;
        case TCPlayerError_BufferingTimerOut:
        stateBackText = @(-1);
        break;
        
        case TCPlayerError_Unsupport:
        stateBackText = @(-1);
        break;
        default:
        stateBackText = @(-1);
        break;
    }
    NSString *jsonStr = [stateBackText JSONFragment];
    NSString *jsString = [NSString stringWithFormat:@"uexQcloudAV.onStateChanged('%@');",jsonStr];
    [EUtility brwView:self.meBrwView evaluateScript:jsString];
}

//切换网络时触发
-(void)onNetworkStateChanged:(id<TCPlayerEngine>)player toState:(TCPlayerNetworkState)state{
    NSNumber *networkState = nil;
    switch (state)
    {
        case TCPlayerNetwork_NotReachable:
            networkState =@0; //@"无网络";
            break;
        case TCPlayerNetwork_WWAN:
            networkState = @1;//@"移动网络";
            break;
        case TCPlayerNetwork_WIFI:
            networkState = @2;//@"WIFI";
            break;
        default:
            break;
    }
    
    NSString *jsonStr = [networkState JSONFragment];
    NSString *jsString = [NSString stringWithFormat:@"uexQcloudAV.onNetworkStateChanged('%@');",jsonStr];
    [EUtility brwView:self.meBrwView evaluateScript:jsString];
    NSLog(@"%@",networkState);
    
}

@end
