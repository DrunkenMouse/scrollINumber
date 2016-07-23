//
//  ViewController.m
//  数字的滚动显示
//
//  Created by 王奥东 on 16/7/5.
//  Copyright © 2016年 王奥东. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UIPickerViewDataSource,UIPickerViewDelegate>

//保存滚动后的数字
@property(nonatomic,strong)NSMutableArray *array;

//保存显示滚动数字的Label
@property(nonatomic,strong)UILabel *numLabel;

//添加一个耗时操作
@property(nonatomic,strong)NSOperationQueue *queue;

//保存pickerView
@property(nonatomic,strong)UIPickerView *pickerV;

@end

@implementation ViewController

//懒加载方式创建队列queue
-(NSOperationQueue *)queue{
    if (!_queue) {
        _queue = [NSOperationQueue new];
    }
    return _queue;
}

//懒加载方式初始化数组，默认值为：0 0 0
-(NSMutableArray *)array{
    if (_array == nil) {
        _array = [NSMutableArray array];
        for (int i=0; i<3; i++) {
            [_array addObject:@"0"];
        }
    }
    return _array;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.view.backgroundColor = [UIColor orangeColor];

    //设置并添加滚动的PickerView
    UIPickerView *pickerV = [[UIPickerView alloc]initWithFrame:CGRectMake(100, 200, 210,50)];
    
    //设置pickerView的边框
    pickerV.layer.borderColor = [UIColor grayColor].CGColor;
    pickerV.layer.borderWidth = 1;
 
    
    pickerV.delegate = self;
    pickerV.dataSource = self;
    [self.view addSubview:pickerV];
    self.pickerV = pickerV;
    
    
    //保存滚动结束后的数值
    UILabel *numLabel = [[UILabel alloc]initWithFrame:CGRectMake(150, CGRectGetMaxY(pickerV.frame)+20, 80, 50)];
    //默认值为0 0 0
    numLabel.text = @"0  0  0";
    //保存显示数值的Label
    self.numLabel = numLabel;
    [self.view addSubview:numLabel];
    
    //开始按钮的设置与添加
    UIButton *startButton = [[UIButton alloc]initWithFrame:CGRectMake(50, 200, 88, 44)];
    [startButton setTitle:@"开始" forState:UIControlStateNormal];
    [startButton addTarget:self action:@selector(clickStartButton:) forControlEvents:UIControlEventTouchUpInside];
    [startButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.view addSubview:startButton];

    
   
    
}

//开启按钮的点击
-(void)clickStartButton:(UIButton *)sender {
    
    //判断队列中是否有操作
    //如果没有就添加，如果有就将操作暂停
    if (self.queue.operationCount == 0) {
        //添加一个操作
        [self.queue addOperationWithBlock:^{
           
            [self random];
        }];
        //如果操作被暂停，回复操作的暂停
        //如果没有，那就么有~
        //并改变按钮的显示
        [self.queue setSuspended:NO];
        [sender setTitle:@"暂停" forState:UIControlStateNormal];
        
    }else{
        //改变按钮的显示并暂停操作
        [sender setTitle:@"开始" forState:UIControlStateNormal];
        [self.queue setSuspended:YES];
        
    }
    
}

//操作中执行的方法
-(void)random{
    //如果操作没有被暂停就执行
    while (!self.queue.suspended) {
     
        //当前线程休息0.1秒
        [NSThread sleepForTimeInterval:0.3];
        
        //随机生成三个0~9的数字
        int num1 = arc4random_uniform(10);
        int num2 = arc4random_uniform(10);
        int num3 = arc4random_uniform(10);
       
      
       
        
        //让pickerView的三个列滚动
        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
//         滚动某列的行数为某行
            [self.pickerV selectRow:num1 inComponent:0 animated:YES];
            [self.pickerV selectRow:num2 inComponent:1 animated:YES];
            [self.pickerV selectRow:num3 inComponent:2 animated:YES];
           
//            设置Label的值
            self.numLabel.text = [NSString stringWithFormat:@"%d  %d  %d",num1,num2,num3];
        }];
       
    }
    
}


//返回列
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
   
    
    return 3;
}

//返回行
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    
    //经测试发现，返回行数的时候会返回一条下划线
    //所以为了盖住PickerView默认显示的下划线需要在返回行中书写
    //设置一个盖住分割线的LineView
    UIView *LineView = [[UIView alloc]initWithFrame:CGRectMake(0, 37, pickerView.frame.size.width, 2)];
    LineView.backgroundColor = self.view.backgroundColor;
    [pickerView addSubview:LineView];
   
    return 10;
}

//返回每行的数据
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    
    
  
    
    //第几回就返回字符串几，如第1行返回@”1“
    return [NSString stringWithFormat:@"%ld",(long)row];
  

}


//滚动结束后调用此方法
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    //保存某列在滚动结束后显示的行数
    self.array[component] = [NSString stringWithFormat:@"%ld",[pickerView selectedRowInComponent:component]];
    //数组里的数据拼接成字符串，间隔符为@“   ”
    NSString *str = [self.array componentsJoinedByString:@"  "];
    //设置显示Label的数据为滚动后的数值
    self.numLabel.text = str;
}



@end
