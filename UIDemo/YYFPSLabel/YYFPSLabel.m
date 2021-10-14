//
//  YYFPSLabel.m
//  YYKitExample
//
//  Created by ibireme on 15/9/3.
//  Copyright (c) 2015 ibireme. All rights reserved.
//

#import "YYFPSLabel.h"
#import "YYWeakProxy.h"
#import <mach/mach.h>
#define kSize CGSizeMake(255, 20)

@implementation YYFPSLabel {
    CADisplayLink *_link;
    NSUInteger _count;
    NSTimeInterval _lastTime;
    UIFont *_font;
    UIFont *_subFont;
    
    NSTimeInterval _llll;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (frame.size.width == 0 && frame.size.height == 0) {
        frame.size = kSize;
    }
    self = [super initWithFrame:frame];
    
    self.layer.cornerRadius = 5;
    self.clipsToBounds = YES;
    self.textAlignment = NSTextAlignmentCenter;
    self.userInteractionEnabled = NO;
    self.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.700];
    
    _font = [UIFont fontWithName:@"Menlo" size:12];
    if (_font) {
        _subFont = [UIFont fontWithName:@"Menlo" size:12];
    } else {
        _font = [UIFont fontWithName:@"Courier" size:12];
        _subFont = [UIFont fontWithName:@"Courier" size:12];
    }
    
    // 如果直接用 self 或者 weakSelf，都不能解决循环引用问题
    
    // 将 timer 的 target 从 self ，变成了中间人 NSProxy
    // timer 调用 target 的 selector 时，会被 NSProxy 内部转调用 self 的 selector
    _link = [CADisplayLink displayLinkWithTarget:[YYWeakProxy proxyWithTarget:self] selector:@selector(tick:)];
//    __weak typeof(self) weakSelf = self;
//    _link = [CADisplayLink displayLinkWithTarget:weakSelf selector:@selector(tick:)];
    [_link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    
    return self;
}

- (void)dealloc {
    [_link invalidate];
    NSLog(@"timer release");
}

- (CGSize)sizeThatFits:(CGSize)size {
    return kSize;
}

- (void)tick:(CADisplayLink *)link {
    if (_lastTime == 0) {
        _lastTime = link.timestamp;
        return;
    }
    
    _count++;
    NSTimeInterval delta = link.timestamp - _lastTime;
    if (delta < 1) return;
    _lastTime = link.timestamp;
    float fps = _count / delta;
    _count = 0;
    
    CGFloat progress = fps / 60.0;
    UIColor *color = [UIColor colorWithHue:0.27 * (progress - 0.2) saturation:1 brightness:0.9 alpha:1];
    
    NSString *text1 = [NSString stringWithFormat:@"运行次数：%ld, %d FPS,m:%lld kb",(long)_Scount,(int)round(fps),[self memoryUsage]];
    NSLog(@"%@", text1);

    
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:text1];
    [text addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, text.length - 1)];
    [text addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(text.length - 3, 3)];
    [text addAttribute:NSFontAttributeName value:_font range:NSMakeRange(0, text.length)];
    [text addAttribute:NSFontAttributeName value:_subFont range:NSMakeRange(text.length - 4, 1)];
    self.attributedText = text;
}
- (int64_t)memoryUsage {
    int64_t memoryUsageInByte = 0;
    task_vm_info_data_t vmInfo;
    mach_msg_type_number_t count = TASK_VM_INFO_COUNT;
    kern_return_t kernelReturn = task_info(mach_task_self(), TASK_VM_INFO, (task_info_t) &vmInfo, &count);
    if(kernelReturn == KERN_SUCCESS) {
        memoryUsageInByte = (int64_t) vmInfo.phys_footprint;
        NSLog(@"APP占用内存: %lld字节(B)", memoryUsageInByte);
        int64_t mb = memoryUsageInByte / 1024 / 1024;
        NSLog(@"APP占用内存: %lld兆(MB)", mb);
    } else {
        NSLog(@"Error with task_info(): %s", mach_error_string(kernelReturn));
    }
    return  memoryUsageInByte / 1024;
}
@end
