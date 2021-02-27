#import "DoorbellDialog.h"
#import <QuartzCore/QuartzCore.h>

NSString * const DoorbellSite = @"http://doorbell.io";

@interface DoorbellDialog ()

@property (strong, nonatomic) UIView *boxView;
@property (strong, nonatomic) UITextView *bodyView;
@property (strong, nonatomic) UITextField *emailField;
@property (strong, nonatomic) UIButton *cancelButton;
@property (strong, nonatomic) UIButton *sendButton;
@property (strong, nonatomic) UIView *poweredBy;
@property (strong, nonatomic) UILabel *bodyPlaceHolderLabel;
@property (strong, nonatomic) UILabel *sendingLabel;
@property (strong, nonatomic) UIViewController *parentViewController;

@property UIDeviceOrientation lastDeviceOrientation;

@end

@implementation DoorbellDialog

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _showEmail = YES;
        _showPoweredBy = YES;
        _sending = NO;
        // Initialization code
        CGRect screenFrame=self.frame;
        screenFrame.size.height=screenFrame.size.height+250;
        self.frame=screenFrame;
        
        self.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.4];
        self.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
        CGRect boxFrame;
        boxFrame.size = CGSizeMake(DEVICE_WIDTH-20, 235);
        boxFrame.origin.x = (self.frame.size.width/2) - boxFrame.size.width/2;
        boxFrame.origin.y = ((frame.size.height - boxFrame.size.height) / 2)-120;
        
        _boxView = [[UIView alloc] initWithFrame:CGRectMake(boxFrame.origin.x, DEVICE_HEIGHT, boxFrame.size.width, 334)];
        _boxView.backgroundColor = UIColor.whiteColor;
        _boxView.layer.masksToBounds = NO;
//        _boxView.layer.cornerRadius = 18.0f;
        //_boxView.layer.borderColor = [UIColor blackColor].CGColor;
        //_boxView.layer.borderWidth = 1.0f;
        _boxView.layer.shadowRadius = 2.0f;
//        _boxView.layer.shadowOffset = CGSizeMake(0, 1);
//        _boxView.layer.shadowOpacity = 0.7f;

        [self createBoxSubviews];

        [self addSubview:_boxView];

    }
    return self;
}

- (id)initWithViewController:(UIViewController *)vc
{
    CGRect frame = vc.view.bounds;
    self = [self initWithFrame:frame];
    if (self) {
        self.parentViewController = vc;

        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter]
         addObserver:self selector:@selector(orientationChanged:)
         name:UIDeviceOrientationDidChangeNotification
         object:[UIDevice currentDevice]];
    }
    return self;
}

- (void)dealloc
{
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

//- (void) recalculateFrame
//{
//    CGRect frame = self.parentViewController.view.bounds;
//
//    CGRect boxFrame;
//    boxFrame.size = CGSizeMake(DEVICE_WIDTH-20, 235);
//    boxFrame.origin.x = (frame.size.width/2) - boxFrame.size.width/2;
//    boxFrame.origin.y = (frame.size.height - boxFrame.size.height) / 2;
//
////    _boxView.frame = boxFrame;
//}

- (void) orientationChanged:(NSNotification *)note
{
    // Hide the keyboard, so when the dialog is centered is looks OK
    UIDevice *device = [note object];
    if ([device orientation] != UIDeviceOrientationFaceUp &&
        [device orientation] != UIDeviceOrientationFaceDown &&
        [device orientation] != UIDeviceOrientationUnknown &&
        [device orientation] != self.lastDeviceOrientation )
    {
        [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
        self.lastDeviceOrientation = [device orientation];
//        [self recalculateFrame];
    }
}

- (NSString*)bodyText
{
    return [_bodyView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (void)setEmail:(NSString *)email
{
    if (email.length > 0) {
        self.emailField.text = email;
    }
}

- (NSString*)email
{
    return [self.emailField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (void)goToDoorbell:(id)sender
{
    NSURL *doorbellURL = [NSURL URLWithString:DoorbellSite];
    [[UIApplication sharedApplication] openURL:doorbellURL];
}

- (void)send:(id)sender
{
    [self.bodyView resignFirstResponder];//Oneclick28-04-2016
    if (self.email.length == 0)
    {
        [self highlightEmailEmpty];
        return;
    }
    else
    {
        if (self.bodyText.length == 0)
        {
            [self highlightMessageEmpty];
            return;
        }
    }
    
    
    
    if ([APP_DELEGATE validateEmail:_emailField.text])
    {
        [APP_DELEGATE startHudProcess:@"Sending feedback..."];
        if ([_delegate respondsToSelector:@selector(dialogDidSend:)])
        {
            [_delegate dialogDidSend:self];
        }
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DoorbellPopupFailure" object:nil];
    }
    
}

- (void)cancel:(id)sender
{
    if ([_delegate respondsToSelector:@selector(dialogDidCancel:)]) {
        [_delegate dialogDidCancel:self];
    }
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)highlightMessageEmpty
{
    _bodyPlaceHolderLabel.text = NSLocalizedString(@"Please add some feedback", nil);
    _bodyPlaceHolderLabel.textColor = [UIColor redColor];
    [_bodyView becomeFirstResponder];
}

- (void)highlightEmailEmpty
{
    _emailField.layer.borderColor = [UIColor redColor].CGColor;
    _emailField.placeholder = NSLocalizedString(@"Please add an email", nil);
    [_emailField becomeFirstResponder];
    [APP_DELEGATE getPlaceholderText:_emailField andColor:[UIColor redColor]];

}

- (void)highlightEmailInvalid
{
    _emailField.layer.borderColor = [UIColor redColor].CGColor;
    [_emailField becomeFirstResponder];
}

- (void)setShowEmail:(BOOL)showEmail
{
    _showEmail = showEmail;
    _emailField.hidden = !showEmail;
    [self layoutSubviews];
}

- (void)setShowPoweredBy:(BOOL)showPoweredBy
{
    _showPoweredBy = showPoweredBy;
    _poweredBy.hidden = !showPoweredBy;
    [self layoutSubviews];
}

- (UILabel*)sendingLabel
{
    if (!_sendingLabel)
    {
        _sendingLabel = [[UILabel alloc] initWithFrame:_bodyView.frame];
        _sendingLabel.font = [UIFont boldSystemFontOfSize:18.0f];
        _sendingLabel.textAlignment = NSTextAlignmentCenter;
        _sendingLabel.textColor =  [UIColor colorWithRed:91/255.0f green:192/255.0f blue:222/255.0f alpha:1.0f];
        _sendingLabel.text = NSLocalizedString(@"Sending ...", nil);
    }

    return _sendingLabel;
}

- (void)setSending:(BOOL)sending
{
    _sending = sending;
    _bodyView.hidden = sending;
    if (_showEmail) {
        _emailField.hidden = sending;
    }
    if (_showPoweredBy) {
        _poweredBy.hidden = sending;
    }
    _cancelButton.hidden = sending;
    _sendButton.hidden = sending;

//    if (sending) {
//        [_boxView addSubview:self.sendingLabel];
//    }
//    else {
//        [self.sendingLabel removeFromSuperview];
//    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)layoutSubviews
{
//    float offsetY = _bodyView.frame.origin.y + _bodyView.frame.size.height + 10.0f;
//    if (_showEmail)
//    {
//        _emailField.frame = CGRectMake(10.0f, offsetY, _bodyView.frame.size.width, 30.0f);
//        offsetY += 40;
//        lblLine2.frame = CGRectMake(10.0f,(_emailField.frame.origin.y+_emailField.frame.size.height), _bodyView.frame.size.width, 1.0f);
//    }



//    CGRect frame = _boxView.frame;
//    frame.size.height = offsetY + 44.0f;
//    _boxView.frame = frame;

    [super layoutSubviews];
}

- (void)createBoxSubviews
{

    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, _boxView.frame.size.width, 50.0f)];
    titleLabel.text = NSLocalizedString(@"Feedback", nil);
    titleLabel.font = [UIFont fontWithName:CGBold size:textSizes+10];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = UIColor.blackColor;
    [_boxView addSubview:titleLabel];

    CGFloat boxWidth = _boxView.frame.size.width;

    UILabel * lblEmail = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 50.0f, DEVICE_WIDTH-20, 30.0f)];
    lblEmail.text = NSLocalizedString(@"Email", nil);
    lblEmail.font = [UIFont fontWithName:CGRegular size:textSizes-2];
    lblEmail.backgroundColor = [UIColor clearColor];
    lblEmail.textColor = UIColor.blackColor;
    [_boxView addSubview:lblEmail];
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(10, 80, boxWidth-20, 44)];
    paddingView.backgroundColor = [UIColor lightGrayColor];
    paddingView.layer.masksToBounds = YES;
    paddingView.layer.cornerRadius = 8;
    [_boxView addSubview:paddingView];
    
    _emailField = [[UITextField alloc] initWithFrame:CGRectMake(5, 0.0f, paddingView.frame.size.width-10, 44)];
    _emailField.delegate = self;
    _emailField.placeholder = NSLocalizedString(@"Your email address", nil);
    [APP_DELEGATE getPlaceholderText:_emailField andColor:[UIColor blackColor]];

    _emailField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _emailField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _emailField.keyboardType = UIKeyboardTypeEmailAddress;
    _emailField.keyboardAppearance = UIKeyboardAppearanceAlert;
    _emailField.returnKeyType = UIReturnKeyNext;
    _emailField.autocorrectionType = UITextAutocorrectionTypeNo;
    _emailField.backgroundColor = UIColor.clearColor;
    _emailField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _emailField.font = [UIFont fontWithName:CGRegular size:textSizes];
    _emailField.autocorrectionType = NO;
    _emailField.layer.masksToBounds = YES;
    [paddingView addSubview:_emailField];

    UILabel * lblBody = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 130.0f, _boxView.frame.size.width-20, 30.0f)];
    lblBody.text = NSLocalizedString(@"Feedback", nil);
    lblBody.font = [UIFont fontWithName:CGRegular size:textSizes-2];
    lblBody.backgroundColor = [UIColor clearColor];
    lblBody.textColor = UIColor.blackColor;
    [_boxView addSubview:lblBody];

    UIView *padBoxView = [[UIView alloc] initWithFrame:CGRectMake(10, 160, boxWidth-20, 110)];
    padBoxView.backgroundColor = [UIColor lightGrayColor];
    padBoxView.layer.masksToBounds = YES;
    padBoxView.layer.cornerRadius = 8;
    [_boxView addSubview:padBoxView];

    _bodyView = [[UITextView alloc] initWithFrame:CGRectMake(5, 5, padBoxView.frame.size.width-10, 100)];
    _bodyView.delegate = self;
    _bodyView.backgroundColor = [UIColor clearColor];
    _bodyView.textColor = [UIColor darkTextColor];
    _bodyView.font = [UIFont fontWithName:CGRegular size:textSizes+2];
    _bodyView.dataDetectorTypes = UIDataDetectorTypeNone;
    _bodyView.keyboardAppearance = UIKeyboardAppearanceAlert;
    _bodyView.autocorrectionType = NO;
    _bodyView.autocorrectionType = UITextAutocorrectionTypeNo;
    _bodyView.layer.masksToBounds = YES;
    [padBoxView addSubview:_bodyView];
    
    _bodyPlaceHolderLabel = [[UILabel alloc] initWithFrame:CGRectMake(8.0f, 10.0f, boxWidth-40, 20.0f)];
    _bodyPlaceHolderLabel.text = NSLocalizedString(@"We want your suggestions!", nil);
    _bodyPlaceHolderLabel.font = _bodyView.font;
    _bodyPlaceHolderLabel.textColor = [UIColor blackColor];
    _bodyPlaceHolderLabel.userInteractionEnabled = NO;
    _bodyPlaceHolderLabel.font = [UIFont fontWithName:CGRegular size:textSizes];
    [_bodyView addSubview:_bodyPlaceHolderLabel];


     UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *bodyDoneButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", nil)
                                                                    style:UIBarButtonItemStyleDone target:_bodyView action:@selector(resignFirstResponder)];
   
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, boxWidth, 44)];
    toolbar.items = [NSArray arrayWithObjects:flexibleSpace, bodyDoneButton, nil];
    _bodyView.inputAccessoryView = toolbar;
    _bodyView.autocorrectionType = UITextAutocorrectionTypeNo;
   
    
    
     UIBarButtonItem *emailFlexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *emailDoneButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Next", nil)
                                                                       style:UIBarButtonItemStyleDone target:_emailField action:@selector(resignFirstResponder)];
    UIToolbar *emailToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 44)];
    emailToolbar.items = [NSArray arrayWithObjects:emailFlexibleSpace, emailDoneButton, nil];
    _emailField.inputAccessoryView = emailToolbar;
    _emailField.autocorrectionType = UITextAutocorrectionTypeNo;
    

    _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _cancelButton.frame = CGRectMake(2.0f, _boxView.frame.size.height-48, (_boxView.frame.size.width/2)-2, 44.0f);
    _cancelButton.backgroundColor = global_brown_color;
    [_cancelButton setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
    [_cancelButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    _cancelButton.titleLabel.font = [UIFont fontWithName:CGRegular size:textSizes];
    [_cancelButton addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];

    _sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _sendButton.frame = CGRectMake((_boxView.frame.size.width/2)+2,  _boxView.frame.size.height-48, (_boxView.frame.size.width/2)-4, 44.0f);
    [_sendButton setTitle:NSLocalizedString(@"Send", nil) forState:UIControlStateNormal];
    [_sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _sendButton.titleLabel.font = [UIFont fontWithName:CGRegular size:textSizes+2];
    _sendButton.backgroundColor = global_brown_color;
    [_sendButton addTarget:self action:@selector(send:) forControlEvents:UIControlEventTouchUpInside];

    [_boxView addSubview:_cancelButton];
    [_boxView addSubview:_sendButton];
    
//    [_bodyView becomeFirstResponder];
    
    [self ShowPicker:YES andView:_boxView];
}

- (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
    CGContextFillRect(context, rect);

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}

#pragma mark - Animations
-(void)ShowPicker:(BOOL)isShow andView:(UIView *)myView
{
    if (isShow == YES)
    {
        [UIView transitionWithView:myView duration:0.2
                           options:UIViewAnimationOptionCurveLinear
                        animations:^{
                            [myView setFrame:CGRectMake(10,(DEVICE_HEIGHT-334)/2,DEVICE_WIDTH-20, 334)];
                        }
                        completion:^(BOOL finished)
         {
         }];
    }
    else
    {
        [UIView transitionWithView:myView duration:0.2
                           options:UIViewAnimationOptionCurveLinear
                        animations:^{
                            [myView setFrame:CGRectMake(10,DEVICE_HEIGHT,DEVICE_WIDTH-20, 320)];
                        }
                        completion:^(BOOL finished)
         {
         }];
    }
}


#pragma mark - UITextView Delegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
//    [self verticalOffsetBy:-80];
    
    [UIView transitionWithView:_boxView duration:0.2
                       options:UIViewAnimationOptionCurveLinear
                    animations:^{
                        [_boxView setFrame:CGRectMake(10,20,DEVICE_WIDTH-20, 334)];
                    }
                    completion:^(BOOL finished)
     {
     }];

    return YES;
}
-(void)textViewDidBeginEditing:(UITextView *)textView
{
    if (textView == _bodyView)
    {
        lblLine1.backgroundColor = UIColor.blackColor;
    }
}
-(void)textViewDidEndEditing:(UITextField *)textField
{
    lblLine1.backgroundColor = UIColor.lightGrayColor;

//   [self verticalOffsetBy:0];
    [UIView transitionWithView:_boxView duration:0.3
                       options:UIViewAnimationOptionCurveLinear
                    animations:^{
                        [_boxView setFrame:CGRectMake(10,(DEVICE_HEIGHT-334)/2,DEVICE_WIDTH-20, 334)];
                    }
                    completion:^(BOOL finished)
     {
     }];
    [_bodyView resignFirstResponder];

}

- (void)textViewDidChange:(UITextView *)textView
{
    if (textView.text.length > 0) {
        self.bodyPlaceHolderLabel.hidden = YES;
    }
    else {
        self.bodyPlaceHolderLabel.hidden = NO;
    }
}

#pragma mark - UITextField Delegate
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == _emailField)
    {
        lblLine2.backgroundColor = UIColor.blackColor;
    }

}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    
//    [self verticalOffsetBy:-150];
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    lblLine2.backgroundColor = UIColor.lightGrayColor;

    if (self.email.length == 0)
    {
        if (_bodyView.text.length == 0)
        {
//            [self verticalOffsetBy:-80];
        }
        else
        {
//            [self verticalOffsetBy:0];
        }
    }
    else
    {
        if (textField == _emailField)
        {
//            [self verticalOffsetBy:0];
        }
    }
    [_bodyView becomeFirstResponder];

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
//    [textField resignFirstResponder];
//    [self send:textField];
    [_bodyView becomeFirstResponder];
    return NO;
}

@end
