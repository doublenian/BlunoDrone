//
//  ViewController.h
//  UMDWebView
//
//  Created by Doublenian on 15/2/9.
//  Copyright (c) 2015年 com.doublenian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DFBlunoManager.h"

@interface ViewController : UIViewController<DFBlunoDelegate>
@property (strong,nonatomic) DFBlunoManager *blunoManager;
@property (strong,nonatomic) DFBlunoDevice *blunoDev;
//@property (strong,nonatomic) NSMutableArray *aryDevices;

@end

