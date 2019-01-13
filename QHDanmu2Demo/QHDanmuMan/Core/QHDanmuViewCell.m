//
//  QHDanmuViewCell.m
//  QHDanmu2Demo
//
//  Created by Anakin chen on 2019/1/4.
//  Copyright © 2019 Chen Network Technology. All rights reserved.
//

#import "QHDanmuViewCell.h"

#import "QHViewUtil.h"

@interface QHDanmuViewCell ()

@property (nonatomic, readwrite, copy, nullable) NSString *reuseIdentifier;

@property (nonatomic, readwrite, strong) UIView *contentView;
@property (nonatomic, readwrite, strong, nullable) UILabel *textLabel;

@property (nonatomic) QHDanmuViewCellStyle style;

@end

@implementation QHDanmuViewCell

- (void)dealloc {
    _reuseIdentifier = nil;
    
    _contentView = nil;
    _textLabel = nil;
    _model = nil;
}

- (instancetype)init {
    return [self initWithStyle:QHDanmuViewCellStyleDefault reuseIdentifier:nil];
}

- (instancetype)initWithStyle:(QHDanmuViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier {
    self = [super init];
    if (self) {
        self.reuseIdentifier = reuseIdentifier;
        self.style = style;
        _contentView = [[UIView alloc] init];
        [self addSubview:_contentView];
        [QHViewUtil fullScreen:_contentView];
    }
    return self;
}

#pragma mark - Get

- (UILabel *)textLabel {
    if (_style == QHDanmuViewCellStyleCustom) {
        return nil;
    }
    if (_textLabel == nil) {
        _textLabel = [[UILabel alloc] init];
        [_contentView addSubview:_textLabel];
        [QHViewUtil fullScreen:_textLabel];
    }
    return _textLabel;
}

@end

@implementation QHDanmuViewCell (Private)

- (instancetype)_qhDanmuInitWithReuseIdentifier:(nullable NSString *)reuseIdentifier {
    return [self initWithStyle:QHDanmuViewCellStyleDefault reuseIdentifier:reuseIdentifier];
}

@end
