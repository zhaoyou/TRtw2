//
//  AppDelegate.h
//  TRtw2
//
//  Created by zhaoyou on 2/28/15.
//  Copyright (c) 2015 zhaoyou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Accounts/ACAccount.h"
#import "Accounts/ACAccountStore.h"

#

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) ACAccountStore *accountStore;
@property (strong, nonatomic) NSMutableDictionary *profileImages;
@property (strong, nonatomic) ACAccount *userAccount;

@end

