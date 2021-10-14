//
//  ViewController.h
//  UIDemo
//
//  Created by DeveWang on 2020/9/17.
//

#import <UIKit/UIKit.h>
#import "THCapture.h"
@interface ViewController : UIViewController<THCaptureDelegate>
{
    THCapture *capture;
    NSString* opPath;
}

@end

