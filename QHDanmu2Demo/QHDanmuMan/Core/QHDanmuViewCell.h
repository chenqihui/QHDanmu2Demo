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

@interface QHDanmuViewCell : UIView

@property (nonatomic, readonly, copy, nullable) NSString *reuseIdentifier;

@property (nonatomic, readonly, strong) UIView *contentView;
@property (nonatomic, readonly, strong, nullable) UILabel *textLabel;

- (instancetype)initWithStyle:(QHDanmuViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier;

@end

@interface QHDanmuViewCell (Private)

- (instancetype)_qhDanmuInitWithReuseIdentifier:(nullable NSString *)reuseIdentifier;

@end

NS_ASSUME_NONNULL_END
