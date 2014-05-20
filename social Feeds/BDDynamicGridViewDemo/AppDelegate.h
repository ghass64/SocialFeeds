

#import <UIKit/UIKit.h>
#import "BDViewController.h"
#import "LoginViewController.h"

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) LoginViewController *viewController;

@property (strong, nonatomic) UINavigationController *navigationController;

@end
