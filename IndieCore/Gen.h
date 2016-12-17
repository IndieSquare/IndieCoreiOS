//
//  Gen.h
//  IndieCore
//
//  Created by Chris on 25/10/2016.
//  Copyright © 2016 IndieSquare. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Gen : UIViewController<UIWebViewDelegate>
-(void)startLoad:(UIView*)theView;
@property(nonatomic,strong)IBOutlet UIWebView * webView;
@property(nonatomic,strong)NSString*privateKey;
@end
