//
//  QHBaseUtil.m
//  QHDanmu2Demo
//
//  Created by Anakin chen on 2019/1/7.
//  Copyright © 2019 Chen Network Technology. All rights reserved.
//

#import "QHBaseUtil.h"

@implementation QHBaseUtil

+ (CGSize)getSizeWithString:(NSString *)str fontSize:(CGFloat)fontSize {
    CGSize s;
    s = [str sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]}];
    return s;
}

+ (NSAttributedString *)toHTML:(NSString *)content fontSize:(CGFloat)fontSize {
    if (content == nil || content.length <= 0) {
        return nil;
    }
    NSError *error = nil;
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithData:[content dataUsingEncoding:NSUnicodeStringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSFontAttributeName: [UIFont systemFontOfSize:fontSize]} documentAttributes:nil error:&error];
    if (error != nil) {
        return nil;
    }
    return attributedString;
}

@end
