/******************************************************************************
 *
 * Copyright (C) 2013 T Dispatch Ltd
 *
 * Licensed under the GPL License, Version 3.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.gnu.org/licenses/gpl-3.0.html
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 ******************************************************************************
 *
 * @author Marcin Orlowski <marcin.orlowski@webnet.pl>
 *
 ****/

#import "FlatAutoScrollButton.h"

#import "CBAutoScrollLabel.h"

@interface FlatAutoScrollButton()

@property (nonatomic, weak) CBAutoScrollLabel* label;

@end

@implementation FlatAutoScrollButton

- (void)initialize
{
    CBAutoScrollLabel* l = [[CBAutoScrollLabel alloc] initWithFrame:self.bounds];
    l.backgroundColor = [UIColor clearColor];
    l.font = [UIFont systemFontOfSize:12];
    l.textAlignment = UITextAlignmentCenter;
    l.textColor = [UIColor whiteColor];
    [self addSubview:l];
    self.label = l;

    [self layoutIfNeeded];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)setTitleFont:(UIFont*)font
{
    _label.font = font;
}

- (void)setTitleColor:(UIColor *)color forState:(UIControlState)state
{
    _label.textColor = color;
}

- (void) setTitle:(NSString *)title forState:(UIControlState)state
{
    [_label setText:title refreshLabels:YES];
}

- (void)setTextAlignment:(UITextAlignment)textAlignment
{
    _label.textAlignment = textAlignment;
    [_label refreshLabels];
}

- (NSString *)titleForState:(UIControlState)state
{
    return _label.text;
}

@end
