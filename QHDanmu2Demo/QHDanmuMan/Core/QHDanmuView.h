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
- (CGFloat)playUseTimeOfPathwayCellInDanmuView:(QHDanmuView * _Nonnull)danmuView;

@end

@protocol QHDanmuViewDelegate <NSObject>

- (CGFloat)danmuView:(QHDanmuView * _Nonnull)danmuView widthForPathwayWithData:(NSDictionary * _Nonnull)data;

@end

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, QHDanmuViewStyle) {
    QHDanmuViewStyleCustom,
};

@interface QHDanmuView : UIView

@property (nonatomic, readonly) QHDanmuViewStyle style;

@property (nonatomic, weak, nullable) id <QHDanmuViewDataSource> dataSource;
@property (nonatomic, weak, nullable) id <QHDanmuViewDelegate> delegate;
@property (nonatomic) NSUInteger danmuPoolMaxCount;

- (id)initWithFrame:(CGRect)frame style:(QHDanmuViewStyle)theStyle;

- (void)registerClass:(nullable Class)cellClass forCellReuseIdentifier:(NSString *)identifier;

- (nullable __kindof QHDanmuViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier;

- (void)insertData:(NSArray<NSDictionary *> *)data;
- (void)cleanData;

@end

NS_ASSUME_NONNULL_END
