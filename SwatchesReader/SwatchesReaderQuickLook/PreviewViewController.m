//
//  PreviewViewController.m
//  SwatchesReaderQuickLook
//
//  Created by Viktor Goltvyanytsya on 11.12.2019.
//  Copyright © 2019 FWKit. All rights reserved.
//









#import "PreviewViewController.h"
#import <QuickLook/QuickLook.h>
#import "PreviewColorTableViewCell.h"
#import "SRColorGroup.h"
#import "SRColorCollection.h"
#import "SRColorCollectionFileHandler.h"
@import os.log;

@interface PreviewViewController () <QLPreviewingController, UITableViewDelegate, UITableViewDataSource>
{
    SRColorCollectionFileHandler    *_colorCollectionFileHandler;
    NSString                        *_fileExt;
}

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<SRColorGroup *> *groupsArray;

@end



@implementation PreviewViewController

- (void)dealloc
{
    
    if(_colorCollectionFileHandler)
    {
        [_colorCollectionFileHandler close];
    }
    
    _colorCollectionFileHandler = nil;
    
    _fileExt = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configurationData];
    [self configurationTableView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self reload];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    CGFloat cw = self.view.frame.size.width;
    [self.tableView setFrame:CGRectMake(0, 0, cw, self.view.frame.size.height)];
}

- (void)preparePreviewOfFileAtURL:(NSURL *)url completionHandler:(void (^)(NSError * _Nullable))handler
{
    
    if(_colorCollectionFileHandler)
    {
        [_colorCollectionFileHandler close];
    }
    
    _colorCollectionFileHandler = nil;
    
    _fileExt = nil;
    
    _colorCollectionFileHandler = [[SRColorCollectionFileHandler alloc] initWithURL:url];
    _fileExt = url?[[url pathExtension] uppercaseString]:@"";
    __weak __typeof(self) weakSelf = self;
    [_colorCollectionFileHandler readColorCollectionWithCompletionHandler:^(BOOL success, NSURL *url, SRColorCollection *collection) {
        if(weakSelf && success && (collection.groups || collection.colors))
        {
            [weakSelf configurationData];
            [weakSelf configurationTableView];
             
            if(collection.colors.count>0)
            {
                SRColorGroup *group = [collection ungroupedColors];
                [weakSelf.groupsArray addObject:group];
            }
            
            [weakSelf.groupsArray addObjectsFromArray:collection.groups];
        }
        
        if(handler)
        {
            handler(nil);
        }

    }];
    
    
}

#pragma mark -UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    SRColorGroup *group = self.groupsArray[section];
    return group.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PreviewColorTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PreviewColorTableViewCell" forIndexPath:indexPath];
    if(indexPath.section>=0 && indexPath.section<self.groupsArray.count)
    {
        SRColorGroup *group = self.groupsArray[indexPath.section];
        if(indexPath.row>=0 && indexPath.row<group.count)
        {
            SRBaseColor *color = [group colorAtIndex:indexPath.row];
            BOOL displayColorType = ( _fileExt && [_fileExt isEqualToString:@"ASE"] );
            [cell setColor:color displayColorType:displayColorType];
        }
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.groupsArray.count;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    SRColorGroup *group = [self.groupsArray objectAtIndex:section];
    NSString *groupName = group.name?group.name:@"";
    return groupName;
}

#pragma mark -UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    os_log_t logger = os_log_create("com.fwkit.swatches", "color");
    os_log_with_type(logger, OS_LOG_TYPE_DEBUG, "select %@", @(indexPath.row) );
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

#pragma mark -Private methods

- (void)configurationData
{
    if(!self.groupsArray)
    {
        self.groupsArray = [NSMutableArray array];
    }
}

- (void)configurationTableView
{
    [self.tableView registerClass:[PreviewColorTableViewCell class] forCellReuseIdentifier:@"PreviewColorTableViewCell"];
}

- (void)reload
{
    [self.tableView reloadData];
}

- (UITableView *)tableView
{
    if (!_tableView)
    {
        CGFloat cw = CGRectGetWidth(self.view.frame);
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, cw, CGRectGetHeight(self.view.frame)) style:UITableViewStyleInsetGrouped];
        tableView.tableHeaderView.frame = CGRectMake(0, 0, cw, 50);
        tableView.autoresizingMask = UIViewAutoresizingNone;
        tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentScrollableAxes;
        tableView.delegate = self;
        tableView.dataSource = self;
        
        [self.view addSubview:tableView];
        
        _tableView = tableView;
    }
    
    return _tableView;
}




@end
