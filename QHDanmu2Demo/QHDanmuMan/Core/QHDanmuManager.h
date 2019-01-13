//
//  QHDanmuManager.h
//  QHDanmu2Demo
//
//  Created by Anakin chen on 2019/1/10.
//  Copyright © 2019 Chen Network Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

// [苹果开发中文网站iOS进阶（一）block与property - CocoaChina_让移动开发更简单](http://www.cocoachina.com/ios/20170503/19165.html)
typedef CFTimeInterval(^StartTimeBlock)(NSDictionary *data);

@class QHDanmuView;

NS_ASSUME_NONNULL_BEGIN

@protocol QHDanmuManagerDelegate <NSObject>

// 弹幕减少到设定数量时进行回调 [TODO]

@end

@interface QHDanmuManager : NSObject

// 同步点播视频的播放时间点，并进行弹幕选择播放
@property (nonatomic) CFAbsoluteTime mediaPlayAbsoluteTime;

// 返回数据里面的时间戳，用于排序 & 判断是否显示
@property (nonatomic, strong) StartTimeBlock startTimeBlock;

- (instancetype)initWithDanmuView:(QHDanmuView *)danmuView;
/**
 批量加入弹幕数据（即包含时间戳的弹幕数组），并进行数组的排序
 提醒：控制弹幕的数量
 */
- (void)addDanmu:(NSArray<NSDictionary *> *)data;
/**
 加入单条弹幕，可在下一个弹幕时间点显示的弹幕
 */
- (void)insertDanmu:(NSDictionary *)data;

- (void)clean;
- (void)start;
- (void)stop;
- (void)resume;
- (void)pause;

@end

NS_ASSUME_NONNULL_END
