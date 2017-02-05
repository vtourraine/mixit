//
//  AMGAboutViewController.h
//  mixit
//
//  Created by Vincent Tourraine on 26/03/15.
//  Copyright (c) 2015-2017 Studio AMANgA. All rights reserved.
//

@import UIKit;

@class AMGMixITSyncManager;


@interface AMGAboutViewController : UITableViewController

@property (nonatomic, strong, nullable) AMGMixITSyncManager *syncManager;

- (IBAction)openInMaps:(nullable id)sender;
- (IBAction)openInSafari:(nullable id)sender;

- (IBAction)openVTourraine:(nullable id)sender;
- (IBAction)dismiss:(nullable id)sender;

@end
