//
//  MyView.m
//  Attribute
//
//  Created by Doublenian on 15/2/3.
//  Copyright (c) 2015年 com.doublenian. All rights reserved.
//

#import "MyView.h"

@implementation MyView

- (void)setup
{
    self.backgroundColor = [UIColor clearColor];

}

- (void)awakeFromNib
{

    [self setup];

}

- (void) drawRect:(CGRect)rect
{
    
        NSLog(@"draw is coming");
    
        UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0,self.bounds.size.width,self.bounds.size.height)];
    
        [[UIColor greenColor] setFill];
    
        [path fill];
    
        [path addClip];
    
    
       
}

@end
