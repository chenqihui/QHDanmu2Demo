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

@end

@interface QHDanmuManager : NSObject

@property (nonatomic) CFAbsoluteTime mediaPlayAbsoluteTime;

@property (nonatomic, strong) StartTimeBlock startTimeBlock;

- (instancetype)initWithDanmuView:(QHDanmuView *)danmuView;

- (void)addDanmu:(NSArray<NSDictionary *> *)data;
- (void)insertDanmu:(NSDictionary *)data;

- (void)start;
- (void)stop;
- (void)resume;
- (void)pause;

@end

NS_ASSUME_NONNULL_END
