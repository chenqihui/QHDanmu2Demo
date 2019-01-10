//
//  SLCDanmuViewCell.h
//  QHDanmu2Demo
//
//  Created by Anakin chen on 2019/1/8.
//  Copyright © 2019 Chen Network Technology. All rights reserved.
//

#import "QHDanmuViewCell.h"

NS_ASSUME_NONNULL_BEGIN

#define kSLCDanmuViewCellTop 10.0f
#define kSLCDanmuViewCellContentHeight 28.0f
#define kSLCDanmuViewCellHeight 38.0f
#define kSLCDanmuViewCellEdgeInsets UIEdgeInsetsMake(10, 12, 0, 12)

@interface SLCDanmuViewCell : QHDanmuViewCell

@property (nonatomic, readonly, strong) UILabel *contentTextLabel;

@end

NS_ASSUME_NONNULL_END
