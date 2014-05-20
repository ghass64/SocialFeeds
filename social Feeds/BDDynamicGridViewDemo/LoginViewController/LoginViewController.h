//
//  LoginViewController.h
//  SocialFeeds
//
//  Created by GALMarei on 5/19/14.
//  Copyright (c) 2014 Bluedot. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import "BDViewController.h"

@interface LoginViewController : UIViewController

@property (nonatomic) ACAccountStore *accountStore;
@property (nonatomic) ACAccountStore *facebookAccountStore;
@property (strong, nonatomic) FBRequestConnection *requestConnection;

- (IBAction)facebookLogin:(id)sender;
- (IBAction)twitterLogin:(id)sender;
- (IBAction)instagramLogin:(id)sender;
- (IBAction)nextInvoked:(id)sender;
@end
