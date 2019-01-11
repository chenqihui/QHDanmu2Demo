//
//  QHDanmuViewCell.h
//  QHDanmu2Demo
//
//  Created by Anakin chen on 2019/1/4.
//  Copyright © 2019 Chen Network Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, QHDanmuViewCellStyle) {
    QHDanmuViewCellStyleDefault,
    QHDanmuViewCellStyleCustom
};

// [【iOS开发】结构体如何存入数组中 - wm9028的专栏 - CSDN博客](https://blog.csdn.net/wm9028/article/details/50681773)
struct QHDanmuCellParam {
    CGFloat speed;
    CGFloat width;
    NSInteger pathwayNumber;
    CFTimeInterval startTime;
};
typedef struct QHDanmuCellParam QHDanmuCellParam;

@interface QHDanmuViewCell : UIView

@property (nonatomic, readonly, copy, nullable) NSString *reuseIdentifier;

@property (nonatomic, readonly, strong) UIView *contentView;
@property (nonatomic, readonly, strong, nullable) UILabel *textLabel;
@property (nonatomic) QHDanmuCellParam param;

- (instancetype)initWithStyle:(QHDanmuViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier;

@end

@interface QHDanmuViewCell (Private)

- (instancetype)_qhDanmuInitWithReuseIdentifier:(nullable NSString *)reuseIdentifier;

@end

NS_ASSUME_NONNULL_END
