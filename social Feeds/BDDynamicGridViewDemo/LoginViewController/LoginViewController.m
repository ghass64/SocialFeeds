//
//  LoginViewController.m
//  SocialFeeds
//
//  Created by GALMarei on 5/19/14.
//  Copyright (c) 2014 Bluedot. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()
{
    BOOL fbLogin;
    BOOL twitLogin;
    BOOL instagramLogin;
    
    NSMutableArray* feedsArray;
    
    MRProgressOverlayView *progressView;
    
}
@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _accountStore = [[ACAccountStore alloc] init];
        _facebookAccountStore = [[ACAccountStore alloc] init];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    feedsArray = [NSMutableArray new];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [self hideLoadingMode];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBAction
- (IBAction)facebookLogin:(id)sender {
    [self showLoadingMode];
    [self fetchFacebookTimelineForUser];
}

- (IBAction)twitterLogin:(id)sender {
    [self showLoadingMode];
    [self fetchTimelineForUser:@"Ghassan"];
    
}

- (IBAction)instagramLogin:(id)sender {
    [self showLoadingMode];
    dispatch_queue_t fetchMarketQueue = dispatch_queue_create("Fetch_instagram", NULL);
    dispatch_async(fetchMarketQueue, ^{
        
        [self fetchInstagramTimeline];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self hideLoadingMode];
            
        });
    });
}

- (IBAction)nextInvoked:(id)sender {
    //check if he login to all accounts first
    if (!fbLogin && !twitLogin && !instagramLogin) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Info" message:@"In order to show you all the feeds ,Please Login in all Socail Networks" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    else
    {
        //load the homepage with all feeds
        BDViewController* vc = [[BDViewController alloc] init];
        vc.feedArr = feedsArray;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - Twitter Api
- (BOOL)userHasAccessToTwitter
{
    return [SLComposeViewController
            isAvailableForServiceType:SLServiceTypeTwitter];
}

- (void)fetchTimelineForUser:(NSString *)username
{
    //  Step 0: Check that the user has local Twitter accounts
    if ([self userHasAccessToTwitter]) {
        
        //  Step 1:  Obtain access to the user's Twitter accounts
        ACAccountType *twitterAccountType =
        [self.accountStore accountTypeWithAccountTypeIdentifier:
         ACAccountTypeIdentifierTwitter];
        
        [self.accountStore
         requestAccessToAccountsWithType:twitterAccountType
         options:NULL
         completion:^(BOOL granted, NSError *error) {
             if (granted) {
                 //  Step 2:  Create a request
                 NSArray *twitterAccounts =
                 [self.accountStore accountsWithAccountType:twitterAccountType];
                 NSURL *url = [NSURL URLWithString:@"https://api.twitter.com"
                               @"/1.1/statuses/user_timeline.json"];
                 SLRequest *request =
                 [SLRequest requestForServiceType:SLServiceTypeTwitter
                                    requestMethod:SLRequestMethodGET
                                              URL:url
                                       parameters:nil];
                 
                 //  Attach an account to the request
                 [request setAccount:[twitterAccounts lastObject]];
                 
                 //  Step 3:  Execute the request
                 [request performRequestWithHandler:
                  ^(NSData *responseData,
                    NSHTTPURLResponse *urlResponse,
                    NSError *error) {
                      
                      if (responseData) {
                          if (urlResponse.statusCode >= 200 &&
                              urlResponse.statusCode < 300) {
                              
                              NSError *jsonError;
                              NSDictionary *timelineData =
                              [NSJSONSerialization
                               JSONObjectWithData:responseData
                               options:NSJSONReadingAllowFragments error:&jsonError];
                              if (timelineData) {
                                  NSLog(@"Timeline Response: %@\n", timelineData);
                                  [self hideLoadingMode];
                                  
                                  //get the feeds [text , image , type]
                                  for (NSDictionary* userData in timelineData) {
                                      NSMutableDictionary* dict = [NSMutableDictionary new];
                                      dict[@"text"] = userData[@"text"];
                                      dict[@"imageURL"] = userData[@"user"][@"profile_image_url"];
                                      dict[@"type"] = @"twitter";
                                      [feedsArray addObject:dict];
                                  }
                                  fbLogin = YES;
                                  twitLogin = YES;
                                  instagramLogin = YES;
                              }
                              else {
                                  [self hideLoadingMode];
                                  // Our JSON deserialization went awry
                                  NSLog(@"JSON Error: %@", [jsonError localizedDescription]);
                              }
                          }
                          else {
                              [self hideLoadingMode];
                              // The server did not respond ... were we rate-limited?
                              NSLog(@"The response status code is %d",
                                    urlResponse.statusCode);
                          }
                      }
                      else
                          [self hideLoadingMode];
                  }];
                 [self hideLoadingMode];
             }
             else {
                 [self hideLoadingMode];
                 // Access was not granted, or an error occurred
                 NSLog(@"%@", [error localizedDescription]);
             }
         }];
    }
    else
    {
        [self hideLoadingMode];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Please login to your twitter account in setting"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

#pragma mark - facebook Api

- (void)fetchFacebookTimelineForUser
{
    
    if (FBSession.activeSession.isOpen) {
        // login is integrated with the send button -- so if open, we send
        [self sendRequests];
    } else {
        NSArray *permissions = @[@"public_profile", @"email"];
        [FBSession openActiveSessionWithReadPermissions:permissions
                                           allowLoginUI:YES
                                      completionHandler:^(FBSession *session,
                                                          FBSessionState status,
                                                          NSError *error) {
                                          
                                          
                                          // if login fails for any reason, we alert
                                          if (error) {
                                              [self hideLoadingMode];
                                              UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                                              message:error.localizedDescription
                                                                                             delegate:nil
                                                                                    cancelButtonTitle:@"OK"
                                                                                    otherButtonTitles:nil];
                                              [alert show];
                                              // if otherwise we check to see if the session is open, an alternative to
                                              // to the FB_ISSESSIONOPENWITHSTATE helper-macro would be to check the isOpen
                                              // property of the session object; the macros are useful, however, for more
                                              // detailed state checking for FBSession objects
                                          } else if (FB_ISSESSIONOPENWITHSTATE(status)) {
                                              // send our requests if we successfully logged in
                                              [self sendRequests];
                                          }
                                      }];
    }
}

- (void)sendRequests {
    // create the connection object
    FBRequestConnection *newConnection = [[FBRequestConnection alloc] init];
    
    // for each fbid in the array, we create a request object to fetch
    // the profile, along with a handler to respond to the results of the request
    
    // create a handler block to handle the results of the request for fbid's profile
    FBRequestHandler handler =
    ^(FBRequestConnection *connection, id result, NSError *error) {
        // output the results of the request
        [self requestCompleted:connection result:result error:error];
    };
    
    // create the request object, using the fbid as the graph path
    // as an alternative the request* static methods of the FBRequest class could
    // be used to fetch common requests, such as /me and /me/friends
    NSMutableDictionary* mutDict = [NSMutableDictionary new];
    mutDict[@"limit"] = @"100";
    FBRequest *request = [[FBRequest alloc] initWithSession:FBSession.activeSession
                                                  graphPath:@"me/posts" parameters:mutDict HTTPMethod:@"GET"];
    
    // add the request to the connection object, if more than one request is added
    // the connection object will compose the requests as a batch request; whether or
    // not the request is a batch or a singleton, the handler behavior is the same,
    // allowing the application to be dynamic in regards to whether a single or multiple
    // requests are occuring
    [newConnection addRequest:request completionHandler:handler];
    
    
    // if there's an outstanding connection, just cancel
    [self.requestConnection cancel];
    
    // keep track of our connection, and start it
    self.requestConnection = newConnection;
    [newConnection start];
}

// FBSample logic
// Report any results.  Invoked once for each request we make.
- (void)requestCompleted:(FBRequestConnection *)connection
                  result:(id)result
                   error:(NSError *)error {
    // not the completion we were looking for...
    if (self.requestConnection &&
        connection != self.requestConnection) {
        [self hideLoadingMode];
        return;
    }
    
    // clean this up, for posterity
    self.requestConnection = nil;
    
    NSString *text;
    if (error) {
        [self hideLoadingMode];
        // error contains details about why the request failed
        text = error.localizedDescription;
    } else {
        [self hideLoadingMode];
        // result is the json response from a successful request
        //get the feeds data [story , type]
        NSDictionary *dictionary = (NSDictionary *)result;
        NSArray* dataarr = dictionary[@"data"];
        for (NSDictionary* storyData in dataarr) {
            NSMutableDictionary* dict = [NSMutableDictionary new];
            dict[@"text"] = storyData[@"story"];
            dict[@"imageURL"] = @"";
            dict[@"type"] = @"facebook";
            [feedsArray addObject:dict];
        }
        fbLogin = YES;
        twitLogin = YES;
        instagramLogin = YES;
        
    }
    
}



#pragma mark - Instagram Api
- (void)fetchInstagramTimeline {
    NSData *data = [[NSData alloc] init];
    data = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"https://api.instagram.com/v1/media/popular?access_token=210816447.f59def8.5b15d86f44ce4dbf94a2b84d7026c721&count=10"]];
    NSError *localError = nil;
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
    
    if (localError != nil) {
        NSLog(@"%@", [localError userInfo]);
    }
    
    NSArray* v = (NSArray *)parsedObject[@"data"];
    for (NSDictionary *d in v) {
        NSMutableDictionary* dict = [NSMutableDictionary new];
        if (d[@"caption"]) {
            dict[@"text"] = d[@"caption"][@"text"];
            NSString* url = d[@"caption"][@"from"][@"profile_picture"];
            dict[@"imageURL"] = [url stringByReplacingOccurrencesOfString:@"\\" withString:@""];
            dict[@"type"] = @"instagram";
            [feedsArray addObject:dict];
        }
        fbLogin = YES;
        twitLogin = YES;
        instagramLogin = YES;
        
    }
}

#pragma mark - loader animating
-(void)showLoadingMode {
    progressView = [MRProgressOverlayView new];
    progressView.titleLabelText = @"Loading...";
    progressView.tintColor = [UIColor whiteColor];
    [self.view addSubview:progressView];
    [progressView show:YES];
}

-(void)hideLoadingMode {
    [progressView dismiss:YES];
    progressView = nil;
}

@end
