//
//  ViewController.m
//  UMDWebView
//
//  Created by Doublenian on 15/2/9.
//  Copyright (c) 2015年 com.doublenian. All rights reserved.
//

#import "ViewController.h"



@interface ViewController ()<UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *myWebView;

@property (strong,nonatomic) NSMutableDictionary *blunoDict;

@property (strong,nonatomic) NSMutableArray *blunoArrary;

@property (nonatomic) BOOL isScan;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"h5/angular" ofType:@"html"] ];
    
    [_myWebView loadRequest:[NSURLRequest requestWithURL:url]];
    
    NSString *initScript = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"getUrl" ofType:@"js" ] encoding:NSUTF8StringEncoding error:NULL];
    

    _myWebView.delegate = self;
    
    _myWebView.scrollView.scrollEnabled = NO;
    
    _myWebView.scrollView.bounces = NO;
    
    
    self.blunoManager = [DFBlunoManager sharedInstance];
    self.blunoManager.delegate = self;
    
    self.isScan = NO;
    self.blunoDict = [[NSMutableDictionary alloc]init];
    self.blunoArrary = [[NSMutableArray alloc]init];
    
    
    [self.myWebView stringByEvaluatingJavaScriptFromString:initScript];
    
    
    
    
    
}

#pragma mark - WebView Delegate Method

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{

    
    NSLog(@"should Start Loading");
    
   
    
    if ([request.URL.lastPathComponent isEqualToString:@"scan"]) {
        NSLog(@"scan");
        
         [self.blunoDict removeAllObjects];
        
         [self.blunoArrary removeAllObjects];
        
         self.isScan = YES;
        
         [self.blunoManager scan];
        
         [self reloadBlunDict];
         return  NO;
    }    
    if (([[request.URL pathComponents] count] > 1 ) ) {
        
        
        if ([[[request.URL pathComponents] objectAtIndex:1] isEqualToString:@"connect"]) {
            
            NSLog(@"the last Path components is %@",request.URL.lastPathComponent);
            
            NSString *willConnectDeviceID = request.URL.lastPathComponent;
            
            for (DFBlunoDevice * dev in self.blunoArrary) {
                if ([dev.identifier isEqualToString:willConnectDeviceID]) {
                    [self connectToDevice:dev];
                }
            }
              return NO;
        }
        
        if ([[[request.URL pathComponents] objectAtIndex:1] isEqualToString:@"write"]) {
            
            NSLog(@"the last Path components is %@",request.URL.lastPathComponent);
            
            NSString *writeCmd = request.URL.lastPathComponent;
            
            int i =  [writeCmd intValue];
            
            NSLog(@"the i is %d",i);
            
            [self writeByteToBluno:i];
            
            return NO;
            
        }
      
      
    }
    
    

    return YES;

}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    NSLog(@"WebView Did Start Load");

}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"WebView Did Finish Load");
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"webview did FailLoad With Error");

}


#pragma mark - DFBluno Delegate Method

-(void)bleDidUpdateState:(BOOL)bleSupported
{
    if(bleSupported)
    {
      //  [self.blunoManager scan];
    }
}
-(void)didDiscoverDevice:(DFBlunoDevice*)dev
{
    BOOL bRepeat = NO;
    for (NSString *identifier in self.blunoDict)
    {
        if ([identifier isEqualToString:dev.identifier])
        {
            bRepeat = YES;
            break;
        }
    }
    if (!bRepeat)
    {
        [self.blunoDict setObject:dev.name forKey:dev.identifier];
        
        [self.blunoArrary addObject:dev];
    }
    if (self.isScan) {
        [self reloadBlunDict];
    }
    
}

- (void)reloadBlunDict
{
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self.blunoDict options:NSJSONWritingPrettyPrinted error:NULL];
    NSString *astr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSString *blunDictscript = [NSString stringWithFormat:@"umdi.blunDict = %@",astr];
    
    NSLog(@"the script is %@",blunDictscript);
    
    [self.myWebView stringByEvaluatingJavaScriptFromString:blunDictscript];
    
    NSString *reload = @"scanResult()";
    
    [self.myWebView stringByEvaluatingJavaScriptFromString:reload];


}
-(void)readyToCommunicate:(DFBlunoDevice*)dev
{
    self.blunoDev = dev;
  //  self.lbReady.text = @"Ready!";
    
    NSLog(@"Ready");
    [self.myWebView stringByEvaluatingJavaScriptFromString:@"umdi.status('Ready');"];
    
    
    
}


-(void)didDisconnectDevice:(DFBlunoDevice*)dev
{
   // self.lbReady.text = @"Not Ready!";
     [self.myWebView stringByEvaluatingJavaScriptFromString:@"umdi.status('Not Ready');"];
    
}
-(void)didWriteData:(DFBlunoDevice*)dev
{
    
}


#pragma mark - Received Data

-(void)didReceiveData:(NSData*)data Device:(DFBlunoDevice*)dev
{
    
    NSLog(@"received message is :%@",data);
}

-(void) writeByteToBluno:(int)value
{
    
    NSData *data  = [NSData dataWithBytes:&value length:1];
    
    [self.blunoManager writeDataToDevice:data Device:self.blunoDev];
}


#pragma mark - Connect Device

- (void) connectToDevice:(DFBlunoDevice *)device
{
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

}




@end
