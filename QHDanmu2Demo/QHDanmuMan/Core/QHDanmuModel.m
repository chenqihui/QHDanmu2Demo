//
//  QHDanmuModel.m
//  QHDanmu2Demo
//
//  Created by Anakin chen on 2019/1/14.
//  Copyright © 2019 Chen Network Technology. All rights reserved.
//

#import "QHDanmuModel.h"

@interface QHDanmuModel ()

@property (nonatomic, copy, readwrite) NSDictionary *data;

@end

@implementation QHDanmuModel

- (instancetype)initWithData:(NSDictionary *)data {
    self = [super init];
    if (self) {
        _animation = QHDanmuViewCellAnimationRight;
        _data = data;
    }
    return self;
}

// [关于使用Copy崩溃的问题 - 简书](https://www.jianshu.com/p/7c5bbea5d6e4)
- (id)copyWithZone:(NSZone *)zone {
    QHDanmuModel *model = [[QHDanmuModel alloc] initWithData:self.data];
    model.animation = self.animation;
    return model;
}

@end
