//
//  OVStudent.h
//  HomeWork 37-38 MKMap
//
//  Created by Oleh Veheria on 6/15/16.
//  Copyright © 2016 Selfie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MKAnnotation.h>

@interface OVStudent : NSObject

@property (strong, nonatomic) NSString *firstName;
@property (strong, nonatomic) NSString *lastName;
@property (strong, nonatomic) NSDate *dateOfBirth;
@property (assign, nonatomic) BOOL isMale;
@property (assign, nonatomic) CLLocationCoordinate2D coordinate;

+ (OVStudent *)generateRandomStudent;

@end
