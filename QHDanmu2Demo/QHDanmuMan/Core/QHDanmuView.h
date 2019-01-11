//
//  QHDanmuView.h
//  QHDanmu2Demo
//
//  Created by Anakin chen on 2019/1/4.
//  Copyright © 2019 Chen Network Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "QHDanmuViewCell.h"

@class QHDanmuView;

@protocol QHDanmuViewDataSource <NSObject>

@required

- (NSInteger)numberOfPathwaysInDanmuView:(QHDanmuView * _Nonnull)danmuView;

- (CGFloat)heightOfPathwayCellInDanmuView:(QHDanmuView * _Nonnull)danmuView;

- (QHDanmuViewCell * _Nullable)danmuView:(QHDanmuView * _Nonnull)danmuView cellForPathwayWithData:(NSDictionary * _Nonnull)data;

@optional

/**
 设置弹幕飞行的时间
 */
- (CFTimeInterval)playUseTimeOfPathwayCellInDanmuView:(QHDanmuView * _Nonnull)danmuView;

/**
 设置弹幕触发时是否在找不到轨道后的处理，YES 为 删除，NO 为 等待，默认 NO
 */
- (BOOL)waitWhenNowHasNoPathwayInDanmuView:(QHDanmuView * _Nonnull)danmuView withData:(NSDictionary * _Nonnull)data;

@end

@protocol QHDanmuViewDelegate <NSObject>

- (CGFloat)danmuView:(QHDanmuView * _Nonnull)danmuView widthForPathwayWithData:(NSDictionary * _Nonnull)data;

@end

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, QHDanmuViewStyle) {
    QHDanmuViewStyleCustom,
};

typedef NS_ENUM(NSInteger, QHDanmuViewStatus) {
    QHDanmuViewStatusPlay,
    QHDanmuViewStatusStop,
    QHDanmuViewStatusPause,
};

@interface QHDanmuView : UIView

@property (nonatomic, readonly) QHDanmuViewStyle style;
@property (nonatomic, readonly) QHDanmuViewStatus status;

@property (nonatomic, weak, nullable) id <QHDanmuViewDataSource> dataSource;
@property (nonatomic, weak, nullable) id <QHDanmuViewDelegate> delegate;
// 弹幕池容量，默认 10 条
@property (nonatomic) NSUInteger danmuPoolMaxCount;

- (id)initWithFrame:(CGRect)frame style:(QHDanmuViewStyle)theStyle;

- (void)registerClass:(nullable Class)cellClass forCellReuseIdentifier:(NSString *)identifier;

- (nullable __kindof QHDanmuViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier;

- (void)insertData:(NSArray<NSDictionary *> *)data;
- (void)insertDataImmediately:(NSDictionary *)data;
- (void)cleanData;

- (void)start;
- (void)stop;
- (void)resume;
- (void)pause;

@end

NS_ASSUME_NONNULL_END
