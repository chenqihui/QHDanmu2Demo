//
//  QHDanmuModel.h
//  QHDanmu2Demo
//
//  Created by Anakin chen on 2019/1/14.
//  Copyright © 2019 Chen Network Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, QHDanmuViewCellAnimationSection) {
    QHDanmuViewCellAnimationSectionRight = 0,
    QHDanmuViewCellAnimationSectionFade = 1,
};

@interface QHDanmuModel : NSObject

@property (nonatomic) QHDanmuViewCellAnimationSection animationSection;
@property (nonatomic, copy, readonly) NSDictionary *data;

- (instancetype)initWithData:(NSDictionary *)data;

@end

NS_ASSUME_NONNULL_END
