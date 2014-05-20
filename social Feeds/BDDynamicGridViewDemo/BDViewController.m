

#import "BDViewController.h"
#import "BDViewController+Private.h"
#import "BDRowInfo.h"

@interface BDViewController ()<UITextFieldDelegate>
{
    NSMutableArray* filteredFeeds;
    NSArray* originalFeeds;
}

@end

@implementation BDViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    } else {
        self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    }
    
    self.delegate = self;
    self.searchBar.delegate = self;
    originalFeeds = self.feedArr;
    [self _demoAsyncDataLoading];
    [self buildBarButtons];
}

- (void)animateReload
{
    [self.searchBar resignFirstResponder];
    self.feedArr = originalFeeds;
    _items = [NSArray new];
    [self _demoAsyncDataLoading];
}

- (void)beginSearch
{
    _items = [NSArray new];
    [self _demoAsyncDataLoading];
}

-(void)searchingClassified
{
    
}

- (NSUInteger)numberOfViews
{
    return _items.count;
}

-(NSUInteger)maximumViewsPerCell
{
    return 5;
}

- (UIView *)viewAtIndex:(NSUInteger)index rowInfo:(BDRowInfo *)rowInfo
{
    UIImageView * imageView = [_items objectAtIndex:index];

    return imageView;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    //Call super when overriding this method, in order to benefit from auto layout.
    [super shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
    return YES;
}

- (CGFloat)rowHeightForRowInfo:(BDRowInfo *)rowInfo
{
//    if (rowInfo.viewsPerCell == 1) {
//        return 125  + (arc4random() % 55);
//    }else {
//        return 100;
//    }
    return 55 + (arc4random() % 125);
}

#pragma mark search engine
- (void)searchForLocation:(NSString *)location
{
        NSMutableArray* tempArr = [NSMutableArray new];
        filteredFeeds = [NSMutableArray new];
        for (NSDictionary* ma in self.feedArr) {
            [tempArr addObject:ma[@"type"]];
            [tempArr addObject:ma[@"text"]];
        }
        
        NSArray* tempFilterArr = nil;
        tempFilterArr =  [tempArr filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF contains[cd] %@",location]];
        
        for (NSDictionary* ma in self.feedArr) {
            for (NSString* st in tempFilterArr) {
                if ([st isEqualToString:ma[@"type"]] || [st isEqualToString:ma[@"text"]]) {
                    [filteredFeeds addObject:ma];
                    break;
                }
            }
        }
        self.feedArr = filteredFeeds;
        [self beginSearch];
}


#pragma mark UITextField delegate

- (void) UITextFieldTextDidChange:(NSNotification*)notification
{
        UITextField * textfield = (UITextField*)notification.object;
        NSString * text = textfield.text;
        [self searchForLocation:text];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
        UITextPosition *beginning = [textField beginningOfDocument];
        [textField setSelectedTextRange:[textField textRangeFromPosition:beginning
                                                              toPosition:beginning]];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    NSString * text = textField.text;
    if ([text isEqualToString:@""]) {
        self.feedArr = originalFeeds;
        [self animateReload];
    }else
        [self searchForLocation:text];

    return YES;
}


@end
