//
//  ViewController.m
//  ConnectDemo
//
//  Created by 中国孔 on 2019/2/22.
//  Copyright © 2019 孔令辉. All rights reserved.
//

#import "ViewController.h"
#import <Contacts/Contacts.h>
#import "ConnectModel.h"
#import "ConnectCell.h"
#import "BottomeView.h"

#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IOS_11  ([[[UIDevice currentDevice] systemVersion] floatValue] >= 11.f)
#define IS_IPHONE_X (IS_IOS_11 && IS_IPHONE && (MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) >= 375 && MAX([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) >= 812))

#define NAVIGATIONBARHEIGHT IS_IPHONE_X ? 88.0f:64.0f

#ifdef DEBUG
#define MLLog(...) NSLog(@"%s 第%d行 \n %@\n\n",__func__,__LINE__,[NSString stringWithFormat:__VA_ARGS__])
#else
#define NSLog(...)
#endif

#define STATUSBARHEIGHT [[UIApplication sharedApplication] statusBarFrame].size.height

#define ScreenW [UIScreen mainScreen].bounds.size.width
#define ScreenH [UIScreen mainScreen].bounds.size.height
@interface ViewController ()<UISearchControllerDelegate,UISearchResultsUpdating,UITableViewDelegate,UITableViewDataSource,ConnectSelectActionDelegate>
{
    BOOL isSearch;
}

@property (strong , nonatomic) UISearchController *searchControl;
@property (strong , nonatomic) NSMutableArray *contactArray;
@property (strong , nonatomic) NSMutableArray *indexArray;
@property (strong , nonatomic) NSMutableArray *searchArray;
@property (strong , nonatomic) UITableView *tableView;

@property (strong , nonatomic) BottomeView *bottom;
@end

static NSString *const ConnectCellID = @"ConnectCell";
@implementation ViewController

- (void)viewWillAppear:(BOOL)animated{
    
    self.view.backgroundColor = [UIColor whiteColor];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGFloat barHieght = NAVIGATIONBARHEIGHT;
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, STATUSBARHEIGHT + self.searchControl.searchBar.frame.size.height, ScreenW, ScreenH-barHieght) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;

    self.tableView.estimatedRowHeight = 50;
    [self.tableView registerClass:[ConnectCell class] forCellReuseIdentifier:ConnectCellID];
    [self.view addSubview:self.tableView];
    
    [self initBottomView];
    [self headerSearchbar];
    [self loadSystemInfomation];
    [self createIndexArray];
    [self createSectionarray];

    [self.indexArray insertObject:@"{search}" atIndex:0];

    NSLog(@"%@",self.contactArray);
    NSLog(@"%@",self.indexArray);


    [self.tableView reloadData];
 
    
   
    MLLog(@"%f", NAVIGATIONBARHEIGHT);
   
  
   
    
}




// 底部数据统计框
- (void)initBottomView{
    
    self.bottom = [[BottomeView alloc] initWithFrame:CGRectMake(0, ScreenH - 60, ScreenW, 60)];
    [self.view addSubview:self.bottom];
    
    [self.view bringSubviewToFront:self.bottom];
    
    self.bottom.selectStatus.text = [NSString stringWithFormat:@"选中%@共%@",@"12",@"15"];

    
}

// 顶部搜索框
- (void)headerSearchbar{
    
    UIView *searchView = [[UIView alloc] initWithFrame:CGRectMake(0, STATUSBARHEIGHT, ScreenW, self.searchControl.searchBar.frame.size.height)];
    searchView.backgroundColor = [UIColor clearColor];
    
    [searchView addSubview:self.searchControl.searchBar];
    [self.view addSubview:searchView];
    
    self.searchControl.hidesNavigationBarDuringPresentation = NO;
    self.definesPresentationContext = NO;
    
}

// 获取到系统通讯录数据
- (void)loadSystemInfomation{
    
    // 1.获取授权状态
    CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];

    // 2.判断授权状态,如果不是已经授权,则直接返回
    if (status != CNAuthorizationStatusAuthorized) return;

    // 1.创建联系人仓库
     CNContactStore *store = [[CNContactStore alloc] init];
    // 2. 创建联系人信息的请求对象
    NSArray * keys = @[CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey];

    // 3.根据请求Key 获取联系人
    CNContactFetchRequest *request = [[CNContactFetchRequest alloc] initWithKeysToFetch:keys];

    [store enumerateContactsWithFetchRequest:request error:nil usingBlock:^(CNContact * _Nonnull contact, BOOL * _Nonnull stop) {
        ConnectModel *model = [[ConnectModel alloc] init];
        // 名字
        NSString *givenName = contact.givenName;
        //性别
        NSString *familyname = contact.familyName;
        NSString *name = [NSString stringWithFormat:@"%@%@",familyname,givenName];

        model.name = name;
    
        NSArray *phoneNumber = contact.phoneNumbers;

        for (CNLabeledValue *values in phoneNumber) {
            CNPhoneNumber *number = values.value;

             NSString *photo = [number.stringValue stringByReplacingOccurrencesOfString:@"-" withString:@""];

            model.phone = photo;
        }

        [self.contactArray addObject:model];
    }];


}



// 创建索引数组
- (void)createIndexArray{
    
    NSMutableArray *array = [NSMutableArray array];
    for (ConnectModel *model in self.contactArray) {
        NSString *pinyin = [self transform:model.name];
        
        if (pinyin) {
            model.initial = pinyin;
            [array addObject:pinyin];
        }
        
    }
    
    // 手写字母去重
    NSMutableArray *preperArray = [NSMutableArray array];
    
    for (int i = 0;i < array.count;i ++) {
        
        if ([preperArray containsObject:[array objectAtIndex:i]] == NO) {
            [preperArray addObject:[array objectAtIndex:i]];
        }
    }
    
    // 把无需的数组使用数组排序方法回归有序
    NSArray *sortedArray = [preperArray sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2];
    }];
    
    self.indexArray = [NSMutableArray arrayWithArray:sortedArray];
    
}


// 根据索引数组 创建Section 数组
- (void)createSectionarray{
    
    NSMutableArray *array = [NSMutableArray array];
    for (NSString *str in self.indexArray) {
        NSMutableArray *sectionArray = [NSMutableArray array];
        for (ConnectModel *model in self.contactArray) {
            if ([model.initial isEqualToString:str]) {
                [sectionArray addObject:model];
            }
        }
        
        [array addObject:sectionArray];
    }
   
    self.contactArray = [NSMutableArray arrayWithArray:array];
    
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return isSearch ? 1 :self.contactArray.count;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return isSearch ? self.searchArray.count : [self.contactArray[section] count];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ConnectCell *cell = [tableView dequeueReusableCellWithIdentifier:ConnectCellID];
    cell.delegate = self;
    
    if (cell == nil) {
        cell = [tableView dequeueReusableCellWithIdentifier:ConnectCellID forIndexPath:indexPath];
    }
    
    if (isSearch) {
        ConnectModel *model = self.searchArray[indexPath.row];
        [cell bindDataSource:model];
    }else{
        NSArray *arr = self.contactArray[indexPath.section];
        ConnectModel *model = arr[indexPath.row];
        [cell bindDataSource:model];
    }
    
    return cell;
}


// 返回索引数组
- (nullable NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    
    return self.indexArray;
}

// 点击索引时候滚动
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{
    
    if ([title isEqualToString:UITableViewIndexSearch]) {
        [tableView setContentOffset:CGPointZero animated:NO];
        
        return NSNotFound;
    }else{
        
         return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index] - 1; // -1 添加了搜索标识
        
    }
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor colorWithRed:230.0f/255.0f green:230.0f/255.0f blue:230.0f/255.0f alpha:1.0f];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 8, 200, 12)];
    label.font = [UIFont systemFontOfSize:14.0f];
    label.textColor = [UIColor  colorWithRed:30.0f/255.0f green:30.0f/255.0f blue:30.0f/255.0f alpha:1.0f];
    
    label.text = isSearch ? @"搜索结果":self.indexArray[section + 1];
    
    [view addSubview:label];
    
    
    
    
    return view;
    
}


// 搜索协议的更新方法

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController{
    
    
    if (self.searchControl.searchBar.text.length) {
        
        if (self.searchControl.isActive) {
            
            [self.searchArray removeAllObjects];
            
            for (NSArray *array in self.contactArray) {
                
                for (ConnectModel *model in array) {
                    
                    NSRange range = [model.name rangeOfString:self.searchControl.searchBar.text];
                  
                    if (range.location != NSNotFound) {
                        
                        [self.searchArray addObject:model];
    
                    }
                    
                }
                
            }
            isSearch = YES;
        }else{
            isSearch = NO;
        }
        
        
    }else{
        isSearch = NO;
    }
    
    [self.tableView reloadData];
    
}



- (void)selectBtnActionWithCell:(ConnectCell *)cell{
    
   NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    
    
    
}








- (UISearchController *)searchControl{
    
    if (!_searchControl) {
        _searchControl = [[UISearchController alloc] initWithSearchResultsController:nil];
        _searchControl.delegate = self;
        [_searchControl.searchBar setValue:@"取消" forKey:@"_cancelButtonText"];
        
        _searchControl.searchBar.placeholder = @"搜索关键字";
        _searchControl.searchResultsUpdater = self;
        _searchControl.dimsBackgroundDuringPresentation = NO;
        [_searchControl.searchBar sizeToFit];
        
        
        _searchControl.searchBar.barStyle = UISearchBarStyleMinimal;
    }
    
    return _searchControl;
}

/**
 汉字转拼音
 @param chinese 传入文字
 @return 返回大写首字母
 */
- (NSString *)transform:(NSString *)chinese {
    if (!chinese.length) {
        
        return nil;
    }
    
    NSMutableString *pinyin = [chinese mutableCopy];
    CFStringTransform((__bridge CFMutableStringRef)pinyin, NULL, kCFStringTransformMandarinLatin, NO);
    CFStringTransform((__bridge CFMutableStringRef)pinyin, NULL, kCFStringTransformStripCombiningMarks, NO);
    
    NSString *oneStr = [pinyin substringToIndex:1];
    
    return [oneStr uppercaseString];;
}



- (NSMutableArray *)contactArray{
    
    if (!_contactArray) {
        _contactArray = [NSMutableArray array];
        
    }
    
    return _contactArray;
}

- (NSMutableArray *)indexArray{
    
    if (!_indexArray) {
        _indexArray = [NSMutableArray array];
    }
    return _indexArray;
}

- (NSMutableArray *)searchArray{
    
    if (!_searchArray) {
        _searchArray = [NSMutableArray array];
    }
    return _searchArray;
}

@end
