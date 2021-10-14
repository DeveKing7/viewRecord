//
//  WLTButton.m
//  UIDemo
//
//  Created by DeveWang on 2020/9/17.
//

#import "WLTButton.h"


@implementation WLTButton

- (id)initWithFrame:(CGRect)frame
{
    
    self = [super initWithFrame:frame];
    if (self) {
        // 高亮的时候不要自动调整图标
        self.adjustsImageWhenHighlighted = NO;
        self.titleLabel.font = [UIFont boldSystemFontOfSize:15];
        //self.titleLabel.textColor = [UIColor whiteColor];
     
       
      [self  setImageEdgeInsets:UIEdgeInsetsMake(35, 35, 35, 35)];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        // 背景
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
      self.backgroundColor =  [UIColor colorWithRed:244/255.0 green:245/255.0 blue:250/255.0 alpha:1.0];
        self.layer.cornerRadius =5;
        self.layer.masksToBounds  = YES;
        
   
        
        
    }
    return self;
}
 
-(void)setNeedsLayout{
    @try {
        /*
        UIViewContentModeScaleToFill,
        UIViewContentModeScaleAspectFit,      // contents scaled to fit with fixed aspect. remainder is transparent
        UIViewContentModeScaleAspectFill,     // contents scaled to fill with fixed aspect. some portion of content may be clipped.
        UIViewContentModeRedraw,              // redraw on bounds change (calls -setNeedsDisplay)
        UIViewContentModeCenter,              // contents remain same size. positioned adjusted.
        UIViewContentModeTop,
        UIViewContentModeBottom,
        UIViewContentModeLeft,
        UIViewContentModeRight,
        UIViewContentModeTopLeft,
        UIViewContentModeTopRight,
        UIViewContentModeBottomLeft,
        UIViewContentModeBottomRight,
         */
        
  
    for (UIImageView * v in self.subviews) {
        v.contentMode = 1;
    }
        
    } @catch (NSException *exception) {
        
    }
}
 
@end
