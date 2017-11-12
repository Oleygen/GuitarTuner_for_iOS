//
//  AppDelegate.h
//  GuitarTuner
//
//  Created by Gennadii on 11/12/17.
//  Copyright © 2017 Gennady Oleynik. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

