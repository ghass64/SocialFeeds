
#import <UIKit/UIKit.h>
#import "BDDynamicGridViewController.h"
@interface BDViewController : BDDynamicGridViewController <BDDynamicGridViewDelegate>{
    NSArray * _items;
}

@property (nonatomic, strong) NSArray* feedArr;
@property (nonatomic, strong) UITextField* searchField;
@end
