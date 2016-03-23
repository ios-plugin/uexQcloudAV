//
//  EUExQcloudAV.h
//  EUExQcloudAV
//
//  Created by 杨广 on 16/3/23.
//  Copyright © 2016年 杨广. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EUExBase.h"
#import <TCPlayerSDK/TCPlayerSDK.h>
extern NSString *kUexQCloudTitle;//初始化显示TCPlayerBottomView底部label的名称
@interface EUExQcloudAV : EUExBase <TCPlayerEngineDelegate>
@property(nonatomic,strong) NSMutableDictionary *jsonOpenDic;
@property(nonatomic,strong) TCPlayerView *playerView;
@property(nonatomic,strong) NSNumber *timeNum;
@end
