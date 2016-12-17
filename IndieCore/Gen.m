//
//  Gen.m
//  IndieCore
//
//  Created by Chris on 25/10/2016.
//  Copyright © 2016 IndieSquare. All rights reserved.
//

#import "Gen.h"

@interface Gen ()

@end

@implementation Gen

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)startLoad:(UIView*)theView{
  
           self.webView = [[UIWebView alloc] initWithFrame:theView.frame];
        
        //load function.html this contains the bitcoin library bitlib.js
        
        
        self.webView.delegate = self;
        //   self.webView.hidden = true; //hide webview so it runs unnoticed to the user
        [theView addSubview:self.webView];
        
      //  NSURL *theURL = [NSURL fileURLWithPath:@"http://google.com"];
    NSURL *theURL = [NSURL URLWithString:@"https://www.google.com"];

 [self.webView loadRequest:[NSURLRequest requestWithURL:theURL]];
        NSLog(@"exists");
        
    
    
    
}


- (void) webViewDidFinishLoad:(UIWebView *)webView
{
    
    // webViewDidLoad = true; //can only run functions when bitcoin library bitlib has loaded into webview
    
    NSLog(@"loaded");
    
    
    
    
}
/*
//intercepts the returned data from the webview
- (BOOL)webView:(UIWebView *)webView
shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType {
    
    NSLog(@"start load");

    if([request.URL.absoluteString rangeOfString:@"private_key"].location != NSNotFound){
        
        NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:request.URL
                                                    resolvingAgainstBaseURL:NO];
        NSArray *queryItems = urlComponents.queryItems;
        self.privateKey = [self valueForKey:@"private_key"
                             fromQueryItems:queryItems];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Private key is"
                                                        message:self.privateKey
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
    }
    
    if([request.URL.absoluteString rangeOfString:@"signature"].location != NSNotFound){
        
        NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:request.URL
                                                    resolvingAgainstBaseURL:NO];
        NSArray *queryItems = urlComponents.queryItems;
        
        
        NSString * message = [self valueForKey:@"message"
                                fromQueryItems:queryItems];
        NSString * signature = [self valueForKey:@"signature"
                                  fromQueryItems:queryItems];
        NSString * publicKey = [self valueForKey:@"public_key"
                                  fromQueryItems:queryItems];
        
        NSLog(@"message:%@\nsignature:%@\npublic key:%@",message,signature,publicKey);
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Signature and Public key"
                                                        message:[NSString stringWithFormat:@"message is\n\n%@\n\nsignature is\n\n%@\n\npublic key is\n\n%@",message,signature,publicKey]
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
    }
    
    
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
