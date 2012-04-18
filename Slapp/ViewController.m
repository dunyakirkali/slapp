//
//  ViewController.m
//  Slapp
//
//  Created by dunyakirkali on 4/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "PieView.h"
#import "AstronomicalCalendar.h"
#import "GeoLocation.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize pie, workPie, schedulePie;
@synthesize datePicker, schedulePicker;
@synthesize locationManager, locationMeasurements, bestEffortAtLocation;
@synthesize descriptionLabel;
@synthesize stateString;
@synthesize schedules;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    self.locationMeasurements = [NSMutableArray array];
    self.schedules = [NSMutableArray array];
    [schedules addObject:@"Everyman"];
    [schedules addObject:@"Monophasic"];
    
    [self performSelector:@selector(initLocationManager) withObject:nil afterDelay:0.5];    
    
    [self updateWorkPie];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    

}

#pragma mark Location Manager Interactions 

- (void) initLocationManager {
    
    CLLocationManager *newLocationManager = [[CLLocationManager alloc] init];
    self.locationManager = newLocationManager;
    [newLocationManager release];
    
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        
    [locationManager startUpdatingLocation];
    bestEffortAtLocation = nil;
    [self performSelector:@selector(stopUpdatingLocation:) withObject:@"Timed Out" afterDelay: 30.];

    self.stateString = NSLocalizedString(@"Updating", @"Updating");
    descriptionLabel.text = stateString;
}

- (void)reset {
    self.bestEffortAtLocation = nil;
    [self.locationMeasurements removeAllObjects];
}


/*
 * We want to get and store a location measurement that meets the desired accuracy. For this example, we are
 *      going to use horizontal accuracy as the deciding factor. In other cases, you may wish to use vertical
 *      accuracy, or both together.
 */
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    // store all of the measurements, just so we can see what kind of data we might receive
    [locationMeasurements addObject:newLocation];
    // test the age of the location measurement to determine if the measurement is cached
    // in most cases you will not want to rely on cached measurements
    NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
    if (locationAge > 5.0) return;
    // test that the horizontal accuracy does not indicate an invalid measurement
    if (newLocation.horizontalAccuracy < 0) return;
    // test the measurement to see if it is more accurate than the previous measurement
    if (bestEffortAtLocation == nil || bestEffortAtLocation.horizontalAccuracy > newLocation.horizontalAccuracy) {
        // store the location as the "best effort"
        self.bestEffortAtLocation = newLocation;
        // test the measurement to see if it meets the desired accuracy
        //
        // IMPORTANT!!! kCLLocationAccuracyBest should not be used for comparison with location coordinate or altitidue 
        // accuracy because it is a negative value. Instead, compare against some predetermined "real" measure of 
        // acceptable accuracy, or depend on the timeout to stop updating. This sample depends on the timeout.
        //
        if (newLocation.horizontalAccuracy <= locationManager.desiredAccuracy) {
            // we have a measurement that meets our requirements, so we can stop updating the location
            // 
            // IMPORTANT!!! Minimize power usage by stopping the location manager as soon as possible.
            //
            NSLog(@"GOT IT!");
            [self stopUpdatingLocation:NSLocalizedString(@"Acquired Location", @"Acquired Location")];
            // we can also cancel our previous performSelector:withObject:afterDelay: - it's no longer necessary
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopUpdatingLocation:) object:nil];    

        }
    }
    // Update texts and pie
    if (bestEffortAtLocation.horizontalAccuracy < 0) {
        descriptionLabel.text =  NSLocalizedString(@"DataUnavailable", @"DataUnavailable");
    }
    NSString *latString = (bestEffortAtLocation.coordinate.latitude < 0) ? NSLocalizedString(@"South", @"South") : NSLocalizedString(@"North", @"North");
    NSString *lonString = (bestEffortAtLocation.coordinate.longitude < 0) ? NSLocalizedString(@"West", @"West") : NSLocalizedString(@"East", @"East");
    descriptionLabel.text = [NSString stringWithFormat:NSLocalizedString(@"LatLongFormat", @"LatLongFormat"), fabs(bestEffortAtLocation.coordinate.latitude), latString, fabs(bestEffortAtLocation.coordinate.longitude), lonString];
    
    [self updateDate: nil];

}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    // The location "unknown" error simply means the manager is currently unable to get the location.
    // We can ignore this error for the scenario of getting a single location fix, because we already have a 
    // timeout that will stop the location manager to save power.
    if ([error code] != kCLErrorLocationUnknown) {
        [self stopUpdatingLocation:NSLocalizedString(@"Error", @"Error")];
    }
}

- (void)stopUpdatingLocation:(NSString *)state {

    self.stateString = state;
    descriptionLabel.text = stateString;
    [locationManager stopUpdatingLocation];
    
    locationManager.delegate = nil;
    
    [self updateDate: nil];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void) viewDidDisappear:(BOOL)animated {
    [self reset];
}

#pragma mark -
#pragma mark Actions

-(IBAction) updateDate:(id) sender {

    // Get sunrise sunset
    
    NSLog(@"%f %f %f", bestEffortAtLocation.coordinate.latitude , bestEffortAtLocation.coordinate.longitude, bestEffortAtLocation.altitude);
    

    GeoLocation *AGeoLocation = [ [GeoLocation alloc] initWithName:@"Location" 
                                                       andLatitude: bestEffortAtLocation.coordinate.latitude 
                                                      andLongitude:bestEffortAtLocation.coordinate.longitude 
                                                      andElevation:bestEffortAtLocation.altitude
                                                       andTimeZone:[NSTimeZone systemTimeZone] ];
    
    AstronomicalCalendar *astronomicalCalendar = [ [AstronomicalCalendar alloc] initWithLocation:AGeoLocation];
    
    NSDate *pickerDate = [datePicker date];
    
    astronomicalCalendar.workingDate = pickerDate;
    NSDate *sunrise = [astronomicalCalendar sunrise];
    NSDate *sunset = [astronomicalCalendar sunset];
    
    // TODO clean up
    // Get midnight of that day
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    
    NSDateComponents *components = [gregorian components:unitFlags fromDate:pickerDate];
    components.hour = 0;
    components.minute = 0;
    
    NSDate *pickerDateMidnight = [gregorian dateFromComponents:components];
    
    [gregorian release];

    
    double diff = (sunset.timeIntervalSince1970 - sunrise.timeIntervalSince1970);
    double dayPerc = 1.0 - (diff / kSecondsInADay);
    double dayShift = (sunset.timeIntervalSince1970 - pickerDateMidnight.timeIntervalSince1970) / kSecondsInADay;  
    
    [pie setShift:dayShift andPercentage:dayPerc animated:YES];
}

- (void) updateWorkPie {
        
    // Get 09 o'clock that day
    
    [workPie setShift: (9 / 24.) andPercentage: (8 / 24.) animated:YES];
}

#pragma mark -
#pragma mark Schedule Picker

//PickerViewController.m
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
    
    return 1;
}


- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
    
    return [schedules count];
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [schedules objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    NSString *urlAddress = [[NSBundle mainBundle] pathForResource:[schedules objectAtIndex:row] ofType:@"svg"];
    
    NSLog(@"urlAddress %@", urlAddress);
    //Create a URL object.
    NSURL *url = [NSURL URLWithString:urlAddress];
    
    //URL Requst Object
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    
    //Load the request in the UIWebView.
    [schedulePie loadRequest:requestObj];
}

#pragma mark -
#pragma mark Rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}


- (void) dealloc {
    [schedulePicker release];
    [schedulePie release];
    [workPie release];
    [stateString release];
    [locationMeasurements release];
    [bestEffortAtLocation release];
    [descriptionLabel release];
    [locationManager release];
    [datePicker release];
    [pie release];
    [super dealloc];
}

@end
