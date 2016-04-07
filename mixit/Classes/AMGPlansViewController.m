//
//  AMGPlansViewController.m
//  mixit
//
//  Created by Vincent Tourraine on 07/04/16.
//  Copyright © 2016 Studio AMANgA. All rights reserved.
//

#import "AMGPlansViewController.h"

static NSString * const AMGImageCellIdentifier = @"CellImage";


@implementation AMGPlansViewController

#pragma mark - View life cycle

- (instancetype)init {
    self = [super initWithStyle:UITableViewStyleGrouped];

    if (self) {
        self.title = NSLocalizedString(@"Plans", nil);
    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.plansImages = @[[self floorMapImageNamed:@"MapGeneral"],
                         [self floorMapImageNamed:@"MapGeneral1"],
                         [self floorMapImageNamed:@"MapGeneral0"],
                         [self floorMapImageNamed:@"MapGeneral-1"]];

    [self.tableView registerClass:UITableViewCell.class forCellReuseIdentifier:AMGImageCellIdentifier];
}

- (UIImage *)floorMapImageNamed:(nonnull NSString *)imageName {
    NSString *path = [[NSBundle mainBundle] pathForResource:imageName ofType:@"jpg"];
    return [UIImage imageWithContentsOfFile:path];
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.plansImages.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:AMGImageCellIdentifier forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    UIImageView *imageView = cell.contentView.subviews.firstObject;
    UIImage *image = self.plansImages[indexPath.row];

    if (imageView == nil) {
        imageView = [[UIImageView alloc] initWithImage:image];
        imageView.frame = CGRectInset(cell.contentView.bounds, 0, 8);
        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [cell.contentView addSubview:imageView];
    }
    else {
        imageView.image = image;
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 230;
}

@end
