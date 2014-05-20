
#import "BDViewController+Private.h"
#import "UIImageView+WebCache.h"

#define kNumberOfPhotos 25
@implementation BDViewController (Private)

-(void)buildBarButtons
{
    UIBarButtonItem * reloadButton = [[UIBarButtonItem alloc] initWithTitle:@"Reload!"
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self 
                                                                     action:@selector(animateReload)];

    //UIBarButtonItem* searchButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchingClassified)];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: reloadButton, nil];

}

-(NSArray*)_imagesFromFeed
{   
    NSArray *images = [NSArray array];
    for (NSDictionary* dictImg in self.feedArr) {
        images = [images arrayByAddingObject:dictImg[@"imageURL"]];
    }
    return images;
}


-(NSArray*)_labelsFromFeed
{
    NSArray *labels = [NSArray array];
    for (NSDictionary* dictLbl in self.feedArr) {
        labels = [labels arrayByAddingObject:dictLbl[@"text"]];
    }
    return labels;
}

-(NSArray*)_typesFromFeed
{
    NSArray *types = [NSArray array];
    for (NSDictionary* dictype in self.feedArr) {
        types = [types arrayByAddingObject:dictype[@"type"]];
    }
    return types;
}

- (void)_demoAsyncDataLoading
{
    _items = [NSArray array];
    //load the placeholder image
    for (int i=0; i < [self.feedArr count]; i++) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"placeholder.png"]];
        imageView.frame = CGRectMake(0, 0, 44, 44);
        imageView.clipsToBounds = YES;
        _items = [_items arrayByAddingObject:imageView];
    }
    [self reloadData];
    NSArray *images = [self _imagesFromFeed];
    NSArray* labels = [self _labelsFromFeed];
    NSArray* feedTypes = [self _typesFromFeed];
    
    for (int i = 0; i < images.count; i++) {
        UIImageView *imageView = [_items objectAtIndex:i];
        NSString *image = [images objectAtIndex:i];
        imageView.frame = CGRectMake(0, 0, 44, 44);
        
        UIImageView* typeImg = [[UIImageView alloc] initWithFrame:CGRectMake(2, 2, 15, 15)];
        
        NSString* currentType = [feedTypes objectAtIndex:i];
        [typeImg setImage:[UIImage imageNamed:currentType]];
        
        UILabel* lbl = [[UILabel alloc] init];
        //lbl.frame = CGRectMake(0, 0, 44, 44);
        lbl.backgroundColor = [UIColor clearColor];
        lbl.font = [UIFont systemFontOfSize:11];
        lbl.textColor = [UIColor whiteColor];
        lbl.text = [labels objectAtIndex:i];
        lbl.numberOfLines = 4;
        lbl.lineBreakMode = NSLineBreakByClipping;
        [lbl sizeToFit];
        CGRect frame = lbl.frame;
        lbl.frame = CGRectMake(18,frame.origin.y , 80, 40);
        
        
        [imageView addSubview:typeImg];
        [imageView addSubview:lbl];

        
        [self performSelector:@selector(animateUpdate:) 
                   withObject:[NSArray arrayWithObjects:imageView, image, nil]
                   afterDelay:0.2 + (arc4random()%3) + (arc4random() %10 * 0.1)];
    }
}

- (void) animateUpdate:(NSArray*)objects
{
    UIImageView *imageView = [objects objectAtIndex:0];
    NSString* image = [objects objectAtIndex:1];
    [UIView animateWithDuration:0.5 
                     animations:^{
                         imageView.alpha = 0.f;
                     } completion:^(BOOL finished) {
                         //imageView.image = image;
                         [imageView setImageWithURL:[NSURL URLWithString:image] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
                         
                         [UIView animateWithDuration:0.5
                                          animations:^{
                                              imageView.alpha = 1;
                                          } completion:^(BOOL finished) {
                                              NSArray *visibleRowInfos =  [self visibleRowInfos];
                                              for (BDRowInfo *rowInfo in visibleRowInfos) {
                                                  [self updateLayoutWithRow:rowInfo animiated:YES];
                                              }
                                          }];
                     }];
}

@end
