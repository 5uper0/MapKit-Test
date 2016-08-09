//
//  ViewController.m
//  HomeWork 37-38 MKMap
//
//  Created by Oleh Veheria on 6/15/16.
//  Copyright © 2016 Selfie. All rights reserved.
//

#import "ViewController.h"
#import "OVStudent.h"
#import "OVMapAnnotation.h"
#import "UIView+MKAnnotationView.h"
#import "OVCircle.h"

#import <MapKit/MapKit.h>

@interface ViewController () <MKMapViewDelegate, UIPopoverPresentationControllerDelegate, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) NSArray *studentsArray;
@property (strong, nonatomic) OVStudent *currentStudent;
@property (strong, nonatomic) CLGeocoder *geoCoder;
@property (strong, nonatomic) NSString *address;
@property (strong, nonatomic) MKCircle *circleOverlay;
@property (strong, nonatomic) MKCircleRenderer *circleRenderer;
@property (strong, nonatomic) MKDirections *directions;
@property (assign, nonatomic) CLLocationCoordinate2D meetCoordinate;
@property (strong, nonatomic) NSArray *circlesArray;

@end

typedef enum : NSUInteger {
    OVCircleNameRed,
    OVCircleNameOrange,
    OVCircleNameGreen
    
} OVCircleName;

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    UIBarButtonItem *zoomButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch
                                                                          target:self
                                                                          action:@selector(actionZoom:)];
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                   target:self
                                                                                   action:nil];
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                target:self
                                                                                action:@selector(actionAdd:)];
    
    self.navigationItem.rightBarButtonItems = @[flexibleSpace, addButton, zoomButton];
    
    [self studentsArrayInitWithCoordinates];
    self.geoCoder = [[CLGeocoder alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    if ([self.geoCoder isGeocoding]) {
        [self.geoCoder cancelGeocode];
    }
    if ([self.directions isCalculating]) {
        [self.directions cancel];
    }
}

#pragma mark - Private Methods

- (void)addOverlaysWithMeetAnnotation:(OVMapAnnotation *)meetAnnotation {
    
    NSString *title = @"Meeting Point";
    self.meetCoordinate = meetAnnotation.coordinate;
    
    CLLocationDistance redRadius = 15000.0;
    CLLocationDistance orangeRadius = 10000.0;
    CLLocationDistance greenRadius = 5000.0;
    
    MKCircle *redCircleOverlay = [MKCircle circleWithCenterCoordinate:meetAnnotation.coordinate radius:redRadius];
    MKCircle *orangeCircleOverlay = [MKCircle circleWithCenterCoordinate:meetAnnotation.coordinate radius:orangeRadius];
    MKCircle *greenCircleOverlay = [MKCircle circleWithCenterCoordinate:meetAnnotation.coordinate radius:greenRadius];
    
    for (id <MKOverlay>overlay in self.mapView.overlays) {
        [self.mapView removeOverlay:overlay];
    }
    
    [redCircleOverlay setTitle:@"redCircleOverlay"];
    [orangeCircleOverlay setTitle:@"orangeCircleOverlay"];
    [greenCircleOverlay setTitle:@"greenCircleOverlay"];
    
    [self.mapView addOverlays:@[greenCircleOverlay, orangeCircleOverlay, redCircleOverlay] level:MKOverlayLevelAboveRoads];
    
    OVCircle *redCircleArray = [[OVCircle alloc] init];
    OVCircle *orangeCircleArray = [[OVCircle alloc] init];
    OVCircle *greenCircleArray = [[OVCircle alloc] init];
    
    redCircleArray.name = @"Red Circle";
    orangeCircleArray.name = @"Orange Circle";
    greenCircleArray.name = @"Green Circle";
    
    redCircleArray.itemsArray = [NSMutableArray array];
    orangeCircleArray.itemsArray = [NSMutableArray array];
    greenCircleArray.itemsArray = [NSMutableArray array];
    
    NSUInteger checkCounter = 0;
    
    for (OVMapAnnotation *annotation in self.mapView.annotations) {
        
        MKMapPoint meetPoint = MKMapPointForCoordinate(meetAnnotation.coordinate);
        MKMapPoint peoplePoint = MKMapPointForCoordinate(annotation.coordinate);
        
        annotation.distance = MKMetersBetweenMapPoints(meetPoint, peoplePoint);
        
        if ([annotation.title isEqualToString:title] || annotation.distance > redRadius) {
            checkCounter++;
            continue;
        }
        
        if (annotation.distance <= redRadius && annotation.distance > orangeRadius) {
            [redCircleArray.itemsArray addObject:annotation];
            
        } else if (annotation.distance <= orangeRadius && annotation.distance > greenRadius) {
            [orangeCircleArray.itemsArray addObject:annotation];
            
        } else if (annotation.distance <= greenRadius) {
            [greenCircleArray.itemsArray addObject:annotation];
           
        } else {
            checkCounter++;
        }
    }
    
    if (checkCounter == [self.mapView.annotations count]) {
        [self showAlertWithTitle:@"No Friends Found" andMessage:@"Try Again"];
        
    } else {
        
        self.circlesArray = @[redCircleArray, orangeCircleArray, greenCircleArray];
        [self showFriendsDistancePopup];

    }
}

- (void)addAnnotationWithTitle:(NSString *)title
                      subtitle:(NSString *)subtitle
                    coordinate:(CLLocationCoordinate2D)coordinate andStudents:(OVStudent *)student {
    
    OVMapAnnotation *annotation = [[OVMapAnnotation alloc] init];
    
    annotation.title = title;
    annotation.subtitle = subtitle;
    annotation.coordinate = coordinate;
    annotation.student = student;
    
    [self.mapView addAnnotation:annotation];
    
    if (!student) {
        [self addOverlaysWithMeetAnnotation:annotation];
    }
}

- (void)showAlertWithTitle:(NSString *)title andMessage:(NSString *)message {
    
    UIAlertController* alert =
    [UIAlertController alertControllerWithTitle:title
                                        message:message
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction =
    [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * action) {}];
    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showFriendsDistancePopup {
    
    NSUInteger tableLength = 0;
    
    for (OVCircle *array in self.circlesArray) {
        if ([array.itemsArray count] > 0) {
            tableLength += [array.itemsArray count] * 44 + 28;
        }
    }
    
    UITableViewController *tableController = [[UITableViewController alloc] init];
    tableController.preferredContentSize = CGSizeMake(300, tableLength);
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:tableController];
    navController.modalPresentationStyle = UIModalPresentationPopover;
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:tableController.view.frame style:UITableViewStylePlain];
    
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    tableView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    tableView.alpha = 1.f;
    
    tableController.tableView = tableView;
    tableController.navigationItem.title = @"Meeting People";
    
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                target:self
                                                                                action:@selector(actionCloseInfo:)];
    backButton.style = UIBarButtonItemStylePlain;
    tableController.navigationItem.rightBarButtonItem = backButton;
    
    UIBarButtonItem *directionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                     target:self
                                                                                     action:@selector(actionDirection:)];
    backButton.style = UIBarButtonItemStylePlain;
    tableController.navigationItem.leftBarButtonItem = directionButton;
    
    [self presentViewController:navController animated:YES completion:nil];
    
    UIPopoverPresentationController *popController = [navController popoverPresentationController];
    popController.permittedArrowDirections = UIPopoverArrowDirectionDown;
    popController.canOverlapSourceViewRect = YES;
    popController.delegate = self;
    
    popController.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    
    popController.sourceView = self.mapView;
}

- (BOOL)randomBoolWithYesPercentage:(NSUInteger)percentage {
    return arc4random_uniform(100) < percentage;
}

- (void)studentsArrayInitWithCoordinates {
    
    NSMutableArray *students = [NSMutableArray array];
    NSUInteger studentsCount = 30;
    
    for (int i = 0; i < studentsCount; i++) {
        
        OVStudent *student = [OVStudent generateRandomStudent];
        
        [students addObject:student];
        
        
        NSString *title = [NSString stringWithFormat:@"%@ %@", student.firstName, student.lastName];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"dd/MM/yyyy"];
        NSString *subtitle = [dateFormatter stringFromDate:student.dateOfBirth];
   
        [self addAnnotationWithTitle:title subtitle:subtitle coordinate:student.coordinate andStudents:student];
    }
    
    self.studentsArray = [NSArray arrayWithArray:students];
}

#pragma mark - Actions

- (void)actionAdd:(UIBarButtonItem *)sender {
    
    NSString *title = @"Meeting Point";
    NSString *subtitle = @"Let's go for a walk!";
    CLLocationCoordinate2D coordinate = self.mapView.region.center;
    
    [self addAnnotationWithTitle:title subtitle:subtitle coordinate:coordinate andStudents:nil];
}

- (void)actionDirection:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if ([self.directions isCalculating]) {
        [self.directions cancel];
    }
    
    for (MKOverlayRenderer *overlay in self.mapView.overlays) {
        if ([overlay isKindOfClass:[MKPolyline class]]) {
            id <MKOverlay> idOverlay = overlay.overlay;
            [self.mapView removeOverlay:idOverlay];
        }
    }
    
    for (OVCircle *circle in self.circlesArray) {
        BOOL isGoing = NO;
        
        for (OVMapAnnotation *annotation in circle.itemsArray) {
            
            if ([circle.name isEqualToString:@"Red Circle"]) {
                isGoing = [self randomBoolWithYesPercentage:10];
                
            } else if ([circle.name isEqualToString:@"Orange Circle"]) {
                isGoing = [self randomBoolWithYesPercentage:50];
                
            } else if ([circle.name isEqualToString:@"Green Circle"]) {
                isGoing = [self randomBoolWithYesPercentage:90];
            }
            
            NSLog(@"isGoing = %@", isGoing ? @"YES" : @"NO");
            
            if (isGoing) {
                MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
                
                MKPlacemark *sourcePlacemark = [[MKPlacemark alloc] initWithCoordinate:annotation.coordinate
                                                                     addressDictionary:nil];
                MKMapItem *sourceMapItem = [[MKMapItem alloc] initWithPlacemark:sourcePlacemark];
                
                MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:self.meetCoordinate
                                                               addressDictionary:nil];
                MKMapItem *destinationMapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
               
                request.source = sourceMapItem;
                request.destination = destinationMapItem;
                request.transportType = MKDirectionsTransportTypeAny;
                request.requestsAlternateRoutes = NO;
                
                self.directions = [[MKDirections alloc] initWithRequest:request];
                
                [self.directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse * _Nullable response, NSError * _Nullable error) {
                    if (error) {
                        [self showAlertWithTitle:@"Directions Error" andMessage:[error localizedDescription]];
                        
                    } else if ([response.routes count] == 0) {
                        [self showAlertWithTitle:@"Directions Error" andMessage:@"No routes found"];
                        
                    } else {
                        
                        NSMutableArray *array = [NSMutableArray array];
                        
                        for (MKRoute *route in response.routes) {
                            [array addObject:route.polyline];
                        }
                        
                        [self.mapView addOverlays:array level:MKOverlayLevelAboveRoads];
                    }
                }];
            }
        }
    }
}

- (void)actionCloseInfo:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)actionInfo:(UIButton *)sender {

    UITableViewController *tableController = [[UITableViewController alloc] init];
    
    tableController.preferredContentSize = CGSizeMake(250, 4 * 44);
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:tableController];
    navController.modalPresentationStyle = UIModalPresentationPopover;
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:tableController.view.frame style:UITableViewStyleGrouped];
    
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    tableController.tableView = tableView;
    tableController.navigationItem.title = @"User Info";
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                target:self
                                                                                action:@selector(actionCloseInfo:)];
    backButton.style = UIBarButtonItemStylePlain;
    tableController.navigationItem.rightBarButtonItem = backButton;
    
    [self presentViewController:navController animated:YES completion:nil];
    
    UIPopoverPresentationController *popController = [navController popoverPresentationController];
    popController.permittedArrowDirections = UIPopoverArrowDirectionUp | UIPopoverArrowDirectionDown;
    popController.canOverlapSourceViewRect = NO;
    popController.delegate = self;
    
    popController.sourceView = [sender superview];
    
    MKAnnotationView *annotationView = [sender superAnnotationView];
    
    if (!annotationView) {
        return;
    }
    
    OVMapAnnotation *mapAnnotation = annotationView.annotation;
    OVStudent *student = mapAnnotation.student;
    
    if ([self.geoCoder isGeocoding]) {
        self.address = nil;
        [self.geoCoder cancelGeocode];
    }
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:student.coordinate.latitude longitude:student.coordinate.longitude];
    
    [self.geoCoder reverseGeocodeLocation:location
                        completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
                            
                            NSString *message = nil;
                            
                            if (error) {
                                NSLog(@"%@", [error localizedDescription]);
                                
                            } else  {
                                
                                if ([placemarks count] > 0) {
                                    CLPlacemark *placemark = [placemarks firstObject];
                                    message = [NSString stringWithFormat:@"%@, %@", placemark.country, placemark.locality];
                                    
                                } else {
                                    message = @"Not Found";
                                }
                            }
                            self.address = message;
                            
                        }];
    
    
    self.currentStudent = student;
}


- (void)actionZoom:(UIBarButtonItem *)sender {
    
    MKMapRect zoomRect = MKMapRectNull;
    
    for (id <MKAnnotation>annotation in self.mapView.annotations) {
        
        CLLocationCoordinate2D coordinate = annotation.coordinate;
        MKMapPoint center = MKMapPointForCoordinate(coordinate);
        
        static double delta = 20000;
        MKMapRect rect = MKMapRectMake(center.x - delta, center.y - delta, delta * 2, delta * 2);
        
        zoomRect = MKMapRectUnion(zoomRect, rect);
    }
    
    zoomRect = [self.mapView mapRectThatFits:zoomRect];
    
    [self.mapView setVisibleMapRect:zoomRect
                        edgePadding:UIEdgeInsetsMake(50, 50, 50, 50)
                           animated:YES];
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if (tableView.style == UITableViewStyleGrouped) {
        return 1;
        
    } else {
        
        NSInteger count = 0;
        
        for (OVCircle *circle in self.circlesArray) {
            count += [circle.itemsArray count] > 0 ? 1 : 0;
        }
        
        return count;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (tableView.style == UITableViewStyleGrouped) {
        return 4;

    } else {
        OVCircle *circle = [self.circlesArray objectAtIndex:section];
        return [circle.itemsArray count];
        
    }
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if (tableView.style == UITableViewStyleGrouped) {
        return nil;
        
    } else {
        OVCircle *circle = [self.circlesArray objectAtIndex:section];
        return circle.name;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = nil;
    
    if (tableView.style == UITableViewStyleGrouped) {
        
        static NSString *identifier = @"infoCell";
        
        cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        }
        
        OVStudent *student = self.currentStudent;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        NSString *text = nil;
        NSString *detailText = nil;
        
        if (indexPath.row == 0) {
            text = [NSString stringWithFormat:@"%@ %@", student.firstName, student.lastName];
            detailText = @"Name";
            
        } else if (indexPath.row == 1) {
            [dateFormatter setDateFormat:@"dd/MM/yyyy"];
            text = [dateFormatter stringFromDate:student.dateOfBirth];
            detailText = @"Date Of Birth";
            
        } else if (indexPath.row == 2) {
            text = student.isMale ? @"Male" : @"Female";
            detailText = @"Gender";
            
        } else if (indexPath.row == 3) {
            detailText = @"Address";
            
            if (self.address) {
                text = self.address;
                
            } else {
                text = @"NIL";
            }
        }
        
        cell.textLabel.text = text;
        cell.detailTextLabel.text = detailText;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    } else {
        
        static NSString *identifier = @"circlesCell";
        
        cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        }
        
        OVCircle *circle = [self.circlesArray objectAtIndex:indexPath.section];
        OVMapAnnotation *annotation = [circle.itemsArray objectAtIndex:indexPath.row];
        OVStudent *student = annotation.student;
        
        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", student.firstName, student.lastName];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f m", annotation.distance];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return cell;
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState {
    
    if (newState == MKAnnotationViewDragStateEnding) {
        OVMapAnnotation *annotation = view.annotation;
        [self addOverlaysWithMeetAnnotation:annotation];
    }
}

- (nullable MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return  nil;
    }
    
    OVStudent *student = ((OVMapAnnotation *)annotation).student;
    MKAnnotationView *aView = [[MKAnnotationView alloc] init];
    
    if (student) {
        
        static NSString *identifier = @"Annotation";
        
        aView = [mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        
        if (!aView) {
            aView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            
            if (student.isMale) {
                aView.image = [UIImage imageNamed:@"Untitled1.png"];
                
            } else {
                aView.image = [UIImage imageNamed:@"Untitled4.png"];
            }
            
            aView.frame = CGRectMake(0, 0, 40, 50);
            aView.canShowCallout = YES;
            aView.draggable = NO;
            
            UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
            [infoButton addTarget:self action:@selector(actionInfo:) forControlEvents:UIControlEventTouchUpInside];
            aView.rightCalloutAccessoryView = infoButton;
            
        } else {
            aView.annotation = annotation;
        }
        
    } else {
        
        static NSString *meetIdentifier = @"MeetingPlace";
        
        aView = [mapView dequeueReusableAnnotationViewWithIdentifier:meetIdentifier];
        
        if (!aView) {
            aView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:meetIdentifier];
            
            aView.image = [UIImage imageNamed:@"Untitled5.png"];

            aView.frame = CGRectMake(0, 0, 40, 50);
            aView.canShowCallout = YES;
            aView.draggable = YES;
            
            UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
            [infoButton addTarget:self action:@selector(showFriendsDistancePopup) forControlEvents:UIControlEventTouchUpInside];
            aView.rightCalloutAccessoryView = infoButton;
            
        } else {
            aView.annotation = annotation;
        }
    }
    
    return aView;
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id < MKOverlay >)overlay {
    
    if ([overlay isKindOfClass:[MKCircle class]]) {
        
        MKCircleRenderer *circleR = [[MKCircleRenderer alloc] initWithCircle:(MKCircle *)overlay];

        if ([[overlay title] isEqualToString:@"redCircleOverlay"]) {
            circleR.fillColor = [[UIColor greenColor] colorWithAlphaComponent:0.1];
            
        } else if ([[overlay title] isEqualToString:@"orangeCircleOverlay"]) {
            circleR.fillColor = [[UIColor greenColor] colorWithAlphaComponent:0.3];
            
        } else if ([[overlay title] isEqualToString:@"greenCircleOverlay"]) {
            circleR.fillColor = [[UIColor greenColor] colorWithAlphaComponent:0.6];
            
        }
        
        return circleR;
        
    } else if ([overlay isKindOfClass:[MKPolyline class]]) {
        
        MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
        
        renderer.lineWidth = 2.f;
        renderer.strokeColor = [UIColor colorWithRed:0.f green:0.5f blue:1.f alpha:0.9f];
        
        return renderer;
    }
    
    return nil;
}


@end

/*
 Ученик.
 
 1. Создайте массив из 10 - 30 рандомных студентов, прямо как раньше, только в этот раз пусть у них наряду с именем и фамилией будет еще и координата. Можете использовать структуру координаты, а можете просто два дабла - лонгитюд и латитюд.
 
 2. Координату генерируйте так, установите центр например в вашем городе и просто генерируйте небольшие отрицательные либо положительные числа, чтобы рандомно получалась координата от центра в пределах установленного радиуса.
 
 (Ну а если совсем не получается генерировать координату, то просто ставьте им заготовленные координаты - это не главное)
 
 3. После того, как вы сгенерировали своих студентов, покажите их всех на карте, причем в титуле пусть будет Имя и Фамилия а в сабтитуле год рождения. Можете для каждого студента создать свою аннотацию, а можете студентов подписать на протокол аннотаций и добавить их на карту напрямую - как хотите :)
 
 Студент.
 
 4. Добавьте кнопочку, которая покажет всех студентов на экране.
 
 5. Вместо пинов на карте используйте свои кастомные картинки, причем если студент мужского пола, то картинка должна быть одна, а для девушек другая.
 
 Мастер
 
 6. У каждого колаута (этого облачка над пином) сделайте кнопочку информации справа так, что когда я на нее нажимаю вылазит поповер, в котором в виде статической таблицы находится имя и фамилия студента, год рождения, пол и самое главное адрес.
 
 7. В случае если это телефон, то вместо поповера контроллер должен вылазить модально.
 
 Супермен
 
 8. Создайте аннотацию для места встречи и показывайте его на карте новымой соответствующей картинкой
 
 9. Место встречи можно перемещать по карте, а студентов нет
 
 10. Когда место встречи бросается на карту, то вокруг него надо рисовать 3 круга, с радиусами 5 км, 10 км и 15 км (используйте оверлеи)
 
 11. На какой-то полупрозрачной вьюхе в одном из углов вам надо показать сколько студентов попадают в какой круг. Суть такая, чем дальше студент живет, тем меньше вероятность что он придет на встречу. Расстояние от студента до места встречи рассчитывайте используя функцию для расчета расстояния между точками, поищите ее в фреймворке :)
 
 12. Сделайте на навигейшине кнопочку, по нажатию на которую, от рандомных студентов до нее будут проложены маршруты (типо студенты идут на сходку), притом вероятности генератора разные, зависит от круга, в котором они находятся, если он близко, то 90%, а если далеко - то 10%
 
 Сложно, но, надеюсь, интересно :)
 */
