//
//  SMScreenRecording.m
//  SMScreenRecording
//
//  Created by 橙汁不加橙 on 2020/5/13.
//  Copyright © 2020年 橙汁不加橙. All rights reserved.
//

#import "SMScreenRecording.h"
 
 

@implementation SMScreenRecording{
    NSInteger t;
    BOOL _run;
    NSInteger _CurrentFrame;
}

- (void)dealloc
{
    CGColorSpaceRelease(_rgbColorSpace);
    if (_outputBufferPool != NULL) {
        CVPixelBufferPoolRelease(_outputBufferPool);
    }
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        // 01 创建获取截图队列
        _concurrent_getImage_queue = dispatch_queue_create("concurrent", DISPATCH_QUEUE_CONCURRENT);
        
        // 02 创建写入视频队列
//        _serial_writeVideo_queue = dispatch_queue_create("serial", DISPATCH_QUEUE_CONCURRENT);
        _serial_writeVideo_queue = dispatch_queue_create("serial", DISPATCH_QUEUE_SERIAL);
        
        
        
        t=0;
        
        _run= NO;
        
    }
    return self;
}

/*
 *  单例方法
 */
+ (SMScreenRecording *)shareManager
{
    static SMScreenRecording *screenRecording = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        screenRecording = [[SMScreenRecording alloc] init];
        
        
    });
    return screenRecording;
}

/*
 *  开始录制屏幕
 *
 *  params: 指定视图的填充位置，可以录制指定区域
 */
- (void)startScreenRecordingWithScreenView:(UIView *)screenView recordTime:(NSInteger )sec finishBlock:(FinishBlock)finishBlock
{
    @autoreleasepool {
        
   
    if (_run) {
        return;
    }
    _run =  YES;
    // 保存需要录制的视图
    _screenView = screenView;
    __weak typeof(self) weakSelf = self;
    NSDictionary *bufferAttributes = @{(id)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA),
                                       (id)kCVPixelBufferCGBitmapContextCompatibilityKey : @YES,
                                       (id)kCVPixelBufferWidthKey : @(_screenView.frame.size.width * kScreenScale),
                                       (id)kCVPixelBufferHeightKey : @(_screenView.frame.size.height * kScreenScale),
                                       (id)kCVPixelBufferBytesPerRowAlignmentKey : @(32)
                                       };
    // 03 移除路径里面的数据
    [[NSFileManager defaultManager] removeItemAtPath:kMoviePath error:NULL];
    // 04 视频转换设置
    NSError *error = nil;
    
        if (_videoWriter) {
            _videoWriter =NULL;
            
        }
    //AVFileTypeProfileMPEG4AppleHLS
    _videoWriter = [[AVAssetWriter alloc] initWithURL:[NSURL fileURLWithPath:kMoviePath]
                                                           fileType:AVFileTypeMPEG4
                                                              error:&error];
       
    _rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    
    CVPixelBufferPoolCreate(NULL, NULL, (__bridge CFDictionaryRef)(bufferAttributes), &_outputBufferPool);
    
    if (_writerInput == NULL) {
 
      
        
   
//        if (self->_outputBufferPool != NULL) {
//            CVPixelBufferPoolRelease(self->_outputBufferPool);
//        }
   

    
   
    
    NSParameterAssert(_videoWriter);
    
    NSDictionary *videoSettings = @{AVVideoCodecKey: AVVideoCodecJPEG,
                                    AVVideoWidthKey: [NSNumber numberWithFloat:screenView.frame.size.width * kScreenScale],
                                    AVVideoHeightKey: [NSNumber numberWithFloat:screenView.frame.size.height * kScreenScale]};
    
    _writerInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo
                                                                         outputSettings:videoSettings];
    _writerInput.expectsMediaDataInRealTime = YES;
    
    _adaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:_writerInput
                                                                                                                     sourcePixelBufferAttributes:nil];
    // 05 保存block
//    self.failureBlock = failureBlock;
   
    NSParameterAssert(_writerInput);
    NSParameterAssert([_videoWriter canAddInput:_writerInput]);
   

  
     
    //Start a session:
       
    }
   
  
    // 06
    // 创建定时器
    
//    _timer = [NSTimer scheduledTimerWithTimeInterval:(1.0 / kFrames) target:self selector:@selector(timerAction:) userInfo:nil repeats:YES];
//    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
//
    if(!_timer){
        _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(0, 0));
        /**
         设置定时器
         参数1：定时器对象
         参数2：GCD dispatch_time_t 里面的都是纳秒 创建一个距离现在多少秒开启的任务
         参数3：间隔多少秒调用一次
         */
        dispatch_source_set_timer(_timer, dispatch_time(DISPATCH_TIME_NOW, 0),0.2 * NSEC_PER_SEC, 0); // 设置回调

        dispatch_source_set_event_handler(_timer, ^{
            @autoreleasepool {
            [self timerAction: nil];
            }
        });

        // 启动
        dispatch_resume(_timer);
    }else{
        dispatch_resume(_timer);
    }
    [_videoWriter addInput:_writerInput];
    // 01 初始化时间
    _startTime = CFAbsoluteTimeGetCurrent();
    [_videoWriter startWriting];
    [_videoWriter startSessionAtSourceTime:kCMTimeZero];
   
        self.finishBlock =finishBlock;
        
        _delayedBlockHandle = perform_block_after_delay(sec, ^{
            @autoreleasepool {
            if (self->_run) {
                [weakSelf endScreenRecordingWithFinishBlock:finishBlock];
            }
            }
            });
      
    }
}

 
/*
 *  停止录制屏幕
 *
 *  FinishBlock: 错误信息，视频地址
 */
- (void)endScreenRecordingWithFinishBlock:(FinishBlock) finishBlock;
{
    @autoreleasepool {
    if(_timer){
        dispatch_source_cancel(_timer);
    }
    
    
   
    
    // 01 通知多线程停止操作
//    [self performSelector:@selector(threadend) onThread:_timer_thread withObject:nil waitUntilDone:YES];
//    [_timer invalidate];
//    _timer = nil;
       
   
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1* NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        @autoreleasepool {
        
        [self->_writerInput markAsFinished];
        }
        [self->_videoWriter finishWritingWithCompletionHandler:^{
            NSLog(@"Successfully closed video writer");
    
            dispatch_async(dispatch_get_main_queue(), ^{
               
                    
                @autoreleasepool {
           
                if (self->_videoWriter.status == AVAssetWriterStatusCompleted) {
                    NSLog(@"成功");
                    if (self.finishBlock != nil) {
                        self.finishBlock(nil, kMoviePath);
                    }
                } else {
                    NSLog(@"失败");
                    if (self.finishBlock != nil) {
                        NSError *error = [NSError errorWithDomain:@"录制失败" code:-1 userInfo:nil];
                        self.finishBlock(error, nil);
                    }
                }
               
               
           
                CGColorSpaceRelease(self->_rgbColorSpace);
                if (self->_outputBufferPool != NULL) {
                    CVPixelBufferPoolRelease(self->_outputBufferPool);
                    self->_outputBufferPool =NULL;
                    
                }
               
                }
              
                
                CFRelease(CFBridgingRetain(self->_videoWriter));
                CFRelease(CFBridgingRetain(self->_screenView));
                self->_timer = nil;
                self->_run = NO;
 
//                CFRelease((__bridge CFTypeRef)(self->_timer));
//                [self->_videoWriter endSessionAtSourceTime:kCMTimeZero];
//                self->_writerInput = nil;
//                self->_videoWriter = nil;
//                self->_adaptor = nil;
            });
        }];
        
    });
    }

}

// 定时器事件
- (void)timerAction:(NSTimer *)timer
{
   
//        [[SMScreenRecording shareManager] endScreenRecordingWithFinishBlock:^(NSError *error, NSString *videoPath) {
////            [[SMScreenRecording shareManager] startScreenRecordingWithScreenView:_screenView failureBlock:^(NSError *error) {
////
////
////
////            }];
//        }];
//    }
//
    
   
     
   
    @autoreleasepool {
   
        dispatch_async(self->_concurrent_getImage_queue, ^{
           
            @autoreleasepool {
        
        CVPixelBufferRef pixelBuffer = NULL;
         CGContextRef bitmapContext = [self createPixelBufferAndBitmapContext:&pixelBuffer];
           
          
//                for (UIWindow *window in [[UIApplication sharedApplication] windows]) {
            UIGraphicsPushContext(bitmapContext);
              
                  
                [self->_screenView drawViewHierarchyInRect:self->_screenView.bounds afterScreenUpdates:NO];
                
             
//                [self wirteVideoWithBuffer:pixelBuffer];
//                }
                
          UIGraphicsPopContext();
                             
        
           
            dispatch_sync(self->_serial_writeVideo_queue, ^{
                @autoreleasepool {
            [self wirteVideoWithBuffer:pixelBuffer];
                }
        });
        CGContextRelease(bitmapContext);
                
        CVPixelBufferUnlockBaseAddress( pixelBuffer, 0 );
         CVPixelBufferRelease( pixelBuffer );
          bitmapContext = NULL;
            }
    });
    }
    
}

- (CGContextRef)createPixelBufferAndBitmapContext:(CVPixelBufferRef *)pixelBuffer
{
    @autoreleasepool {
        
 
       
    CVPixelBufferPoolCreatePixelBuffer(NULL, _outputBufferPool, pixelBuffer);
    CVPixelBufferLockBaseAddress(*pixelBuffer, 0);
    
    CGContextRef bitmapContext = NULL;
    bitmapContext = CGBitmapContextCreate(CVPixelBufferGetBaseAddress(*pixelBuffer),
                                          CVPixelBufferGetWidth(*pixelBuffer),
                                          CVPixelBufferGetHeight(*pixelBuffer),
                                          8, CVPixelBufferGetBytesPerRow(*pixelBuffer), _rgbColorSpace,
                                          kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst
                                          );
    CGContextScaleCTM(bitmapContext, kScreenScale, kScreenScale);
    dispatch_sync(dispatch_get_main_queue(), ^{
        @autoreleasepool {
        CGAffineTransform flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, self->_screenView.bounds.size.height);
        CGContextConcatCTM(bitmapContext, flipVertical);
        }

    });
   
    return bitmapContext;
    }
}


// 图片写入视频流
- (void)wirteVideoWithBuffer:(CVPixelBufferRef)buffer {
//    @autoreleasepool {
         
    if (buffer) {
        
        int nowTime = (CFAbsoluteTimeGetCurrent() - _startTime) * kFrames;
        if (_CurrentFrame==nowTime) {
            return;
        }
        NSLog(@"buffer:frame %d",nowTime);
        @try {
            @autoreleasepool {
          [_adaptor appendPixelBuffer:buffer withPresentationTime:CMTimeMake(nowTime, kFrames)];
            }
        [NSThread sleepForTimeInterval:0.1];
            CVPixelBufferRelease(buffer);
           
           
            buffer = NULL;
            _CurrentFrame = nowTime;
        } @catch (NSException *exception) {
            NSLog(@"try异常处理%@",exception);
        } @finally {
         
            
        }
    }
        
//   }
    
}



@end
