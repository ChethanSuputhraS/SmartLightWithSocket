//
//  DeviceDetailVC.h
//  SmartLightApp
//
//  Created by stuart watts on 29/11/2017.
//  Copyright © 2017 Kalpesh Panchasara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ORBSwitch.h"
#import <OpenEars/OEEventsObserver.h>
#import "HRColorPickerView.h"
#import "HRBrightnessSlider.h"
#import "ISColorWheel.h"
#import "BLEService.h"
#import "AddDeviceVC.h"
#import "NYSegmentedControl.h"
#import "StepSlider.h"
#import "HistoryCell.h"

#import <OpenEars/OELanguageModelGenerator.h>
#import <OpenEars/OEAcousticModel.h>
#import <OpenEars/OEPocketsphinxController.h>
#import <OpenEars/OEAcousticModel.h>

#import "KPSolidColorView.h"
#import "KPWhiteColorImgView.h"
#import <AVFoundation/AVFoundation.h>

@protocol HRColorPickerViewControllerDelegate
- (void)setSelectedColor:(UIColor *)color;
@end

@interface DeviceDetailVC : UIViewController<ISColorWheelDelegate,ORBSwitchDelegate,UITableViewDelegate,UITableViewDataSource,UIPickerViewDataSource,UIPickerViewDelegate,OEEventsObserverDelegate,KPSolidColorDelegate>
{
    UIView *backView;
    UIImageView *imgLowBrightness,*imgFullBrightness;
    UIView * colorSquareView, *patternView, *whiteView, *whiteWheel, * solidView, *musicView, *rgbView, *voiceView, *bgWhiteView, *backWhiteView, *optionView;

    UIButton * redBtn, *greenBtn, *blueBtn, *btnDone, * btnVoice, * btnWhiteTracker, * btnMusic;

    UITextField * txt1,* txt2,* txt3,* txt4;

    UIImageView * warmView, * statusImg, * imgZoneWheel;

    NSInteger  savedRed, savedGreen, savedBlue, brighcount, stsImgY,gridSize,yAbove;

    BOOL isBrighNess, isShowPopup, isSentNoticication , isWhite, isWarmWhite, isVoicView;

    NSMutableArray * arrContent, * redArr, * greenArr, * blueArr, * voiceColors, * arrRecognizeList;

    NSTimer * colorTimer, * brightTimer , *timeoutTimer;

    NSMutableData *completeData, * brighData;

    NSArray  * brandedColors;
    
    NSInteger alpha, selecedPtrn,patternSelected;

    NSString *lmPath, *dicPath;

    UISlider * _brightnessSlider;
    UITableView * tblView;
    UIPickerView *  pickerView;
    UIToolbar *keyboardDoneButtonView;
    UILabel * rgbLbl, * lblVoiceDetected;
    UIScrollView * scrlView;
    UIColor * selectedColors, * imgColor;
    UILabel *lblThumbTint;
    id <HRColorPickerViewControllerDelegate> __weak delegate;
    KPSolidColorView * solidColorView;
  //  HRColorPickerView * colorPickerView;
    StepSlider *slider;
    ISColorWheel* _colorWheel;
    NYSegmentedControl * blueSegmentedControl;
    
    UIView * squareOptionView, * viewOverLay;
    UICollectionView * kpcollectionView;
    NSMutableArray * arrColorOptions, * arrWhiteOptions;
    CGFloat cellPaddings;
    NSInteger rowCount;
    KPWhiteColorImgView * imgColorOptionView;
    BOOL isColorOptionON, isColorOpionWarmON;
    UITableView * tblVoices;
    
    UIScrollView * solidScrollView;
    
    AVAudioRecorder *audioRecorder;
    int recordEncoding;
    enum
    {
        ENC_AAC = 1,
        ENC_ALAC = 2,
        ENC_IMA4 = 3,
        ENC_ILBC = 4,
        ENC_ULAW = 5,
        ENC_PCM = 6,
    } encodingTypes;
    
    float Pitch;
    NSTimer *timerForPitch, * timerforMusicCount, * timertoSendMusic;
    float totalMusicBits;
    
    NSArray * arrSolidColors;

}
@property(nonatomic,strong)ORBSwitch * _switchLight;
@property(nonatomic,strong)NSString *  deviceName;
@property(nonatomic,strong)NSMutableDictionary  *  deviceDict;
@property BOOL isFromScan;
@property(nonatomic,strong)NSString *  isfronScreen;
@property BOOL isFromAll;
@property BOOL isfromGroup;
@property BOOL isDeviceWhite;
@property (strong, nonatomic) OEEventsObserver *openEarsEventsObserver;
@property (strong, nonatomic) KPWhiteColorImgView * colorPicker;
- (void)pickedColor:(UIColor*)color atPoint:(CGPoint) point;
@property  float brightnessSliderVal;

@property (weak) id <HRColorPickerViewControllerDelegate> delegate;




@end
