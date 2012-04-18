//
//  ViewController.h
//  Slapp
//
//  Created by dunyakirkali on 4/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@class PieView;

@interface ViewController : UIViewController<CLLocationManagerDelegate> {
    
    PieView             *pie;
    PieView             *workPie;
    UIWebView             *schedulePie;    
    UIDatePicker        *datePicker;
    
    CLLocationManager   *locationManager;
    NSMutableArray      *locationMeasurements;
    CLLocation          *bestEffortAtLocation;
    
    UILabel             *descriptionLabel;
    NSString            *stateString;    

}

@property (nonatomic, retain) NSString                  *stateString;
@property (nonatomic, retain) IBOutlet PieView          *pie;
@property (nonatomic, retain) IBOutlet PieView          *workPie;
@property (nonatomic, retain) IBOutlet UIWebView          *schedulePie;
@property (nonatomic, retain) IBOutlet UIDatePicker     *datePicker;
@property (nonatomic, retain) CLLocationManager         *locationManager;
@property (nonatomic, retain) NSMutableArray            *locationMeasurements;
@property (nonatomic, retain) CLLocation                *bestEffortAtLocation;
@property (nonatomic, retain) IBOutlet UILabel          *descriptionLabel;

-(IBAction) updateDate:(id) sender;
- (void)stopUpdatingLocation:(NSString *)state;

@end
