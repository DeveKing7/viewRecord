//
//  ViewController.m
//  UIDemo
//
//  Created by DeveWang on 2020/9/17.
//

#import "ViewController.h"
#import "WLTButton.h"
#import "SMScreenRecording.h"
#import <AVKit/AVKit.h>
#import "VideoViewController.h"
#import "YYFPSLabel.h"

#define VEDIOPATH @"vedioPath"
typedef void (^MyBlock)(void);
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property(nonatomic,strong) AVPlayer * player;

@property (weak, nonatomic) IBOutlet UIView *playerView;
@property (weak, nonatomic) IBOutlet UIView *rootView;

@property (nonatomic, strong) YYFPSLabel *fpsLabel;

@property (nonatomic, assign) DelayedBlockHandle delayedBlockHandle;

@end

@implementation ViewController{
    
    WLTButton * btn;
    CADisplayLink *_link;
    NSUInteger _count;
    NSUInteger _StartCount;
    NSTimeInterval _lastTime;
    
    UILabel *label_;
    UITableView *table_;
    
}
static  dispatch_block_t _blockToExecute;
DelayedBlockHandle perform_block_after_delay(CGFloat seconds, dispatch_block_t block) {
    if (nil == block) {
        return nil;
    }
    // block is likely a literal defined on the stack, even though we are using __block to allow us to modify the variable
    // we still need to move the block to the heap with a copy
    _blockToExecute = [block copy];
    __block DelayedBlockHandle delayHandleCopy = nil;
    DelayedBlockHandle delayHandle = ^(BOOL cancel){
        if (NO == cancel && nil != _blockToExecute) {
            dispatch_async(dispatch_get_main_queue(), _blockToExecute);
        }
        // Once the handle block is executed, canceled or not, we free blockToExecute and the handle.
        // Doing this here means that if the block is canceled, we aren't holding onto retained objects for any longer than necessary.
#if !__has_feature(objc_arc)
        [_blockToExecute release];
        [delayHandleCopy release];
#endif
        _blockToExecute = nil;
        delayHandleCopy = nil;
    };
    // delayHandle also needs to be moved to the heap.
    delayHandleCopy = [delayHandle copy];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, seconds * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if (nil != delayHandleCopy) {
            delayHandleCopy(NO);
        }
    });
    return delayHandleCopy;
};


void cancel_delayed_block(DelayedBlockHandle delayedHandle) {
    if (nil == delayedHandle) {
        return;
    }
    delayedHandle(YES);
}
 
- (void)viewDidLoad {
    [super viewDidLoad];
    _StartCount = 0;
    char deviceMd5[3];
    printf("%s",deviceMd5);
    
    //    Demo1: FPS label 用法
      [self testFPSLabel];
        
    //    Demo2: 测试在子线程使用 timer
    //    [self testSubThread];
 
//    NSString * s1 = @"1";
//    NSString * s2 = s1;
//
//    s2= @"3";
//    UIImage * u = [[UIImage alloc]init];
//
//    NSLog(@"s1:%f,s2:%f",u.size.height,u.size.width);
//
//
//
//    int  age = 10;
//        MyBlock block = ^{
//            NSLog(@"age = %d", age);
//        };
//        age = 18;
//        block();
//
//
    
//    UIView * v = [[UIView alloc]initWithFrame:CGRectMake(30, 300, 300, 300)];
//
//   btn = [[WLTButton alloc]initWithFrame:CGRectMake(30, 200, 250, 250)];
//   [btn setBackgroundImage:[UIImage imageNamed:@"2.jpg"] forState:0];
//   [btn setImage:[UIImage imageNamed:@"1"] forState:0];
//   [v addSubview:btn];
//   [self.view addSubview:v];
  
}


#pragma mark - FPS demo

- (void)testFPSLabel {
    _fpsLabel = [YYFPSLabel new];
    _fpsLabel.frame = CGRectMake(100, 400, 250, 30);
    [_fpsLabel sizeToFit];
    [self.view addSubview:_fpsLabel];
    
    // 如果直接用 self 或者 weakSelf，都不能解决循环引用问题

    // 移除也不能使 label里的 timer invalidate
    //        [_fpsLabel removeFromSuperview];
}

#pragma mark - 子线程 timer demo

- (void)testSubThread {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(200, 200, 100, 50)];
    label_ = label;
    label.backgroundColor = [UIColor grayColor];
    [table_ addSubview:label];
    
    
    // 开启子线程，新建 runloop， 避免主线程 阻塞时， timer不能用
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        _link = [CADisplayLink displayLinkWithTarget:self selector:@selector(tick:)];
        
        // NOTE: 子线程的runloop默认不创建； 在子线程获取 currentRunLoop 对象的时候，就会自动创建RunLoop
        
        // 这里不加到 main loop，必须创建一个 runloop
        NSRunLoop *runloop = [NSRunLoop currentRunLoop];
        [_link addToRunLoop:runloop forMode:NSRunLoopCommonModes];
        
        // 必须 timer addToRunLoop 后，再run
        [runloop run];
    });
    
    // 模拟 主线程阻塞 （不应该模拟主线程卡死，模拟卡顿即可）
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        NSLog(@"即将阻塞");
        dispatch_sync(dispatch_get_main_queue(), ^{
            NSLog(@"同步阻塞主线程");
        });
        NSLog(@"不会执行");
    });
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
    
   // NSString *text = [NSString stringWithFormat:@"运行次数：%lu ,%d FPS,memoryUsage:%lld kb",(unsigned long)_StartCount,(int)round(fps),[self memoryUsage] ];

    // 尝试1：主线程阻塞， 这里就不能获取到主线程了
//    dispatch_async(dispatch_get_main_queue(), ^{
//        //  阻塞时，想通过 在主线程更新UI 来查看是不可行了
//        label_.text = text;
//    });
    
    // 尝试2：不在主线程操作 UI ，界面会发生变化
//    label_.text = text;
//
//    NSLog(@"%@", text);
}

- (void)completeAlet:(NSString *)outpath andViewController:(UIViewController *) weakSelf{
    
    BOOL videoCompatible = UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(outpath);
    //检查视频能否保存至相册
    if (videoCompatible) {

        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"确定要保存视频到本地相册？" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            NSLog(@"取消保存");
        }];

        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            UISaveVideoAtPathToSavedPhotosAlbum(outpath, self,@selector(video:didFinishSavingWithError:contextInfo:), nil);
        }];

        [alertController addAction:okAction];
        [alertController addAction:cancelAction];

      [weakSelf presentViewController:alertController animated:YES completion:nil];
    } else {
        NSLog(@"该视频无法保存至相册");
    }
}


- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error) {
        NSLog(@"保存视频失败：%@", error);
    } else {
        NSLog(@"保存视频成功");
    }
}


#pragma mark - 录制的方法
- (IBAction)click_start:(id)sender {
    btn = sender;
    btn.userInteractionEnabled = NO;
     __weak typeof(self) weakSelf = self;
    
//    [[SMScreenRecording shareManager] startScreenRecordingWithScreenView:weakSelf.view recordTime:4 finishBlock:^(NSError *error, NSString *videoPath) {
//
//        NSLog(@"videoPath==%@",videoPath);
//      //为了方便连续录制，测试后再打开。
//   [weakSelf completeAlet:videoPath andViewController:weakSelf];
//        self->_fpsLabel.Scount++;
//
////      VideoViewController *videoVC = [[VideoViewController alloc] initWithVideoUrl:[NSURL URLWithString:[NSString stringWithFormat:@"file:///%@",videoPath]]];
////      [weakSelf presentViewController:videoVC animated:NO completion:nil];
//
//    }];
    
    if(capture == nil){
        capture=[[THCapture alloc] init];
    }
    capture.frameRate = 35;
    capture.delegate = self;
    capture.captureLayer = self.view;
 
    
    
    [capture performSelector:@selector(startRecording1)];
    
    NSString* path=[self getPathByFileName:VEDIOPATH ofType:@"wav"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]){
        [fileManager removeItemAtPath:path error:nil];
    }
    _delayedBlockHandle = perform_block_after_delay(4, ^{
   
      
        [self->capture performSelector:@selector(stopRecording)];
        self->btn.userInteractionEnabled = YES;
        
        });
}

#pragma mark -
#pragma mark THCaptureDelegate
- (void)recordingFinished:(NSString*)outputPath
{
    NSLog(@"成功：%@",outputPath);
    [self completeAlet:outputPath andViewController:self];
    btn.userInteractionEnabled = YES;
    //[self mergedidFinish:outputPath WithError:nil];
}

- (void)recordingFaild:(NSError *)error
{
    NSLog(@"失败：%@",error);
}


#pragma mark -
#pragma mark CustomMethod

 
- (void)StopRecord{
    if(_blockToExecute!=nil){
        cancel_delayed_block(_delayedBlockHandle);

    }
    [capture performSelector:@selector(stopRecording)];
}

- (NSString*)getPathByFileName:(NSString *)_fileName ofType:(NSString *)_type
{
    NSString* fileDirectory = [[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0]stringByAppendingPathComponent:_fileName]stringByAppendingPathExtension:_type];
    return fileDirectory;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
 

- (IBAction)click_end:(id)sender {
    [self.view endEditing:YES];
    __weak typeof(self) weakSelf = self;
    [capture performSelector:@selector(stopRecording)];
    
//    [[SMScreenRecording shareManager] endScreenRecordingWithFinishBlock:^(NSError *error, NSString *videoPath) {
//  //        NSLog(@"%@",videoPath);
//
//          NSLog(@"%@",videoPath);
//
//        VideoViewController *videoVC = [[VideoViewController alloc] initWithVideoUrl:[NSURL URLWithString:videoPath]];
//        [weakSelf presentViewController:videoVC animated:NO completion:nil];
//
//
//
//
//
//      }];
}

@end
