//
//  VCMain.h
//  BlunoTest
//
//  Created by Seifer on 13-12-1.
//  Copyright (c) 2013年 DFRobot. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DFBlunoManager.h"


typedef NS_ENUM(NSInteger, PanDirecton) {
    
    PanDirectonLeftFront = 3,   //左前
    
    PanDirectonFront,       //前
    
    PanDirectonRightFront,   //右前
    
    PanDirectonLeft,           //左
    
    PanDirectonRight,           //右
    
    PanDirectonLeftBack,        //左后
    
    PanDirectonBack,            //后
    
    PanDirectonBackRight        //后右
   
};

@interface VCMain : UIViewController<DFBlunoDelegate>
@property(strong, nonatomic) DFBlunoManager* blunoManager;
@property(strong, nonatomic) DFBlunoDevice* blunoDev;
@property(strong, nonatomic) NSMutableArray* aryDevices;


@property (weak, nonatomic) IBOutlet UILabel *lbReady;

@property (strong, nonatomic) IBOutlet UIView *viewDevices;
@property (weak, nonatomic) IBOutlet UITableView *tbDevices;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *SearchIndicator;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellDevices;

- (IBAction)actionSearch:(id)sender;
- (IBAction)actionReturn:(id)sender;

@end
