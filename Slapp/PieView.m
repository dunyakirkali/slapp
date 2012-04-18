//
//  PieView.m
//  Slapp
//
//  Created by dunyakirkali on 4/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PieView.h"

//  CALayer part

@implementation PieLayer

@dynamic percentage;
@dynamic shift;

+ (BOOL) needsDisplayForKey:(NSString *)key {
    return [key isEqualToString:@"percentage"] || [key isEqualToString:@"shift"] || [super needsDisplayForKey:key];
}

- (id) actionForKey:(NSString *) key {
    if([key isEqualToString:@"percentage"] || [key isEqualToString:@"shift"]) {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:key];
        animation.fromValue = [self.presentationLayer valueForKey:key];
        return animation;
    }
    
    return [super actionForKey:key];
}

//- (id) action
- (void) drawInContext:(CGContextRef)ctx {
    
    // Prepare Draw
    CGRect circleRect = self.bounds;
    CGFloat radius = CGRectGetMidX(circleRect);
    CGPoint center = CGPointMake(radius, CGRectGetMidY(circleRect));
    CGFloat startAngle = self.shift * 2 * M_PI;
    CGFloat endAngle = self.percentage * 2 * M_PI + startAngle;
    
    // Draw Night
    CGContextSetFillColorWithColor(ctx, self.borderColor);
    CGContextMoveToPoint(ctx, center.x, center.y);
    CGContextAddArc(ctx, center.x, center.y, radius, startAngle, endAngle, 0);
    CGContextClosePath(ctx);
    CGContextFillPath(ctx); 
    
    [super drawInContext:ctx];
}


@end

//  UIVIew part

@implementation PieView

@synthesize percentage;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        NSLog(@"PieView init");
        
        // Init Layer
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
        self.layer.cornerRadius = CGRectGetMidX(self.bounds);
        self.layer.borderColor = [[self getRandomColor] CGColor];
        self.layer.borderWidth = 2.0f;
        self.layer.backgroundColor = [[UIColor clearColor] CGColor];
        
    }
    return self;
}

// TODO move to Constants.h
- (UIColor *) getRandomColor {
	
	return [UIColor colorWithRed:((rand() % 255) / 255.) 
                           green:((rand() % 100) / 255.) + 0.5
                            blue:((rand() % 100) / 255.) + 0.5 
                           alpha:((rand() % 100) / 255.) + 0.5];
}

#pragma mark -
#pragma mark Perc Set/Get

// Percentage
- (void) setPercentage:(CGFloat)newPerc {
    [self setShift:self.shift andPercentage:newPerc animated:NO];
}

- (CGFloat) percentage {
    return [(PieLayer *)self.layer percentage];
}

// Shift
- (void) setShift:(CGFloat)newShift {
    [self setShift:newShift andPercentage:self.percentage animated:NO];
}

- (CGFloat) shift {
    return [(PieLayer *)self.layer shift];
}

- (void) setShift: (CGFloat) newShift andPercentage: (CGFloat) newPercentage animated: (BOOL) animated {
    
    NSTimeInterval length = animated ? (6.) : 0.;

    [UIView animateWithDuration:length delay:0. options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        
        [(PieLayer *) self.layer setShift: newShift];
        [(PieLayer *) self.layer setPercentage: newPercentage];
        
    }completion:^(BOOL finished) {

    }];
}


+ (Class) layerClass {
    return [PieLayer class];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
//- (void)drawRect:(CGRect)rect
//{
//    
//}


@end
