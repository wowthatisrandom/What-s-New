//
//  MTZWhatsNewViewController.m
//  What's New
//
//  Created by Matt Zanchelli on 5/17/14.
//  Copyright (c) 2014 Matt Zanchelli. All rights reserved.
//

#import "MTZWhatsNewViewController.h"

#import "MTZTableView.h"
#import "MTZWhatsNewFeatureTableViewCell.h"

#import "MTZCollectionView.h"
#import "MTZWhatsNewFeatureCollectionViewCell.h"

#import "SAMGradientView.h"

@interface MTZWhatsNewViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

///	An ordered list of the versions from newest to oldest.
@property (strong, nonatomic) NSArray *orderedKeys;

///	The collection view to display all the new features.
@property (strong, nonatomic) MTZCollectionView *collectionView;

///	The gradient presented as the background.
@property (strong, nonatomic) SAMGradientView *backgroundGradientView;

@end

@implementation MTZWhatsNewViewController

- (id)init
{
	self = [super init];
	if (self) {
		[self commonInit];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) {
		[self commonInit];
	}
	return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		[self commonInit];
	}
	return self;
}

- (void)commonInit
{
	// Default modal transition and presentation styles.
	self.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	self.modalPresentationStyle = UIModalPresentationFormSheet;
	
	// Background.
	self.backgroundGradientView = [[SAMGradientView alloc] initWithFrame:self.view.bounds];
	self.backgroundGradientView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[self.view addSubview:self.backgroundGradientView];
	self.backgroundGradientView.gradientColors = @[[UIColor clearColor], [UIColor clearColor]];
	self.backgroundGradientView.gradientLocations = @[@0.0, @1.0];
	
	// Feature collection view.
	UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
	flowLayout.minimumLineSpacing = 2;
	flowLayout.minimumInteritemSpacing = 0;
#warning This should be CGSizeMake(320, 108) when displayed in a line.
	flowLayout.itemSize = CGSizeMake(270, 187);
	flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
	flowLayout.headerReferenceSize = flowLayout.footerReferenceSize = CGSizeZero;
	self.collectionView = [[MTZCollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:flowLayout];
	self.collectionView.delegate = self;
	self.collectionView.dataSource = self;
	[self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"whatsnew"];
	[self.collectionView registerClass:[MTZWhatsNewFeatureCollectionViewCell class] forCellWithReuseIdentifier:@"feature"];
	UIEdgeInsets edgeInsets = UIEdgeInsetsMake(0, 0, 50, 0);
	self.collectionView.scrollIndicatorInsets = edgeInsets;
	self.collectionView.contentInset = edgeInsets;
	self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.collectionView.backgroundColor = [UIColor clearColor];
	self.collectionView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
	[self.view addSubview:self.collectionView];
	
	// Get Started.
	CGRect frame = CGRectMake(0, self.view.bounds.size.height-50, self.view.bounds.size.width, 50);
	UIView *buttonBackground = [[UIView alloc] initWithFrame:frame];
	buttonBackground.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.2f];
	buttonBackground.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
	[self.view addSubview:buttonBackground];
	UIButton *button = [[UIButton alloc] initWithFrame:frame];
	[button setTitle:NSLocalizedString(@"Get Started", nil) forState:UIControlStateNormal];
	button.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
	[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[button setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5f] forState:UIControlStateHighlighted];
	[button addTarget:self action:@selector(didTapContinueButton:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:button];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[self.collectionView flashScrollIndicators];
}

- (BOOL)prefersStatusBarHidden
{
	return YES;
}


#pragma mark - Actions

- (IBAction)didTapContinueButton:(id)sender
{
	[self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Properties

- (void)setFeatures:(NSDictionary *)features
{
	_features = [features copy];
	_orderedKeys = [[_features allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
		return [obj2 compare:obj1 options:NSNumericSearch];
	}];
	
	// Reload the collection view's data.
	[self.collectionView reloadData];
}

- (void)setTopColor:(UIColor *)topColor
{
	_topColor = [topColor copy];
	self.backgroundGradientView.gradientColors = @[_topColor, self.backgroundGradientView.gradientColors[1]];
}

- (void)setBottomColor:(UIColor *)bottomColor
{
	_bottomColor = [bottomColor copy];
	self.backgroundGradientView.gradientColors = @[self.backgroundGradientView.gradientColors[0], _bottomColor];
}


#pragma mark - UICollectionViewDelegate

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
	return NO;
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
	return [self.features count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	NSString *key = self.orderedKeys[section];
	return [self.features[key] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
				  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	MTZWhatsNewFeatureCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"feature" forIndexPath:indexPath];
	
	NSDictionary *feature = self.features[self.orderedKeys[indexPath.section]][indexPath.row];
	
	cell.title = feature[@"Title"];
	cell.detail = feature[@"Detail"];
	NSString *iconName = feature[@"Icon"];
	if ( iconName ) {
		cell.icon = [UIImage imageNamed:iconName];
	} else {
		cell.icon = nil;
	}
	
	return cell;
	
	// What's New.
	{
		UICollectionViewCell *whatsNewCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"whatsnew" forIndexPath:indexPath];
		whatsNewCell.frame = CGRectMake(whatsNewCell.frame.origin.x, whatsNewCell.frame.origin.y, collectionView.frame.size.width, 70);
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, whatsNewCell.frame.size.width, 70)];
		label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		label.textAlignment = NSTextAlignmentCenter;
		label.textColor = [UIColor whiteColor];
		label.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:30.0f];
		label.text = NSLocalizedString(@"What's New", nil);
		[whatsNewCell.contentView addSubview:label];
	}
}


#pragma mark - Helpers

- (BOOL)useAlternateLayout
{
	// iPhone width = 320
	// iPad's UIModalPresentationFormSheet width = 540
	return self.view.frame.size.width >= 512;
}


@end