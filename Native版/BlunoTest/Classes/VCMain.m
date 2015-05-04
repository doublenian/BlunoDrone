
//  VCMain.m
//  BlunoTest
//
//  Created by Seifer on 13-12-1.
//  Copyright (c) 2013年 DFRobot. All rights reserved.
//

#import "VCMain.h"

#import "MyView.h"

#define halfScreenWidth self.view.bounds.size.width/2.0

#define halfScreenHeight self.view.bounds.size.height/2.0

@interface VCMain ()

@property (weak, nonatomic) IBOutlet MyView *myview;

@property (nonatomic) PanDirecton panDirectionState;
@property (weak, nonatomic) IBOutlet UILabel *directionText;

@end

@implementation VCMain


- (void)setPanDirectionState:(PanDirecton)panDirectionState
{
    if (_panDirectionState != panDirectionState) {
        _panDirectionState = panDirectionState;
        
        switch (panDirectionState) {
            case PanDirectonLeftFront:{
                NSLog(@"左前");
                self.directionText.text = @"左前";
                self.view.backgroundColor = [UIColor redColor];
                [self writeByteToBluno:0x04];
                break;
            }
              
            case PanDirectonFront:{
                NSLog(@"前");
                 [self writeByteToBluno:0x24];
                 self.directionText.text = @"前";
                self.view.backgroundColor = [UIColor grayColor];
                break;
            }
            case PanDirectonRightFront:{
                NSLog(@"右前");
                [self writeByteToBluno:0x20];
                self.directionText.text = @"右前";
                self.view.backgroundColor = [UIColor purpleColor];
                break;
            }
            case PanDirectonLeft:{
                NSLog(@"左");
                [self writeByteToBluno:0x14];
                self.directionText.text = @"左";
                self.view.backgroundColor = [UIColor blueColor];
                break;
            }
            case PanDirectonRight:{
                NSLog(@"右");
                [self writeByteToBluno:0x28];
                self.directionText.text = @"右";
                self.view.backgroundColor = [UIColor magentaColor];
                break;
            }
            case PanDirectonLeftBack:{
                
                NSLog(@"后左");
                 [self writeByteToBluno:0x08];
                self.directionText.text = @"后左";
                
                self.view.backgroundColor = [UIColor cyanColor];
                break;
            }
           
            case PanDirectonBack:{
                NSLog(@"后");
                [self writeByteToBluno:0x18];
                self.directionText.text = @"后";
                self.view.backgroundColor = [UIColor brownColor];
                
                break;
            }
            
            case PanDirectonBackRight:{
                NSLog(@"后右");
                
                
                 [self writeByteToBluno:0x10];
                  self.directionText.text = @"后右";
                
                self.view.backgroundColor = [UIColor orangeColor];
                
                break;
            }
                
            default:
                break;
        }
        
    }

}

- (void)getDirection
{
    
    CGFloat currentMyviewY     = self.myview.center.y;
    
    CGFloat currentMyviewX     = self.myview.center.x;
    
    
    CGFloat value = (currentMyviewX - halfScreenWidth)/(sqrt( pow(currentMyviewY - halfScreenHeight, 2.0) + pow(currentMyviewX - halfScreenWidth, 2.0) ));
    
    float cosValue = acos(value);
    
    CGFloat angle = (halfScreenHeight - currentMyviewY) > 0 ? cosValue*(180/M_PI) :(360- cosValue*(180/M_PI));
    
    
    
    if ((angle < 112.5) && (angle > 67.5)) {
        
        
        self.panDirectionState = PanDirectonFront;
    }
    if ((angle < 67.5) && (angle > 22.5)) {
        
        self.panDirectionState = PanDirectonRightFront;
    }
    
    if (((angle > 337.5) && ( angle < 360)) || ( (angle > 0) && (angle < 22.5 ))) {
        
        self.panDirectionState = PanDirectonRight;
        
    }
    if ((angle < 337.5) && (angle > 292.5)) {
        
        self.panDirectionState = PanDirectonBackRight;
    }
    if ((angle < 292.5) && (angle > 247.5)) {
        
        
        self.panDirectionState = PanDirectonBack;
    }
    if ((angle < 247.5) && (angle > 202.5)) {
        
        self.panDirectionState = PanDirectonLeftBack;
    }
    if ((angle < 202.5) && (angle > 157.5)) {
        
        self.panDirectionState = PanDirectonLeft;
    }
    if ((angle < 157.5) && (angle > 112.5)) {
        self.panDirectionState = PanDirectonLeftFront;
        
        
    }
}



#pragma mark- LifeCycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


 
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.blunoManager = [DFBlunoManager sharedInstance];
    self.blunoManager.delegate = self;
    self.aryDevices = [[NSMutableArray alloc] init];
    self.lbReady.text = @"Not Ready!";
    
    self.directionText.text = @"停止";
    
    
  
    
    
    
    
}

- (IBAction)pan:(UIPanGestureRecognizer *)sender {
    
    CGPoint translation = [sender translationInView:self.myview];
    
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        
    }else if (sender.state == UIGestureRecognizerStateChanged) {
        
        
        self.myview.center = CGPointMake(self.myview.center.x + translation.x, self.myview.center.y + translation.y);
        
        [self getDirection];
        
        [sender setTranslation:CGPointZero inView:self.myview];
        
    }else if(sender.state == UIGestureRecognizerStateEnded){
        
        self.myview.center = CGPointMake(halfScreenWidth, halfScreenHeight );
        
        [self writeByteToBluno:0];
        
        self.view.backgroundColor =  [UIColor whiteColor];
        self.directionText.text = @"停止";
        
    }
    
    
}


#pragma mark- Actions

- (IBAction)actionSearch:(id)sender
{
    [self.aryDevices removeAllObjects];
    [self.tbDevices reloadData];
    [self.SearchIndicator startAnimating];
    self.viewDevices.hidden = NO;
    
    [self.blunoManager scan];
}

- (IBAction)actionReturn:(id)sender
{
    [self.SearchIndicator stopAnimating];
    [self.blunoManager stop];
    self.viewDevices.hidden = YES;
}

-(void) writeByteToBluno:(Byte)value
{
    
    NSData *data  = [NSData dataWithBytes:&value length:1];
    
    [self.blunoManager writeDataToDevice:data Device:self.blunoDev];
}





#pragma mark- DFBlunoDelegate

-(void)bleDidUpdateState:(BOOL)bleSupported
{
    if(bleSupported)
    {
        [self.blunoManager scan];
    }
}
-(void)didDiscoverDevice:(DFBlunoDevice*)dev
{
    BOOL bRepeat = NO;
    for (DFBlunoDevice* bleDevice in self.aryDevices)
    {
        if ([bleDevice isEqual:dev])
        {
            bRepeat = YES;
            break;
        }
    }
    if (!bRepeat)
    {
        [self.aryDevices addObject:dev];
    }
    [self.tbDevices reloadData];
}
-(void)readyToCommunicate:(DFBlunoDevice*)dev
{
    self.blunoDev = dev;
    self.lbReady.text = @"Ready!";
    
    

    
    
}
-(void)didDisconnectDevice:(DFBlunoDevice*)dev
{
    self.lbReady.text = @"Not Ready!";
    
}
-(void)didWriteData:(DFBlunoDevice*)dev
{
    
}

#pragma mark- ReceiveData
-(void)didReceiveData:(NSData*)data Device:(DFBlunoDevice*)dev
{
    
    NSLog(@"received message is :%@",data);
}

#pragma mark- TableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger nCount = [self.aryDevices count];
    return nCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"ScanDeviceCell";
    NSArray *nib ;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    
    if (cell == nil)
    {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
           
           nib = [[NSBundle mainBundle] loadNibNamed:@"CellDeviceList" owner:nil options:nil];
        }
        
        cell =[nib objectAtIndex:0];
	}
    
    UILabel* lbName             = (UILabel*)[cell viewWithTag:1];
    UILabel* lbUUID             = (UILabel*)[cell viewWithTag:2];
    DFBlunoDevice* peripheral   = [self.aryDevices objectAtIndex:indexPath.row];
    
    lbName.text = peripheral.name;
    lbUUID.text = peripheral.identifier;
    
    return cell;
    
}

#pragma mark- TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DFBlunoDevice* device = [self.aryDevices objectAtIndex:indexPath.row];
    if (self.blunoDev == nil)
    {
        self.blunoDev = device;
        [self.blunoManager connectToDevice:self.blunoDev];
    }
    else if ([device isEqual:self.blunoDev])
    {
        if (!self.blunoDev.bReadyToWrite)
        {
            [self.blunoManager connectToDevice:self.blunoDev];
        }
    }
    else
    {
        if (self.blunoDev.bReadyToWrite)
        {
            [self.blunoManager disconnectToDevice:self.blunoDev];
            self.blunoDev = nil;
        }
        
        [self.blunoManager connectToDevice:device];
    }
    self.viewDevices.hidden = YES;
    [self.SearchIndicator stopAnimating];
}

@end
