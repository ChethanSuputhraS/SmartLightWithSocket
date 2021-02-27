//
//  KPSolidColorView.m
//  SmartLightApp
//
//  Created by stuart watts on 30/03/2018.
//  Copyright © 2018 Kalpesh Panchasara. All rights reserved.
//

#import "KPSolidColorView.h"
#import "solidCustomCell.h"
#import "KPCollectionReusableView.h"

#define kDefaultCellPadding 2.0f
#define kColorCellIdentifier @"KPSolidColorViewCellReuseIdentifier"

@interface KPSolidColorView ()<FCAlertViewDelegate>
-(void)intializeFromHere;
-(void)setColorCell:(UICollectionViewCell *)cell selected:(BOOL)selected withIndexpath:(NSIndexPath *)indexx;
-(void)resetColorPicker;
@end

@implementation KPSolidColorView
@synthesize delegate,favColors,rgbwColor;


#pragma mark - Initialization
- (id)init
{
    self = [super init];
    if (self)
    {
        [self intializeFromHere];
    }
    return self;
}
-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self intializeFromHere];
    }
    return self;
}

#pragma mark - Set Colors
-(void)setColors:(NSArray *)colorsIn;
{
    colors = nil;
    colors = colorsIn;
    [self resetColorPicker];
}
-(void)setColorsPerRow:(NSInteger)colorsPerRow
{
    if (colorsPerRow < 1)
    {
        _rowCount = 1;
        [self resetColorPicker];
        return;
    }
    _rowCount = colorsPerRow;
    [self resetColorPicker];
}

-(void)setColorCellPadding:(CGFloat)colorCellPadding
{
    _cellPaddings = colorCellPadding;
    
    if (_cellPaddings < 0.0)
    {
        _cellPaddings= 0.0;
    }
    [self resetColorPicker];
}
-(void)setHighlightSelection:(BOOL)highlightSelection
{
    _highlightSelection = highlightSelection;
    
    [self resetColorPicker];
}
-(void)setSelectionBorderColor:(UIColor *)selectionBorderColor
{
    _selectionBorderColor = selectionBorderColor;
    
    [self resetColorPicker];
}

-(void)layoutSubviews
{
    _collectionView.frame = self.bounds;
}

-(void)intializeFromHere
{
    // Set default values
    self.colorsPerRow = 4;
   _cellPaddings = kDefaultCellPadding;
   _highlightSelection = YES;
   _selectionBorderColor = [UIColor clearColor];

    // Collection view setup
    _collectionView=[[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
    [_collectionView registerClass:[solidCustomCell class] forCellWithReuseIdentifier:kColorCellIdentifier];
    _collectionView.scrollEnabled = YES;
    _collectionView.alwaysBounceVertical = YES;
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.contentInset = UIEdgeInsetsMake(_cellPaddings, 0, _cellPaddings, 0);
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [self addSubview:_collectionView];
    
    UILongPressGestureRecognizer* longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPress:)];
    [_collectionView addGestureRecognizer:longPressRecognizer];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UpdateFavColors" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(UpdateFavColors) name:@"UpdateFavColors" object:nil];

    [self UpdateFavColors];
}

-(void)setColorCell:(UICollectionViewCell *)cell selected:(BOOL)selected withIndexpath:(NSIndexPath *)indexx;
{
    if (!selected || !_highlightSelection)
    {
    }
    else
    {
//
//        if (selectedIndexPath == indexx)
//        {
//            solidCustomCell *cell = (solidCustomCell *)[_collectionView cellForItemAtIndexPath:selectedIndexPath];
//            cell.imgCheck.hidden = NO;
//            cell.imgCheck.image = [UIImage imageNamed:@"solidCheck.png"];
//            if (indexx.section==0)
//            {
//                if (indexx.row ==3)
//                {
//                    cell.imgCheck.image = [btnCheckMark.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//                    [cell.imgCheck setTintColor:[UIColor blackColor]];
//                }
//            }
//        }
        
   
    }
}

-(void)resetColorPicker
{
    [_collectionView setContentOffset:CGPointMake(0, 0)];
    [_collectionView reloadData];
}
-(void)UpdateFavColors
{
    NSMutableArray * colors = [[NSMutableArray alloc] init];
    NSString * strQuery = [NSString stringWithFormat:@"select * from Solid_Fav_Color where user_id='%@'",CURRENT_USER_ID];
    [[DataBaseManager dataBaseManager] execute:strQuery resultsArray:colors];
    
    NSMutableArray * onlyColorsArr = [[NSMutableArray alloc] init];
    
    for (int i =0; i<[colors count]; i++)
    {
        CGFloat tmpR = [[[colors objectAtIndex:i] valueForKey:@"color_red"] floatValue];
        CGFloat tmpG = [[[colors objectAtIndex:i] valueForKey:@"color_green"] floatValue];
        CGFloat tmpB = [[[colors objectAtIndex:i] valueForKey:@"color_blue"] floatValue];
        
        UIColor * tmpColor = [UIColor colorWithRed:tmpR/255.0f green:tmpG/255.0f blue:tmpB/255.0f alpha:1.0];
        NSMutableDictionary * dicts = [[NSMutableDictionary alloc] init];
        dicts = [[colors objectAtIndex:i] mutableCopy];
        [dicts setObject:tmpColor forKey:@"RealColor"];
        [onlyColorsArr addObject:dicts];
    }
    favColors = [[NSMutableArray alloc] init];
    favColors = onlyColorsArr;
    [_collectionView reloadData];
}
#pragma mark - Collection View Delegate and DataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return rgbwColor.count;
    }
    else if (section == 1)
    {
        return favColors.count;
    }
    return colors.count;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 3;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    solidCustomCell *cell;
    cell = [collectionView dequeueReusableCellWithReuseIdentifier:kColorCellIdentifier forIndexPath:indexPath];
    
    if (!cell)
    {
        cell = [[solidCustomCell alloc] init];
    }
    
    if (indexPath.section == 0)
    {
        cell.lblColor.backgroundColor = [rgbwColor objectAtIndex:indexPath.row];
    }
    else if (indexPath.section ==1)
    {
        cell.lblColor.backgroundColor = [[favColors objectAtIndex:indexPath.row] valueForKey:@"RealColor"];
    }
    else if (indexPath.section == 2)
    {
        cell.lblColor.backgroundColor = [colors objectAtIndex:indexPath.row];
    }
    cell.imgCheck.hidden = YES;

    if (selectedIndexPath == indexPath)
    {
//        NSLog(@"selected Sec=%d Raw=%d  normalsec=%d Raw=%d",selectedIndexPath.section,selectedIndexPath.row, indexPath.section,indexPath.row);
        cell.imgCheck.hidden = NO;
        cell.imgCheck.image = [UIImage imageNamed:@"solidCheck.png"];
        if (indexPath.section==0)
        {
            if (indexPath.row ==3)
            {
                cell.imgCheck.image = [[UIImage imageNamed:@"solidCheck.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                [cell.imgCheck setTintColor:[UIColor blackColor]];
            }
        }
    }
    else
    {
        cell.imgCheck.hidden = YES;
    }
      [collectionView registerClass:[KPCollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView"];
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [_collectionView cellForItemAtIndexPath:indexPath];
    
    cell.alpha = 0.5;
}

-(void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [_collectionView cellForItemAtIndexPath:indexPath];
    cell.alpha = 1.0;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    solidCustomCell * cell  = (solidCustomCell *)[_collectionView cellForItemAtIndexPath:selectedIndexPath];
    cell.imgCheck.hidden = YES;
    
    cell  = (solidCustomCell *)[_collectionView cellForItemAtIndexPath:indexPath];
    {
        
        //        solidCustomCell *cell = (solidCustomCell *)[_collectionView cellForItemAtIndexPath:selectedIndexPath];
        cell.imgCheck.hidden = NO;
        cell.imgCheck.image = [UIImage imageNamed:@"solidCheck.png"];
        if (indexPath.section==0)
        {
            if (indexPath.row ==3)
            {
                cell.imgCheck.image = [[UIImage imageNamed:@"solidCheck.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                [cell.imgCheck setTintColor:[UIColor blackColor]];
            }
        }
    }
    
    selectedIndexPath = indexPath;
    [_collectionView reloadData];
    [self setColorCell:[collectionView cellForItemAtIndexPath:indexPath] selected:YES withIndexpath:indexPath];
    
    if (indexPath.section == 0)
    {
        _selectedColor = [rgbwColor objectAtIndex:indexPath.row];
    }
    else if (indexPath.section ==1)
    {
        _selectedColor = [[favColors objectAtIndex:indexPath.row] valueForKey:@"RealColor"];
    }
    else if (indexPath.section == 2)
    {
        _selectedColor = [colors objectAtIndex:indexPath.row];
    }
    if (delegate && [delegate respondsToSelector:@selector(pickSolidColor:didSelectColor:)])
    {
        [delegate pickSolidColor:self didSelectColor:_selectedColor];
    }
}

-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self setColorCell:[collectionView cellForItemAtIndexPath:indexPath] selected:NO withIndexpath:indexPath];
}

#pragma mark - Collection View Layout Delegate
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger itemsPerRow = _rowCount;
    NSInteger spaceMultiplier = (itemsPerRow-1)*_cellPaddings;
    if (spaceMultiplier <= 0)
    {
        spaceMultiplier = 0;
    }
    // calculate size for 3 thumbs per line
    CGFloat size = floorf((collectionView.bounds.size.width-spaceMultiplier)/itemsPerRow);
    return CGSizeMake(size, size);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return _cellPaddings;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return _cellPaddings;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0,0,0,0);
}
-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
        UICollectionReusableView *reusableview = nil;
    if (kind == UICollectionElementKindSectionHeader)
    {
        KPCollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
        headerView.backgroundColor = [UIColor clearColor];
        reusableview = headerView;
        
        if (indexPath.section == 0)
        {
            headerView.lblHeader.text = @"RGB";
            headerView.btnAdd.hidden = YES;
        }
        else if (indexPath.section == 1)
        {
            headerView.lblHeader.text = @"Your Favourite";
            headerView.btnAdd.hidden = NO;
            [headerView.btnAdd addTarget:self action:@selector(btnAddClick) forControlEvents:UIControlEventTouchUpInside];
        }
        else
        {
            headerView.lblHeader.text = @"Color Palette";
            headerView.btnAdd.hidden = YES;
        }
        return reusableview;
    }
    return nil;
}
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(DEVICE_WIDTH, 50);
}
-(void)btnAddClick
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowColorSelectScreen" object:nil];
}
-(void)onLongPress:(UILongPressGestureRecognizer *)pGesture
{
    if (pGesture.state == UIGestureRecognizerStateRecognized)
    {
        //Do something to tell the user!
    }
    if (pGesture.state == UIGestureRecognizerStateBegan)
    {
        CGPoint touchPoint = [pGesture locationInView:_collectionView];
            NSIndexPath *indexPath = [_collectionView indexPathForItemAtPoint:touchPoint];
        if (indexPath != nil)
        {
            if (indexPath.section == 1)
            {
                strDeleteFavColor = [[favColors objectAtIndex:indexPath.row] valueForKey:@"id"];
                [favColors objectAtIndex:indexPath.row];
                [_collectionView reloadData];
                if (delegate && [delegate respondsToSelector:@selector(selectedIndexforFavDelete:)])
                {
                    [delegate selectedIndexforFavDelete:[favColors objectAtIndex:indexPath.row]];
                }
            }
        }
    }
}

//func collectionView(collectionView: UICollectionView, layout collectionViewLayout: MyFlowLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
//    return CGSize(width: xx, height: xx)
//}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
