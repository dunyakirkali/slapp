//
//  PieView.h
//  Slapp
//
//  Created by dunyakirkali on 4/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

@interface PieLayer : CALayer

@property (nonatomic) CGFloat percentage;
@property (nonatomic) CGFloat shift;

@end

@interface PieView : UIView {
    CGFloat percentage;
    CGFloat shift;
}

@property (nonatomic)           CGFloat         percentage;
@property (nonatomic)           CGFloat         shift;

- (void) setShift: (CGFloat) newShift andPercentage: (CGFloat) newPercentag animated: (BOOL) animated;

@end
