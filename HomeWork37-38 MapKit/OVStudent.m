//
//  OVStudent.m
//  HomeWork 37-38 MKMap
//
//  Created by Oleh Veheria on 6/15/16.
//  Copyright © 2016 Selfie. All rights reserved.
//

#import "OVStudent.h"

@implementation OVStudent

+ (NSString *)generateRandomString {
    
    int length = arc4random_uniform(5) + 5;
    NSString *letters = @"abcdefghijklmnopqrstuvwxyz";
    NSMutableString *randomString = [NSMutableString stringWithCapacity:length];
    
    for (int i = 0; i < length; i++) {
        [randomString appendFormat:@"%C", [letters characterAtIndex:arc4random() % [letters length]]];
    }
    
    return [randomString capitalizedString];
}

+ (NSDate *)generateRandomDateOfBirth {
    
    int years = arc4random_uniform(32) + 18;
    int months = arc4random_uniform(12) + 1;
    int days = arc4random_uniform(30) + 1;
    
    NSDate *today = [NSDate new];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSDateComponents *offsetComponents = [NSDateComponents new];
    [offsetComponents setYear:(years * (-1))];
    [offsetComponents setMonth:(months * (-1))];
    [offsetComponents setDay:(days * (-1))];
    
    NSDate *randomDate = [gregorian dateByAddingComponents:offsetComponents
                                                    toDate:today options:0];
    
    return randomDate;
}

+ (CLLocationCoordinate2D)generateRandomCoordinate {
    
    CLLocationCoordinate2D myCoordinate = CLLocationCoordinate2DMake(47.09514, 37.54131);
    CLCircularRegion *myRegion = [[CLCircularRegion alloc] initWithCenter:myCoordinate radius:138000 identifier:@"Region"];
    CLLocationCoordinate2D randomCoordinate = {0,0};
    
    do {
        double latitude = ((double)(arc4random() % 201 / 400.0) + myCoordinate.latitude);
        double longitude = ((double)(arc4random() % 201 / 200.0) - 0.5f + myCoordinate.longitude);
        randomCoordinate = CLLocationCoordinate2DMake(latitude, longitude);
        
    } while (!CLLocationCoordinate2DIsValid(randomCoordinate) && ![myRegion containsCoordinate:randomCoordinate]);
    
    return randomCoordinate;
}

+ (OVStudent *)generateRandomStudent {
    
    OVStudent *student = [[OVStudent alloc] init];
    student.firstName = [self generateRandomString];
    student.lastName = [self generateRandomString];
    student.dateOfBirth = [self generateRandomDateOfBirth];
    student.isMale = arc4random() % 2;
    student.coordinate = [self generateRandomCoordinate];
    
    return student;
}

@end
