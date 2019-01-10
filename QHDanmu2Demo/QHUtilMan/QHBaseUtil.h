//
//  QHBaseUtil.h
//  QHDanmu2Demo
//
//  Created by Anakin chen on 2019/1/7.
//  Copyright © 2019 Chen Network Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QHBaseUtil : NSObject

+ (CGSize)getSizeWithString:(NSString *)str fontSize:(CGFloat)fontSize;

+ (NSAttributedString *)toHTML:(NSString *)content fontSize:(CGFloat)fontSize;

@end

NS_ASSUME_NONNULL_END
