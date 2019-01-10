//
//  SLCDanmuViewCell.m
//  QHDanmu2Demo
//
//  Created by Anakin chen on 2019/1/8.
//  Copyright © 2019 Chen Network Technology. All rights reserved.
//

#import "SLCDanmuViewCell.h"

#import "QHViewUtil.h"

@interface SLCDanmuViewCell ()

@property (nonatomic, readwrite, strong) UILabel *contentTextLabel;

@end

@implementation SLCDanmuViewCell

- (instancetype)initWithStyle:(QHDanmuViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self p_setup];
    }
    return self;
}

- (void)p_setup {
    UIView *bgView = [UIView new];
    bgView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    bgView.layer.masksToBounds = YES;
    bgView.layer.cornerRadius = kSLCDanmuViewCellContentHeight / 2.0f;
    [self.contentView addSubview:bgView];
    [QHViewUtil fullScreen:bgView edgeInsets:UIEdgeInsetsMake(10, 0, 0, 0)];
    
    [self p_addContentTextLabel];
}

- (void)p_addContentTextLabel {
    UILabel *contentL = [[UILabel alloc] init];
    contentL.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:contentL];
    [QHViewUtil fullScreen:contentL edgeInsets:kSLCDanmuViewCellEdgeInsets];
    _contentTextLabel = contentL;
}

@end
