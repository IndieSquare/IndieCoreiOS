#import "IndieCore.h"
#include <stdlib.h>
@implementation IndieCore

-(id)initWithViewController:(UIViewController*)parentVC andAPIKey:(NSString *)apiKey andTestNet:(bool)testnet andCompletion:(completionBlock)completionBlock{
    self = [super init];
    if(self){
        
        self.currentCompletion = completionBlock;
        self.webView = [[UIWebView alloc] initWithFrame:parentVC.view.frame];
        
        self.webView.delegate = self;
        self.apiKey = apiKey;
        self.webView.hidden = true; //hide webview so it runs unnoticed to the user
        [parentVC.view addSubview:self.webView];
        self.base = @"https://indiesquare.me";
        self.testnet = testnet;
          self.baseUrl = @"https://api.indiesquare.me/v2/";
        if(testnet){
            
            self.baseUrl = @"https://apitestnet.indiesquare.me/v2/";
        }
       
        [self loadfunctions];
        
    }
    return self;
}
-(void)linkageWallet:(NSDictionary*)params andChannel:(NSString*)channel andUrlScheme:(NSString*)MyUrlScheme{
   
    
    NSString * request = [params objectForKey:@"request"];
    NSString * nonce = [[NSProcessInfo processInfo] globallyUniqueString];
    NSMutableDictionary * newParams =  [NSMutableDictionary dictionaryWithObjectsAndKeys:channel,@"channel",nonce,@"nonce",MyUrlScheme,@"x-success", nil];
    
    if([request isEqualToString:@"sign"]){
        [newParams setObject:[params objectForKey:@"unsigned_hex"] forKey:@"unsigned_hex"];
    }
    
    NSString *jsonRequest =  [[self dictionaryToJSON:newParams] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
   
   NSString * urlParams = [NSString stringWithFormat:@"%@?params=%@",request,jsonRequest];
    
    if([request isEqualToString:@"getaddress"] || [request isEqualToString:@"verifyuser"]){
       NSString * xcallback_params = [NSString stringWithFormat:@"channel=%@&nonce=%@&x-success=%@&msg=%@",channel,nonce,MyUrlScheme,channel];
        
        
      urlParams = [NSString stringWithFormat:@"x-callback-url/%@?%@",request,xcallback_params];
    }
  
 
    NSString * url  =[NSString stringWithFormat:@"indiewallet://%@",urlParams];
  
    NSURL * theurl = [NSURL URLWithString: url];
    
    
    [[UIApplication sharedApplication] openURL:theurl];
    
    
    
    
    
}
-(void)signTransactionWithWallet:(NSString*)myUrlScheme andTx:(NSString *)unsignedTx andCompletion:(completionBlock)completionBlock{
    
    NSString* channel = [NSString stringWithFormat:@"indie-%@",[[NSProcessInfo processInfo] globallyUniqueString]];
    
    [self pubsub:channel andParams:[NSDictionary dictionaryWithObjectsAndKeys:@"sign",@"request",unsignedTx,@"unsigned_hex", nil] andUrlScheme:myUrlScheme andCompletion:^(NSError *error, NSDictionary *response) {
        
        completionBlock(error,response);
        
    }];
}
-(void)getAddressFromWallet:(NSString*)myUrlScheme andCompletion:(completionBlock)completionBlock{
    
    NSString* channel = [NSString stringWithFormat:@"indie-%@",[[NSProcessInfo processInfo] globallyUniqueString]];
    
    [self pubsub:channel andParams:[NSDictionary dictionaryWithObjectsAndKeys:@"getaddress",@"request", nil] andUrlScheme:myUrlScheme andCompletion:^(NSError *error, NSDictionary *response) {
        
        NSDictionary * data = [response objectForKey:@"data"];
        if(data != NULL){
            NSString * address = [data objectForKey:@"address"];
          
            NSString * signature = [data objectForKey:@"signature"];
            
            [self verifyMessage:channel andSignature:signature andAddress:address andCompletion:^(NSError*error, NSDictionary *response) {
                if(error != NULL){
                      completionBlock(error,response);
                }else{
                    
                    if([[response objectForKey:@"verified"] isEqualToString:@"true"]){
                        
                        completionBlock(NULL,[NSDictionary dictionaryWithObjectsAndKeys:address,@"address", nil]);
                    }else{
                         completionBlock([NSError errorWithDomain:@"IndieCore"  code:100 userInfo:@{ NSLocalizedDescriptionKey:@"error verifying address" }],NULL);
                    }
                    
                }
                
            }];
        }
        
        
      
        
    }];
}

-(void)pubsub:(NSString*)channel andParams:(NSDictionary*)params andUrlScheme:(NSString*)myUrlScheme andCompletion:(completionBlock)completionBlock{
 
    
    NSString* postString = [NSString stringWithFormat:@"channel=%@",channel];
   
    [self postAsyncObject:[NSString stringWithFormat:@"%@/pubsub/topic",self.base] andPost:postString andCompletion:^(NSError *error, NSDictionary *response) {
        
        if(error != NULL){
            completionBlock(error,NULL);
        }
        [self linkageWallet:params andChannel:channel andUrlScheme:myUrlScheme];
        
         NSString* postString = [NSString stringWithFormat:@"channel=%@&type=1",channel];
       
        
        [self postAsyncObject:[NSString stringWithFormat:@"%@/pubsub/subscribe",self.base] andPost:postString andCompletion:^(NSError *error, NSDictionary *response) {
            
            if(error != NULL){
                completionBlock(error,NULL);
            }
            
              completionBlock(NULL,response);
            
        }];
        
    }];
}

-(void)loadfunctions{
    NSString * path = [[NSBundle mainBundle] pathForResource:@"IndieCore.bundle/functions" ofType:@"html"];
    if([[NSFileManager defaultManager] fileExistsAtPath:path]){
        
        NSURL *theURL = [NSURL fileURLWithPath:path];
        
        
        [self.webView loadRequest:[NSURLRequest requestWithURL:theURL]];
        
    }else{
        NSString * path = [[NSBundle mainBundle] pathForResource:@"functions" ofType:@"html"];
        if([[NSFileManager defaultManager] fileExistsAtPath:path]){
            
            NSURL *theURL = [NSURL fileURLWithPath:path];
            
            
            [self.webView loadRequest:[NSURLRequest requestWithURL:theURL]];
            
        }else{
            
            NSLog(@"error budle not found");
            NSString* filePath = [[NSBundle mainBundle] pathForResource:@"functions"
                                                                 ofType:@"html"];
              NSLog(@"what %@",filePath);
        }
        NSLog(@"error budle not found");
    }

}

- (NSString *)valueForKey:(NSString *)key
           fromQueryItems:(NSArray *)queryItems
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name=%@", key];
    NSURLQueryItem *queryItem = [[queryItems
                                  filteredArrayUsingPredicate:predicate]
                                 firstObject];
    return queryItem.value;
}

- (void) webViewDidFinishLoad:(UIWebView *)webView
{
    
    if(self.webViewLoaded == false){
        self.webViewLoaded = true;
        
        if(self.currentCompletion != NULL){
        
            self.currentCompletion(NULL, [NSDictionary dictionaryWithObjectsAndKeys:@"true",@"initialized" ,nil]);
        }
     
        self.currentCompletion = NULL;
    }
    
}


-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    if(self.webViewLoaded == false){
        if(self.currentCompletion != NULL){
            self.currentCompletion(error, [NSDictionary dictionaryWithObjectsAndKeys:@"false",@"initialized" ,nil]);
        }
        
        self.currentCompletion = NULL;
    }
}
//intercepts the returned data from the webview
- (BOOL)webView:(UIWebView *)webView
shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType {
    
    
    if([request.URL.absoluteString rangeOfString:@"sign_transaction"].location != NSNotFound){
        
        NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:request.URL
                                                    resolvingAgainstBaseURL:NO];
        NSArray *queryItems = urlComponents.queryItems;
        NSString * res = [self valueForKey:@"sign_transaction"
                            fromQueryItems:queryItems];
        
        if([res rangeOfString:@"error"].location != NSNotFound){
            [self.delegate signTransactionError:res];
        }else{
            [self.delegate didSignTransaction:res];
        }
        
        self.currentCompletion(NULL, [NSDictionary dictionaryWithObjectsAndKeys:res,@"tx",nil]);
        
        [self loadfunctions];
        self.currentCompletion = NULL;
        
    }
    
    if([request.URL.absoluteString rangeOfString:@"address_passphrase"].location != NSNotFound){
        
        NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:request.URL
                                                    resolvingAgainstBaseURL:NO];
        NSArray *queryItems = urlComponents.queryItems;
        NSString * res = [self valueForKey:@"address_passphrase"
                            fromQueryItems:queryItems];
        
        
        self.currentCompletion(NULL, [NSDictionary dictionaryWithObjectsAndKeys:res,@"address",nil]);
        
        [self loadfunctions];
        self.currentCompletion = NULL;
        
    }
    
    if([request.URL.absoluteString rangeOfString:@"random_wallet"].location != NSNotFound){
        
        NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:request.URL
                                                    resolvingAgainstBaseURL:NO];
        NSArray *queryItems = urlComponents.queryItems;
        NSString * priv_key = [self valueForKey:@"priv_key"
                            fromQueryItems:queryItems];
        
        NSString * priv_key_wif = [self valueForKey:@"wif"
                                 fromQueryItems:queryItems];
        
        NSString * public_key = [self valueForKey:@"public_key"
                                     fromQueryItems:queryItems];
        
        NSString * address = [self valueForKey:@"address"
                                   fromQueryItems:queryItems];

        self.currentCompletion(NULL, [NSDictionary dictionaryWithObjectsAndKeys:priv_key,@"priv_key",priv_key_wif,@"wif",public_key,@"public_key",address,@"address" ,nil]);
        
         [self loadfunctions];
        self.currentCompletion = NULL;
        
    }
    
    
    if([request.URL.absoluteString rangeOfString:@"create_passphrase"].location != NSNotFound){
        
        NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:request.URL
                                                    resolvingAgainstBaseURL:NO];
        NSArray *queryItems = urlComponents.queryItems;
        NSString * res = [self valueForKey:@"create_passphrase"
                            fromQueryItems:queryItems];
        
        
        
        self.currentCompletion(NULL, [NSDictionary dictionaryWithObjectsAndKeys:res,@"wallet", nil]);
        
        
        [self loadfunctions];
        self.currentCompletion = NULL;
    }
    
    if([request.URL.absoluteString rangeOfString:@"token_name"].location != NSNotFound){
        
        NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:request.URL
                                                    resolvingAgainstBaseURL:NO];
        NSArray *queryItems = urlComponents.queryItems;
        NSString * res = [self valueForKey:@"token_name"
                            fromQueryItems:queryItems];
        
        
        
        self.currentCompletion(NULL, [NSDictionary dictionaryWithObjectsAndKeys:res,@"name", nil]);
        
 
    [self loadfunctions];
    self.currentCompletion = NULL;
        
        
    }

    
    if([request.URL.absoluteString rangeOfString:@"address_valid"].location != NSNotFound){
        
        NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:request.URL
                                                    resolvingAgainstBaseURL:NO];
        NSArray *queryItems = urlComponents.queryItems;
        NSString * res = [self valueForKey:@"address_valid"
                            fromQueryItems:queryItems];
        
        
        self.currentCompletion(NULL,  [NSDictionary dictionaryWithObjectsAndKeys:res,@"verified", nil]);
        
         [self loadfunctions];
        self.currentCompletion = NULL;
    }
    
 
    if([request.URL.absoluteString rangeOfString:@"sign_message"].location != NSNotFound){
      
        NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:request.URL
                                                    resolvingAgainstBaseURL:NO];
        NSArray *queryItems = urlComponents.queryItems;
        
        
        NSString *status = [self valueForKey:@"sign_message"
                                  fromQueryItems:queryItems];
        NSString * signature = [self valueForKey:@"signature"
                                  fromQueryItems:queryItems];
         
        if([status isEqualToString:@"true"]){
            
            self.currentCompletion(NULL,  [NSDictionary dictionaryWithObjectsAndKeys:signature,@"sig", nil]);
        
        }
        else{
           
            self.currentCompletion([NSError errorWithDomain:@"IndieCore"  code:100 userInfo:@{ NSLocalizedDescriptionKey:@"error signing" }],  [NSDictionary dictionaryWithObjectsAndKeys:@"error signing",@"sig", nil]);
            
        }
        [self loadfunctions];
       self.currentCompletion = NULL;
        
    }
    
    if([request.URL.absoluteString rangeOfString:@"verify_message"].location != NSNotFound){
        
        NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:request.URL
                                                    resolvingAgainstBaseURL:NO];
        NSArray *queryItems = urlComponents.queryItems;
        
        
        NSString *status = [self valueForKey:@"verify_message"
                              fromQueryItems:queryItems];
       
        
        if([status isEqualToString:@"true"]){
            
            self.currentCompletion(NULL,  [NSDictionary dictionaryWithObjectsAndKeys:@"true",@"verified", nil]);
            
        }
        else{
            
            self.currentCompletion(NULL, [NSDictionary dictionaryWithObjectsAndKeys:@"false",@"verified", nil]);
            
        }
         [self loadfunctions];
        self.currentCompletion = NULL;
        
    }
    
   
    
    
    return YES;
}
-(BOOL)checkCompletion:(completionBlock)completionBlock{
    if(self.currentCompletion != NULL){
        
        completionBlock([NSError errorWithDomain:@"IndieCore"  code:100 userInfo:@{ NSLocalizedDescriptionKey:@"another task is already running" }],[NSDictionary dictionaryWithObjectsAndKeys:@"another task is already running",@"error", nil]);
        return false;
    }
    
    self.currentCompletion = completionBlock;
    
    if(self.webViewLoaded == false){
        
        
        completionBlock([NSError errorWithDomain:@"IndieCore"  code:100 userInfo:@{ NSLocalizedDescriptionKey:@"IndieCore not initialized" }],[NSDictionary dictionaryWithObjectsAndKeys:@"error",@"error", nil]);
         return false;
    }
     return true;
}

-(void)signMessage:(NSString*)message andPassphrase:(NSString*)passphrase andIndex:(int)index andCompletion:(completionBlock)completionBlock{
    if(![self checkCompletion:completionBlock]){
        return;
    }
    
    NSString * request = [NSString stringWithFormat:@"signMessage(\"%@\",%d,\"%@\")",passphrase,index,message];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.webView stringByEvaluatingJavaScriptFromString:request];
        
    });
    
}
-(void)verifyMessage:(NSString*)message andSignature:(NSString*)signature andAddress:(NSString*)address andCompletion:(completionBlock)completionBlock{
    
    if(![self checkCompletion:completionBlock]){
        return;
    }
    
    
    NSString * request = [NSString stringWithFormat:@"verifyMessage(\"%@\",\"%@\",\"%@\")",message,signature,address];
    
    dispatch_async(dispatch_get_main_queue(), ^{
           
        [self.webView stringByEvaluatingJavaScriptFromString:request];
        
    });
    
}

-(void)signTransacation:(NSString*)tx andPassphrase:(NSString*)passphrase andIndex:(int)index andDestination:(NSString*)destination andCompletion:(completionBlock)completionBlock{
    if(![self checkCompletion:completionBlock]){
        return;
    }
    
    NSString * request = [NSString stringWithFormat:@"signTransaction(\"%@\",%d,\"%@\",\"%@\",\"%@\",\"%@\")",passphrase,index,tx,destination,self.apiKey,self.baseUrl];
   
     dispatch_async(dispatch_get_main_queue(), ^{
    
         [self.webView stringByEvaluatingJavaScriptFromString:request];
         
     });
    
}

-(void)signTransacation:(NSString*)tx andPassphrase:(NSString*)passphrase andIndex:(int)index andCompletion:(completionBlock)completionBlock{
    
    if(![self checkCompletion:completionBlock]){
        return;
    }
    
    NSString * request = [NSString stringWithFormat:@"signTransactionNoDest(\"%@\",%d,\"%@\",\"%@\",\"%@\")",passphrase,index,tx,self.apiKey,self.baseUrl];

    
    dispatch_async(dispatch_get_main_queue(), ^{
    
        [self.webView stringByEvaluatingJavaScriptFromString:request];
    
        
    });
    
}

-(void)generateRandomDetailedWallet:(completionBlock)completionBlock{
   
    if(![self checkCompletion:completionBlock]){
        return;
    }
    
    [self.webView stringByEvaluatingJavaScriptFromString:@"createRandomDetailedWallet()"];

}
-(void)createNewWallet:(completionBlock)completionBlock{
    if(![self checkCompletion:completionBlock]){
        return;
    }
    [self.webView stringByEvaluatingJavaScriptFromString:@"createNewPassphrase()"];
    
}
-(void)checkIfAddressIsValid:(NSString *)address andCompletion:(completionBlock)completionBlock{
    
    if(![self checkCompletion:completionBlock]){
        return;
    }
        
    NSString * request = [NSString stringWithFormat:@"isValidBitcoinAddress(\"%@\")",address];
    
    [self.webView stringByEvaluatingJavaScriptFromString:request];
        

}
-(void)generateAddressForPassphrase:(NSString*)passphrase andIndex:(int)index andCompletion:(completionBlock)completionBlock{
    if(![self checkCompletion:completionBlock]){
        return;
    }
    
    
    NSString * request = [NSString stringWithFormat:@"getAddressForPassphrase(\"%@\",%d)",passphrase,index];
    
    [self.webView stringByEvaluatingJavaScriptFromString:request];
    
}


-(NSString*)dictionaryToJSON:(NSDictionary *)dic{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    if (! jsonData) {
        NSLog(@"bv_jsonStringWithPrettyPrint: error: %@", error.localizedDescription);
        return @"{}";
    } else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}
-(NSDictionary*)JSONToDictionary:(NSString*)json{
    
    NSData *jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    
    //    Note that JSONObjectWithData will return either an NSDictionary or an NSArray, depending whether your JSON string represents an a dictionary or an array.
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
    
    if (error) {
        NSLog(@"Error parsing JSON: %@", error);
    }
    else
    {
        
        
        NSDictionary *jsonDictionary = (NSDictionary *)jsonObject;
        return jsonDictionary;
        
    }
    
    return NULL;
}





-(void)createSendTransaction:(NSString*)source andTokenName:(NSString*)token andDestination:(NSString*)destination andQuantity:(double)quantity andCompletion:(completionBlock)completionBlock{
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSDictionary* response = [self createSendTransactionMaster:source andTokenName:token andDestination:destination andQuantity:quantity andFee:-1 andFeePerKB:-1];
        NSString * status = [response objectForKey:@"status"];
        if(![status isEqualToString:@"error"]){
            completionBlock(NULL, response);
        }else{
            completionBlock( [NSError errorWithDomain:@"IndieCore"  code:100 userInfo:@{ NSLocalizedDescriptionKey:response }], response);
        }
        
        
    });

}

-(void)createSendTransaction:(NSString*)source andTokenName:(NSString*)token andDestination:(NSString*)destination andQuantity:(double)quantity andFee:(int)fee andCompletion:(completionBlock)completionBlock{
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSDictionary* response = [self createSendTransactionMaster:source andTokenName:token andDestination:destination andQuantity:quantity andFee:fee andFeePerKB:-1];
        NSString * status = [response objectForKey:@"status"];
        if(![status isEqualToString:@"error"]){
            completionBlock(NULL, response);
        }else{
            completionBlock( [NSError errorWithDomain:@"IndieCore"  code:100 userInfo:@{ NSLocalizedDescriptionKey:response }], response);
        }
        
        
    });

}

-(void)createSendTransaction:(NSString*)source andTokenName:(NSString*)token andDestination:(NSString*)destination andQuantity:(double)quantity andFeePerKB:(int)feePerKB andCompletion:(completionBlock)completionBlock{
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSDictionary* response = [self createSendTransactionMaster:source andTokenName:token andDestination:destination andQuantity:quantity andFee:-1 andFeePerKB:feePerKB];
        NSString * status = [response objectForKey:@"status"];
        if(![status isEqualToString:@"error"]){
            completionBlock(NULL, response);
        }else{
            completionBlock( [NSError errorWithDomain:@"IndieCore"  code:100 userInfo:@{ NSLocalizedDescriptionKey:response }], response);
        }
        
        
    });
    
}

-(NSDictionary*)createSendTransactionMaster:(NSString*)source andTokenName:(NSString*)token andDestination:(NSString*)destination andQuantity:(double)quantity andFee:(int)fee andFeePerKB:(int)feePerKB{
    
    NSMutableDictionary * tmpDic = [[NSMutableDictionary alloc] init];
    [tmpDic setObject:source forKey:@"source"];
    [tmpDic setObject:token forKey:@"token"];
     [tmpDic setObject:destination forKey:@"destination"];
    [tmpDic setObject:[NSNumber numberWithDouble:quantity] forKey:@"quantity"];
    
    if(feePerKB != -1){
        [tmpDic setObject:[NSNumber numberWithInt:feePerKB] forKey:@"fee_per_kb"];
    }
    if(fee != -1){
        [tmpDic setObject:[NSNumber numberWithInt:fee] forKey:@"fee"];
    }
    
    NSDictionary *postDic = [NSDictionary dictionaryWithDictionary:tmpDic];
    
    NSString *jsonRequest = [self dictionaryToJSON:postDic];
    
    NSDictionary * res = [self post:jsonRequest url:[NSString stringWithFormat:@"%@transactions/send",self.baseUrl]  andIsJSON:true];
    
    NSString * httpStatus = [res objectForKey:@"httpStatus"];
    
    NSString * resString = [res objectForKey:@"response"];
    
    if(![httpStatus isEqualToString:@"200"]){
        
        if(resString != NULL){
            NSDictionary * dic = [self JSONToDictionary:resString];
            if([dic objectForKey:@"message"]){
                NSString * message = [dic objectForKey:@"message"];
                NSDictionary * returnDic = [NSDictionary dictionaryWithObjectsAndKeys:@"error",@"status",message,@"response", nil];
                return returnDic;
            }
        }
        NSDictionary * returnDic = [NSDictionary dictionaryWithObjectsAndKeys:@"error",@"status",@"error creating send transaction",@"response", nil];
        return returnDic;
    }
    
    
    NSDictionary * returnDic = [NSDictionary dictionaryWithObjectsAndKeys:@"success",@"status",resString,@"response", nil];
    
    return returnDic;
    
}


-(void)createOrderTransaction:(NSString*)source andGiveQuantity:(double)giveQuantity andGiveToken:(NSString*)giveToken andGetQuantity:(double)getQuantity andGetToken:(NSString*)getToken andExpiration:(int)expiration andCompletion:(completionBlock)completionBlock{
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSDictionary* response = [self createOrderTransactionMaster:source andGiveQuantity:giveQuantity andGiveToken:giveToken andGetQuantity:getQuantity andGetToken:getToken andExpiration:expiration andFee:-1 andFeePerKB:-1];
        
        NSString * status = [response objectForKey:@"status"];
        if(![status isEqualToString:@"error"]){
            completionBlock(NULL, response);
        }else{
            completionBlock( [NSError errorWithDomain:@"IndieCore"  code:100 userInfo:@{ NSLocalizedDescriptionKey:response }], response);
        }
        
        
    });
    
}

-(void)createOrderTransaction:(NSString*)source andGiveQuantity:(double)giveQuantity andGiveToken:(NSString*)giveToken andGetQuantity:(double)getQuantity andGetToken:(NSString*)getToken andExpiration:(int)expiration andFee:(int)fee andCompletion:(completionBlock)completionBlock{
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSDictionary* response = [self createOrderTransactionMaster:source andGiveQuantity:giveQuantity andGiveToken:giveToken andGetQuantity:getQuantity andGetToken:getToken andExpiration:expiration andFee:fee andFeePerKB:-1];
        
        NSString * status = [response objectForKey:@"status"];
        if(![status isEqualToString:@"error"]){
            completionBlock(NULL, response);
        }else{
            completionBlock([NSError errorWithDomain:@"IndieCore"  code:100 userInfo:@{ NSLocalizedDescriptionKey:response }], response);
        }
        
        
    });

}

-(void)createOrderTransaction:(NSString*)source andGiveQuantity:(double)giveQuantity andGiveToken:(NSString*)giveToken andGetQuantity:(double)getQuantity andGetToken:(NSString*)getToken andExpiration:(int)expiration andFeePerKB:(int)feePerKB andCompletion:(completionBlock)completionBlock{
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
       
        NSDictionary* response = [self createOrderTransactionMaster:source andGiveQuantity:giveQuantity andGiveToken:giveToken andGetQuantity:getQuantity andGetToken:getToken andExpiration:expiration andFee:-1 andFeePerKB:feePerKB];
        
        NSString * status = [response objectForKey:@"status"];
        if(![status isEqualToString:@"error"]){
            completionBlock(NULL, response);
        }else{
            completionBlock([NSError errorWithDomain:@"IndieCore"  code:100 userInfo:@{ NSLocalizedDescriptionKey:response }], response);
        }
        
        
    });

    
}


-(NSDictionary*)createOrderTransactionMaster:(NSString*)source andGiveQuantity:(double)giveQuantity andGiveToken:(NSString*)giveToken andGetQuantity:(double)getQuantity andGetToken:(NSString*)getToken andExpiration:(int)expiration andFee:(int)fee andFeePerKB:(int)feePerKB {
    
    
    NSMutableDictionary * tmpDic = [[NSMutableDictionary alloc] init];
    [tmpDic setObject:source forKey:@"source"];
    [tmpDic setObject:[NSNumber numberWithDouble: giveQuantity] forKey:@"give_quantity"];
    [tmpDic setObject:giveToken forKey:@"give_token"];
    [tmpDic setObject:[NSNumber numberWithDouble:getQuantity] forKey:@"get_quantity"];
    [tmpDic setObject:getToken forKey:@"get_token"];
    [tmpDic setObject:[NSNumber numberWithInt:expiration] forKey:@"expiration"];

    if(feePerKB != -1){
        [tmpDic setObject:[NSNumber numberWithInt:feePerKB] forKey:@"fee_per_kb"];
    }
    if(fee != -1){
        [tmpDic setObject:[NSNumber numberWithInt:fee] forKey:@"fee"];
    }
    
    NSDictionary *postDic = [NSDictionary dictionaryWithDictionary:tmpDic];
    
    NSString *jsonRequest = [self dictionaryToJSON:postDic];
   
    NSDictionary * res = [self post:jsonRequest url: [NSString stringWithFormat:@"%@transactions/order",self.baseUrl] andIsJSON:true];
    
    NSString * httpStatus = [res objectForKey:@"httpStatus"];
    
    NSString * resString = [res objectForKey:@"response"];
    
    if(![httpStatus isEqualToString:@"200"]){
        
        if(resString != NULL){
            NSDictionary * dic = [self JSONToDictionary:resString];
            if([dic objectForKey:@"message"]){
                NSString * message = [dic objectForKey:@"message"];
                NSDictionary * returnDic = [NSDictionary dictionaryWithObjectsAndKeys:@"error",@"status",message,@"response", nil];
                return returnDic;
            }
        }
        NSDictionary * returnDic = [NSDictionary dictionaryWithObjectsAndKeys:@"error",@"status",@"error creating order transaction",@"response", nil];
        return returnDic;
    }
    
    
    NSDictionary * returnDic = [NSDictionary dictionaryWithObjectsAndKeys:@"success",@"status",resString,@"response", nil];
    
    return returnDic;
    
    
    

    
    
}





-(void)cancelOrder:(NSString*)source andOfferHash:(NSString*)offerHash andCompletion:(completionBlock)completionBlock{
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSDictionary* response = [self cancelOrderMaster:source andOfferHash:offerHash andFee:-1 andFeePerKB:-1];
        
        NSString * status = [response objectForKey:@"status"];
        if(![status isEqualToString:@"error"]){
            completionBlock(NULL, response);
        }else{
            completionBlock([NSError errorWithDomain:@"IndieCore"  code:100 userInfo:@{ NSLocalizedDescriptionKey:response }], response);
        }
        
        
    });
    
    
}

-(void)cancelOrder:(NSString*)source andOfferHash:(NSString*)offerHash andFeePerKB:(int)feePerKB andCompletion:(completionBlock)completionBlock{
    
      dispatch_async(dispatch_get_global_queue(0, 0), ^{
    NSDictionary* response = [self cancelOrderMaster:source andOfferHash:offerHash andFee:-1 andFeePerKB:feePerKB];
    
    NSString * status = [response objectForKey:@"status"];
    if(![status isEqualToString:@"error"]){
        completionBlock(NULL, response);
    }else{
        completionBlock([NSError errorWithDomain:@"IndieCore"  code:100 userInfo:@{ NSLocalizedDescriptionKey:response }], response);
    }
    
    
      });


}

-(void)cancelOrder:(NSString*)source andOfferHash:(NSString*)offerHash andFee:(int)fee andCompletion:(completionBlock)completionBlock{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSDictionary* response = [self cancelOrderMaster:source andOfferHash:offerHash andFee:fee andFeePerKB:-1];
                                  
                                  NSString * status = [response objectForKey:@"status"];
                                  if(![status isEqualToString:@"error"]){
                                      completionBlock(NULL, response);
                                  }else{
                                      completionBlock([NSError errorWithDomain:@"IndieCore"  code:100 userInfo:@{ NSLocalizedDescriptionKey:response }], response);
                                  }
                                  
                                  
                                  });
    
}

-(NSDictionary*)cancelOrderMaster:(NSString*)source andOfferHash:(NSString*)offerHash andFee:(int)fee andFeePerKB:(int)feePerKB{

    
    
   
    
    
    NSMutableDictionary * tmpDic = [[NSMutableDictionary alloc] init];
    [tmpDic setObject:source forKey:@"source"];
    [tmpDic setObject:offerHash forKey:@"offer_hash"];
    if(feePerKB != -1){
        [tmpDic setObject:[NSNumber numberWithInt:feePerKB] forKey:@"fee_per_kb"];
    }
    if(fee != -1){
        [tmpDic setObject:[NSNumber numberWithInt:fee] forKey:@"fee"];
    }
    
    NSDictionary *postDic = [NSDictionary dictionaryWithDictionary:tmpDic];
    
    NSString *jsonRequest = [self dictionaryToJSON:postDic];
    
    NSDictionary * res = [self post:jsonRequest url: [NSString stringWithFormat:@"%@transactions/cancel",self.baseUrl] andIsJSON:true];
    
    NSString * httpStatus = [res objectForKey:@"httpStatus"];
    
    NSString * resString = [res objectForKey:@"response"];
    
    if(![httpStatus isEqualToString:@"200"]){
        
        if(resString != NULL){
            NSDictionary * dic = [self JSONToDictionary:resString];
            if([dic objectForKey:@"message"]){
                NSString * message = [dic objectForKey:@"message"];
                NSDictionary * returnDic = [NSDictionary dictionaryWithObjectsAndKeys:@"error",@"status",message,@"response", nil];
                return returnDic;
            }
        }
        NSDictionary * returnDic = [NSDictionary dictionaryWithObjectsAndKeys:@"error",@"status",@"error canceling Order transaction",@"response", nil];
        return returnDic;
    }
    
    
    NSDictionary * returnDic = [NSDictionary dictionaryWithObjectsAndKeys:@"success",@"status",resString,@"response", nil];
    
    return returnDic;

    
    
    
}



-(NSDictionary*)issueToken:(NSString*)source andTokenName:(NSString*)token andQuantity:(double)quantity andDivisible:(BOOL)divisible{
    
    return [self issueTokenMaster:source andTokenName:token andQuantity:quantity andDivisible:divisible andDescription:NULL andWebsiteURL:NULL andImageURL:NULL andFee:-1 andFeePerKB:-1];
}


-(NSDictionary*)issueToken:(NSString*)source andTokenName:(NSString*)token andQuantity:(double)quantity andDivisible:(BOOL)divisible andDescription:(NSString*)description {
    
    return [self issueTokenMaster:source andTokenName:token andQuantity:quantity andDivisible:divisible andDescription:description andWebsiteURL:NULL andImageURL:NULL andFee:-1 andFeePerKB:-1];
    
}

-(NSDictionary*)issueToken:(NSString*)source andTokenName:(NSString*)token andQuantity:(double)quantity andDivisible:(BOOL)divisible andDescription:(NSString*)description andWebsiteURL:(NSString*)websiteURL{
    
    return [self issueTokenMaster:source andTokenName:token andQuantity:quantity andDivisible:divisible andDescription:description andWebsiteURL:websiteURL andImageURL:NULL andFee:-1 andFeePerKB:-1];
    
}

-(NSDictionary*)issueToken:(NSString*)source andTokenName:(NSString*)token andQuantity:(double)quantity andDivisible:(BOOL)divisible andDescription:(NSString*)description andWebsiteURL:(NSString*)websiteURL andImageURL:(NSString*)imageURL{
    
    return [self issueTokenMaster:source andTokenName:token andQuantity:quantity andDivisible:divisible andDescription:description andWebsiteURL:websiteURL andImageURL:imageURL andFee:-1 andFeePerKB:-1];
    
}

-(NSDictionary*)issueToken:(NSString*)source andTokenName:(NSString*)token andQuantity:(double)quantity andDivisible:(BOOL)divisible andDescription:(NSString*)description andWebsiteURL:(NSString*)websiteURL andImageURL:(NSString*)imageURL andFee:(int)fee{
    
    return [self issueTokenMaster:source andTokenName:token andQuantity:quantity andDivisible:divisible andDescription:description andWebsiteURL:websiteURL andImageURL:imageURL andFee:fee andFeePerKB:-1];
    
}

-(NSDictionary*)issueToken:(NSString*)source andTokenName:(NSString*)token andQuantity:(double)quantity andDivisible:(BOOL)divisible andDescription:(NSString*)description andWebsiteURL:(NSString*)websiteURL andImageURL:(NSString*)imageURL andFee:(int)fee andFeePerKB:(int)feePerKB{
    
    return [self issueTokenMaster:source andTokenName:token andQuantity:quantity andDivisible:divisible andDescription:description andWebsiteURL:websiteURL andImageURL:imageURL andFee:fee andFeePerKB:feePerKB];
    
}


-(void)createNumericTokenName:(completionBlock)completionBlock{
    
    if(![self checkCompletion:completionBlock]){
        return;
    }
    [self.webView stringByEvaluatingJavaScriptFromString:@"createNumericTokenName()"];
 
}
-(void)issueToken:(NSString*)source andTokenName:(NSString*)token andQuantity:(double)quantity andDivisible:(BOOL)divisible andCompletion:(completionBlock)completionBlock{
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSDictionary* response = [self issueTokenMaster:source andTokenName:token andQuantity:quantity andDivisible:divisible andDescription:NULL andWebsiteURL:NULL andImageURL:NULL andFee:-1 andFeePerKB:-1];
        
        NSString * status = [response objectForKey:@"status"];
        if(![status isEqualToString:@"error"]){
            completionBlock(NULL, response);
        }else{
            completionBlock([NSError errorWithDomain:@"IndieCore"  code:100 userInfo:@{ NSLocalizedDescriptionKey:response }], response);
        }
        
        
    });
    
}
-(void)issueToken:(NSString*)source andTokenName:(NSString*)token andQuantity:(double)quantity andDivisible:(BOOL)divisible andDescription:(NSString*)description andCompletion:(completionBlock)completionBlock{
    
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSDictionary* response = [self issueTokenMaster:source andTokenName:token andQuantity:quantity andDivisible:divisible andDescription:description andWebsiteURL:NULL andImageURL:NULL andFee:-1 andFeePerKB:-1];
        
        NSString * status = [response objectForKey:@"status"];
        if(![status isEqualToString:@"error"]){
            completionBlock(NULL, response);
        }else{
            completionBlock([NSError errorWithDomain:@"IndieCore"  code:100 userInfo:@{ NSLocalizedDescriptionKey:response }], response);
        }
        
        
    });
    
}
-(void)issueToken:(NSString*)source andTokenName:(NSString*)token andQuantity:(double)quantity andDivisible:(BOOL)divisible andDescription:(NSString*)description andWebsiteURL:(NSString*)websiteURL andCompletion:(completionBlock)completionBlock{
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSDictionary* response = [self issueTokenMaster:source andTokenName:token andQuantity:quantity andDivisible:divisible andDescription:description andWebsiteURL:websiteURL andImageURL:NULL andFee:-1 andFeePerKB:-1];
        NSString * status = [response objectForKey:@"status"];
        if(![status isEqualToString:@"error"]){
            completionBlock(NULL, response);
        }else{
            completionBlock([NSError errorWithDomain:@"IndieCore"  code:100 userInfo:@{ NSLocalizedDescriptionKey:response }], response);
        }
        
        
    });
}

-(void)issueToken:(NSString*)source andTokenName:(NSString*)token andQuantity:(double)quantity andDivisible:(BOOL)divisible andDescription:(NSString*)description andWebsiteURL:(NSString*)websiteURL andImageURL:(NSString*)imageURL andCompletion:(completionBlock)completionBlock{
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSDictionary* response =  [self issueTokenMaster:source andTokenName:token andQuantity:quantity andDivisible:divisible andDescription:description andWebsiteURL:websiteURL andImageURL:imageURL andFee:-1 andFeePerKB:-1];
        
        NSString * status = [response objectForKey:@"status"];
        if(![status isEqualToString:@"error"]){
            completionBlock(NULL, response);
        }else{
            completionBlock([NSError errorWithDomain:@"IndieCore"  code:100 userInfo:@{ NSLocalizedDescriptionKey:response }], response);
        }
        
    });
    
}
-(void)issueToken:(NSString*)source andTokenName:(NSString*)token andQuantity:(double)quantity andDivisible:(BOOL)divisible andDescription:(NSString*)description andWebsiteURL:(NSString*)websiteURL andImageURL:(NSString*)imageURL andFee:(int)fee andCompletion:(completionBlock)completionBlock{
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSDictionary* response = [self issueTokenMaster:source andTokenName:token andQuantity:quantity andDivisible:divisible andDescription:description andWebsiteURL:websiteURL andImageURL:imageURL andFee:fee andFeePerKB:-1];
        
        NSString * status = [response objectForKey:@"status"];
        if(![status isEqualToString:@"error"]){
            completionBlock(NULL, response);
        }else{
            completionBlock([NSError errorWithDomain:@"IndieCore"  code:100 userInfo:@{ NSLocalizedDescriptionKey:response }], response);
        }
        
        
    });
    
}



-(void)issueToken:(NSString*)source andTokenName:(NSString*)token andQuantity:(double)quantity andDivisible:(BOOL)divisible andDescription:(NSString*)description andWebsiteURL:(NSString*)websiteURL andImageURL:(NSString*)imageURL andFee:(int)fee andFeePerKB:(int)feePerKB andCompletion:(completionBlock)completionBlock{
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSDictionary* response =  [self issueTokenMaster:source andTokenName:token andQuantity:quantity andDivisible:divisible andDescription:description andWebsiteURL:websiteURL andImageURL:imageURL andFee:fee andFeePerKB:feePerKB];
        
        NSString * status = [response objectForKey:@"status"];
        if(![status isEqualToString:@"error"]){
            completionBlock(NULL, response);
        }else{
            completionBlock([NSError errorWithDomain:@"IndieCore"  code:100 userInfo:@{ NSLocalizedDescriptionKey:response }], response);
        }
        
        
    });
}









-(BOOL)checkIfTokenExists:(NSString*)token{
    
    NSDictionary * response = [self get:[NSString stringWithFormat:@"%@tokens/%@",self.baseUrl,token]];
    
    NSString * statusCode = [response objectForKey:@"httpStatus"];
    
    if([statusCode isEqualToString:@"200"]){
        
        return true;
        
    }else{
        return false;
    }
    
}


-(NSDictionary*)issueTokenMaster:(NSString*)source andTokenName:(NSString*)token andQuantity:(double)quantity andDivisible:(BOOL)divisible andDescription:(NSString*)description andWebsiteURL:(NSString*)websiteURL andImageURL:(NSString*)imageURL andFee:(int)fee andFeePerKB:(int)feePerKB{
    
    if([self checkIfTokenExists:token]){
        NSLog(@"token already exists");
        return [NSDictionary dictionaryWithObjectsAndKeys:@"error",@"status",@"response",@"token already exists", nil];
    }
    
    if(description == NULL && websiteURL == NULL && imageURL == NULL){
        
        NSDictionary * response1 = [self createIssuanceTransaction:source andTokenName:token andQuantity:quantity andDivisible:divisible andDescription:description andFee:fee andFeePerKB:feePerKB];
        
        if(![[response1 objectForKey:@"status"] isEqualToString:@"error"]){
            
            NSString * resString = [response1 objectForKey:@"response"];
            
            NSDictionary * dic = [self JSONToDictionary:resString];
            
            return [NSDictionary dictionaryWithObjectsAndKeys:@"success",@"status",dic,@"response", nil];
            
        }else{
            
            return response1;
            
        }
        
        
    }else{
        
        
        NSDictionary * response1 = [self createEnhancedAssetInfo:token andDescription:description andWebsiteURL:websiteURL andImageURL:imageURL];
        
        if(![[response1 objectForKey:@"status"] isEqualToString:@"error"]){
            
            NSString * resString = [response1 objectForKey:@"response"];
            
            NSDictionary * dic = [self JSONToDictionary:resString];
            
            NSNumber * issuance = [dic objectForKey:@"issuance"];
            
            NSString * descriptionURL = NULL;
            
            if([issuance boolValue] == true){
                descriptionURL = [dic objectForKey:@"uri"];
            }
            
            NSDictionary * response2 = [self createIssuanceTransaction:source andTokenName:token andQuantity:quantity andDivisible:divisible andDescription:descriptionURL andFee:fee andFeePerKB:feePerKB];
            
            
            
            if(![[response2 objectForKey:@"status"] isEqualToString:@"error"]){
                
                NSString * resString = [response2 objectForKey:@"response"];
                
                NSDictionary * dic = [self JSONToDictionary:resString];
                
                return [NSDictionary dictionaryWithObjectsAndKeys:@"success",@"status",dic,@"response", nil];
                
            }else{
                
                return response2;
            }
            
        }else{
            return response1;
        }
        
    }
    
    return [NSDictionary dictionaryWithObjectsAndKeys:@"error",@"status","unknown error",@"response", nil];
    
}

-(NSDictionary*)createEnhancedAssetInfo:(NSString*)token andDescription:(NSString*)description andWebsiteURL:(NSString*)websiteURL andImageURL:(NSString*)imageURL{
    
    NSArray *objects = [NSArray arrayWithObjects:description, websiteURL, imageURL, nil];
    
    NSArray *keys = [NSArray arrayWithObjects:@"description", @"website", @"image", nil];
    
    NSDictionary *postDic = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    
    NSString *jsonRequest = [self dictionaryToJSON:postDic];
    
    NSDictionary * res = [self post:jsonRequest url:[NSString stringWithFormat:@"%@files/enhancedtokeninfo/%@",self.baseUrl,token] andIsJSON:true];
    
    NSString * httpStatus = [res objectForKey:@"httpStatus"];
    
    NSString * resString = [res objectForKey:@"response"];
    
    
    if(![httpStatus isEqualToString:@"200"]){
        
        if(resString != NULL){
            NSDictionary * dic = [self JSONToDictionary:resString];
            if([dic objectForKey:@"message"]){
                NSString * message = [dic objectForKey:@"message"];
                NSDictionary * returnDic = [NSDictionary dictionaryWithObjectsAndKeys:@"error",@"status",message,@"response", nil];
                return returnDic;
            }
        }
        
        NSDictionary * returnDic = [NSDictionary dictionaryWithObjectsAndKeys:@"error",@"status",@"error creating issuance transaction",@"response", nil];
        
        return returnDic;
    }
    
    
    
    
    NSDictionary * returnDic = [NSDictionary dictionaryWithObjectsAndKeys:@"success",@"status",resString,@"response", nil];
    
    return returnDic;
    
}

-(NSDictionary*)createIssuanceTransaction:(NSString*)source andTokenName:(NSString*)token andQuantity:(double)quantity andDivisible:(BOOL)divisible andDescription:(NSString*)description andFee:(int)fee andFeePerKB:(int)feePerKB{
    
    NSMutableDictionary * tmpDic = [[NSMutableDictionary alloc] init];
    [tmpDic setObject:source forKey:@"source"];
    [tmpDic setObject:[NSNumber numberWithDouble:quantity] forKey:@"quantity"];
    [tmpDic setObject:token forKey:@"token"];
    [tmpDic setObject:[NSNumber numberWithBool:divisible] forKey:@"divisible"];
    if(feePerKB != -1){
        [tmpDic setObject:[NSNumber numberWithInt:feePerKB] forKey:@"fee_per_kb"];
    }
    if(fee != -1){
        [tmpDic setObject:[NSNumber numberWithInt:fee] forKey:@"fee"];
    }
    
    if(description != NULL){
        [tmpDic setObject:description forKey:@"description"];
    }
    
    
    NSDictionary *postDic = [NSDictionary dictionaryWithDictionary:tmpDic];
    
    NSString *jsonRequest = [self dictionaryToJSON:postDic];
    
    NSDictionary * res = [self post:jsonRequest url: [NSString stringWithFormat:@"%@transactions/issuance",self.baseUrl] andIsJSON:true];
    
    NSString * httpStatus = [res objectForKey:@"httpStatus"];
    
    NSString * resString = [res objectForKey:@"response"];
    
    if(![httpStatus isEqualToString:@"200"]){
        
        if(resString != NULL){
            NSDictionary * dic = [self JSONToDictionary:resString];
            if([dic objectForKey:@"message"]){
                NSString * message = [dic objectForKey:@"message"];
                NSDictionary * returnDic = [NSDictionary dictionaryWithObjectsAndKeys:@"error",@"status",message,@"response", nil];
                return returnDic;
            }
        }
        NSDictionary * returnDic = [NSDictionary dictionaryWithObjectsAndKeys:@"error",@"status",@"error creating issuance transaction",@"response", nil];
        return returnDic;
    }
    
    
    NSDictionary * returnDic = [NSDictionary dictionaryWithObjectsAndKeys:@"success",@"status",resString,@"response", nil];
    
    return returnDic;
    
    
}

-(void)broadcastTransaction:(NSString*)signedTx andCompletion:(completionBlock)completionBlock{

    NSArray *objects = [NSArray arrayWithObjects:signedTx, nil];
    
    NSArray *keys = [NSArray arrayWithObjects:@"tx", nil];
    
    NSDictionary *postDic = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    
    NSString *jsonRequest = [self dictionaryToJSON:postDic];
    
    [self postAsync: [NSString stringWithFormat:@"%@transactions/send",self.baseUrl] andPost:jsonRequest andCompletion:^(NSError*error, NSDictionary *response) {
        if(error == NULL){
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(NULL, response );
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock([NSError errorWithDomain:@"IndieCore"  code:100 userInfo:@{ NSLocalizedDescriptionKey:response }],response);
                
            });
        }
        
    }];

   
    
}


-(void)getBalance:(NSString*)source andCompletion:(completionBlock)completionBlock{
    
    [self getAsync:[NSString stringWithFormat:@"%@addresses/%@/balances",self.baseUrl,source] andCompletion:^(NSError*error, NSDictionary *response) {
        if(error == NULL){
               dispatch_async(dispatch_get_main_queue(), ^{
                   completionBlock(NULL, response );
               });
        }else{
              dispatch_async(dispatch_get_main_queue(), ^{
                  completionBlock([NSError errorWithDomain:@"IndieCore"  code:100 userInfo:@{ NSLocalizedDescriptionKey:response }],response);
           
                   });
        }
        
    }];
   
    
}
-(void)getHistory:(NSString*)source andCompletion:(completionBlock)completionBlock{
    
    [self getAsync:[NSString stringWithFormat:@"%@addresses/%@/history",self.baseUrl,source] andCompletion:^(NSError*error, NSDictionary *response) {
        if(error == NULL){
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(NULL, response );
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock([NSError errorWithDomain:@"IndieCore"  code:100 userInfo:@{ NSLocalizedDescriptionKey:response }],response);
                
            });
        }
        
    }];
    
    
}
-(void)getTokenInfo:(NSString*)token andCompletion:(completionBlock)completionBlock{
    
    [self getAsync:[NSString stringWithFormat:@"%@tokens/%@",self.baseUrl,token] andCompletion:^(NSError*error, NSDictionary *response) {
        if(error == NULL){
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(NULL, response );
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock([NSError errorWithDomain:@"IndieCore"  code:100 userInfo:@{ NSLocalizedDescriptionKey:response }],response);
                
            });
        }
        
    }];
    
    
}
-(void)getTokenHolders:(NSString*)token andCompletion:(completionBlock)completionBlock{
    
    [self getAsync:[NSString stringWithFormat:@"%@tokens/%@/holders",self.baseUrl,token] andCompletion:^(NSError*error, NSDictionary *response) {
        if(error == NULL){
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(NULL, response );
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock([NSError errorWithDomain:@"IndieCore"  code:100 userInfo:@{ NSLocalizedDescriptionKey:response }],response);
                
            });
        }
        
    }];
    
    
}
-(void)getTokenHistory:(NSString*)token andCompletion:(completionBlock)completionBlock{
    
    [self getAsync:[NSString stringWithFormat:@"%@tokens/%@/history",self.baseUrl,token] andCompletion:^(NSError*error, NSDictionary *response) {
        if(error == NULL){
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(NULL, response );
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock([NSError errorWithDomain:@"IndieCore"  code:100 userInfo:@{ NSLocalizedDescriptionKey:response }],response);
                
            });
        }
        
    }];
    
    
}
-(void)getTokenDescription:(NSString*)token andCompletion:(completionBlock)completionBlock{
    
    [self getTokenInfo:token andCompletion:^(NSError*error, NSDictionary *response) {
        if(error == NULL){
            if([response valueForKey:@"description"] != NULL){
                NSURL *url = [NSURL URLWithString:[response valueForKey:@"description"]];
                if (url && url.scheme && url.host)
                {
                    [self getAsync:[response valueForKey:@"description"] andCompletion:^(NSError*error2, NSDictionary *response2) {
                        completionBlock(error2,response2);
                    }];
                }else{
                     completionBlock(NULL,response);
                }
            }else{
                
                 completionBlock([NSError errorWithDomain:@"IndieCore"  code:100 userInfo:@{ NSLocalizedDescriptionKey:response }],response);
            }
           
        }else{
            
            completionBlock([NSError errorWithDomain:@"IndieCore"  code:100 userInfo:@{ NSLocalizedDescriptionKey:response }],response);
        }
        
    }];
 
}

-(void)createSend:(NSString*)source andTokenName:(NSString*)token andDestination:(NSString*)destination andQuantity:(double)quantity andCompletion:(completionBlock)completionBlock{
    
    [self createSend:source andTokenName:token andDestination:destination andQuantity:quantity andFee:-1 andFeePerKB:-1 andCompletion:^(NSError*error, NSDictionary *response) {
        completionBlock(error,response);
    }];
    
}


-(void)createSend:(NSString*)source andTokenName:(NSString*)token andDestination:(NSString*)destination andQuantity:(double)quantity andFee:(int)fee andCompletion:(completionBlock)completionBlock{
    [self createSend:source andTokenName:token andDestination:destination andQuantity:quantity andFee:fee andFeePerKB:-1 andCompletion:^(NSError*error, NSDictionary *response) {
        completionBlock(error,response);
    }];
}

-(void)createSend:(NSString*)source andTokenName:(NSString*)token andDestination:(NSString*)destination andQuantity:(double)quantity andFee:(int)fee andFeePerKB:(int)feePerKB andCompletion:(completionBlock)completionBlock{
    
    NSMutableDictionary * tmpDic = [[NSMutableDictionary alloc] init];
    [tmpDic setObject:source forKey:@"source"];
    [tmpDic setObject:token forKey:@"token"];
    [tmpDic setObject:destination forKey:@"destination"];
    [tmpDic setObject:[NSNumber numberWithDouble:quantity] forKey:@"quantity"];
    
    if(feePerKB != -1){
        [tmpDic setObject:[NSNumber numberWithInt:feePerKB] forKey:@"fee_per_kb"];
    }
    if(fee != -1){
        [tmpDic setObject:[NSNumber numberWithInt:fee] forKey:@"fee"];
    }
    
    NSDictionary *postDic = [NSDictionary dictionaryWithDictionary:tmpDic];
    
    NSString *jsonRequest = [self dictionaryToJSON:postDic];
   
    [self postAsync: [NSString stringWithFormat:@"%@transactions/send",self.baseUrl] andPost:jsonRequest andCompletion:^(NSError*error, NSDictionary *response) {
        if(error == NULL){
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(NULL, response );
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock([NSError errorWithDomain:@"IndieCore"  code:100 userInfo:@{ NSLocalizedDescriptionKey:response }],response);
                
            });
        }
        
    }];
    
}

-(void)createIssuance:(NSString*)source andTokenName:(NSString*)token andQuantity:(double)quantity andDivisible:(BOOL)divisible andCompletion:(completionBlock)completionBlock{
    
   [self createIssuanceMaster:source andTokenName:token andQuantity:quantity andDivisible:divisible andDescription:NULL andWebsiteURL:NULL andImageURL:NULL andFee:-1 andFeePerKB:-1 andCompletion:^(NSError*error, NSDictionary *response) {
        completionBlock(error,response);
         }];
}


-(void)createIssuance:(NSString*)source andTokenName:(NSString*)token andQuantity:(double)quantity andDivisible:(BOOL)divisible andDescription:(NSString*)description andCompletion:(completionBlock)completionBlock{
    
     [self createIssuanceMaster:source andTokenName:token andQuantity:quantity andDivisible:divisible andDescription:description andWebsiteURL:NULL andImageURL:NULL andFee:-1 andFeePerKB:-1 andCompletion:^(NSError*error, NSDictionary *response) {
        completionBlock(error,response);
         }];
    
}

-(void)createIssuance:(NSString*)source andTokenName:(NSString*)token andQuantity:(double)quantity andDivisible:(BOOL)divisible andDescription:(NSString*)description andWebsiteURL:(NSString*)websiteURL andCompletion:(completionBlock)completionBlock{
    
   [self createIssuanceMaster:source andTokenName:token andQuantity:quantity andDivisible:divisible andDescription:description andWebsiteURL:websiteURL andImageURL:NULL andFee:-1 andFeePerKB:-1 andCompletion:^(NSError*error, NSDictionary *response) {
        completionBlock(error,response);
         }];
    
}

-(void)createIssuance:(NSString*)source andTokenName:(NSString*)token andQuantity:(double)quantity andDivisible:(BOOL)divisible andDescription:(NSString*)description andWebsiteURL:(NSString*)websiteURL andImageURL:(NSString*)imageURL andCompletion:(completionBlock)completionBlock{
    
    [self createIssuanceMaster:source andTokenName:token andQuantity:quantity andDivisible:divisible andDescription:description andWebsiteURL:websiteURL andImageURL:imageURL andFee:-1 andFeePerKB:-1 andCompletion:^(NSError*error, NSDictionary *response) {
        completionBlock(error,response);
         }];
    
}

-(void)createIssuance:(NSString*)source andTokenName:(NSString*)token andQuantity:(double)quantity andDivisible:(BOOL)divisible andDescription:(NSString*)description andWebsiteURL:(NSString*)websiteURL andImageURL:(NSString*)imageURL andFee:(int)fee andCompletion:(completionBlock)completionBlock{
  
    [self createIssuanceMaster:source andTokenName:token andQuantity:quantity andDivisible:divisible andDescription:description andWebsiteURL:websiteURL andImageURL:imageURL andFee:fee andFeePerKB:-1 andCompletion:^(NSError*error, NSDictionary *response) {
        completionBlock(error,response);
         }];
    
}

-(void)createIssuance:(NSString*)source andTokenName:(NSString*)token andQuantity:(double)quantity andDivisible:(BOOL)divisible andDescription:(NSString*)description andWebsiteURL:(NSString*)websiteURL andImageURL:(NSString*)imageURL andFee:(int)fee andFeePerKB:(int)feePerKB andCompletion:(completionBlock)completionBlock{
    
    [self createIssuanceMaster:source andTokenName:token andQuantity:quantity andDivisible:divisible andDescription:description andWebsiteURL:websiteURL andImageURL:imageURL andFee:fee andFeePerKB:feePerKB andCompletion:^(NSError*error, NSDictionary *response) {
        completionBlock(error,response);
    }];
    
}

-(void)createIssuanceMaster:(NSString*)source andTokenName:(NSString*)token andQuantity:(double)quantity andDivisible:(BOOL)divisible andDescription:(NSString*)description andWebsiteURL:(NSString*)websiteURL andImageURL:(NSString*)imageURL andFee:(int)fee andFeePerKB:(int)feePerKB andCompletion:(completionBlock)completionBlock{
   
    
    
    if(description == NULL && websiteURL == NULL && imageURL == NULL){
        
        NSMutableDictionary * tmpDic = [[NSMutableDictionary alloc] init];
        [tmpDic setObject:source forKey:@"source"];
        [tmpDic setObject:[NSNumber numberWithDouble:quantity] forKey:@"quantity"];
        [tmpDic setObject:token forKey:@"token"];
        [tmpDic setObject:[NSNumber numberWithBool:divisible] forKey:@"divisible"];
        if(feePerKB != -1){
            [tmpDic setObject:[NSNumber numberWithInt:feePerKB] forKey:@"fee_per_kb"];
        }
        if(fee != -1){
            [tmpDic setObject:[NSNumber numberWithInt:fee] forKey:@"fee"];
        }
        
        if(description != NULL){
            [tmpDic setObject:description forKey:@"description"];
        }
        
        
        NSDictionary *postDic = [NSDictionary dictionaryWithDictionary:tmpDic];
        
        NSString *jsonRequest = [self dictionaryToJSON:postDic];
        
        [self postAsync: [NSString stringWithFormat:@"%@transactions/issuance",self.baseUrl] andPost:jsonRequest andCompletion:^(NSError*error, NSDictionary *response) {
            if(error == NULL){
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionBlock(NULL, response );
                });
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionBlock([NSError errorWithDomain:@"IndieCore"  code:100 userInfo:@{ NSLocalizedDescriptionKey:response }],response);
                    
                });
            }
            
        }];
        
        
        
        
    }else{
        
        NSArray *objects = [NSArray arrayWithObjects:description, websiteURL, imageURL, nil];
        
        NSArray *keys = [NSArray arrayWithObjects:@"description", @"website", @"image", nil];
        
        NSDictionary *postDic = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
        
        NSString *jsonRequest = [self dictionaryToJSON:postDic];
        
        
        [self postAsync:[NSString stringWithFormat:@"%@files/enhancedtokeninfo/%@",self.baseUrl,token] andPost:jsonRequest andCompletion:^(NSError*error, NSDictionary *response) {
            if(error == NULL){
                
                
                NSString * resString = [response objectForKey:@"response"];
                
                NSDictionary * dic = [self JSONToDictionary:resString];
                
                NSNumber * issuance = [dic objectForKey:@"issuance"];
                
                NSString * descriptionURL = NULL;
                
                if([issuance boolValue] == true){
                    descriptionURL = [dic objectForKey:@"uri"];
                }
                
                
                NSMutableDictionary * tmpDic = [[NSMutableDictionary alloc] init];
                [tmpDic setObject:source forKey:@"source"];
                [tmpDic setObject:[NSNumber numberWithDouble:quantity] forKey:@"quantity"];
                [tmpDic setObject:token forKey:@"token"];
                [tmpDic setObject:[NSNumber numberWithBool:divisible] forKey:@"divisible"];
                if(feePerKB != -1){
                    [tmpDic setObject:[NSNumber numberWithInt:feePerKB] forKey:@"fee_per_kb"];
                }
                if(fee != -1){
                    [tmpDic setObject:[NSNumber numberWithInt:fee] forKey:@"fee"];
                }
                
                if(description != NULL){
                    [tmpDic setObject:description forKey:@"description"];
                }
                
                
                NSDictionary *postDic = [NSDictionary dictionaryWithDictionary:tmpDic];
                
                NSString *jsonRequest = [self dictionaryToJSON:postDic];
                
                [self postAsync: [NSString stringWithFormat:@"%@transactions/issuance",self.baseUrl] andPost:jsonRequest andCompletion:^(NSError*error, NSDictionary *response) {
                    if(error == NULL){
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completionBlock(NULL, response );
                        });
                    }else{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completionBlock([NSError errorWithDomain:@"IndieCore"  code:100 userInfo:@{ NSLocalizedDescriptionKey:response }],response);
                            
                        });
                    }
                    
                }];
                
                
                
                
                
                
                
                
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionBlock([NSError errorWithDomain:@"IndieCore"  code:100 userInfo:@{ NSLocalizedDescriptionKey:response }],response);
                    
                });
            }
            
        }];
        
        
      
       
            
      
        
    }
    
    
}



-(void)createOrder:(NSString*)source andGiveQuantity:(double)giveQuantity andGiveToken:(NSString*)giveToken andGetQuantity:(double)getQuantity andGetToken:(NSString*)getToken andExpiration:(int)expiration andCompletion:(completionBlock)completionBlock{
    
 
        
        [self createOrderMaster:source andGiveQuantity:giveQuantity andGiveToken:giveToken andGetQuantity:getQuantity andGetToken:getToken andExpiration:expiration andFee:-1 andFeePerKB:-1 andCompletion:^(NSError*error, NSDictionary *response) {
            
            
            completionBlock(error, response);
            
            
            
        }];
}

-(void)createOrder:(NSString*)source andGiveQuantity:(double)giveQuantity andGiveToken:(NSString*)giveToken andGetQuantity:(double)getQuantity andGetToken:(NSString*)getToken andExpiration:(int)expiration andFee:(int)fee andCompletion:(completionBlock)completionBlock{
    
   
        
        [self createOrderMaster:source andGiveQuantity:giveQuantity andGiveToken:giveToken andGetQuantity:getQuantity andGetToken:getToken andExpiration:expiration andFee:fee andFeePerKB:-1 andCompletion:^(NSError*error, NSDictionary *response) {
            
            
            completionBlock(error, response);
            
            
            
        }];
}

-(void)createOrder:(NSString*)source andGiveQuantity:(double)giveQuantity andGiveToken:(NSString*)giveToken andGetQuantity:(double)getQuantity andGetToken:(NSString*)getToken andExpiration:(int)expiration andFeePerKB:(int)feePerKB andCompletion:(completionBlock)completionBlock{
    
 
        
        [self createOrderMaster:source andGiveQuantity:giveQuantity andGiveToken:giveToken andGetQuantity:getQuantity andGetToken:getToken andExpiration:expiration andFee:-1 andFeePerKB:feePerKB andCompletion:^(NSError*error, NSDictionary *response) {
        
        
            completionBlock(error, response);
        
        
        
        }];
    
    
}


-(void)createOrderMaster:(NSString*)source andGiveQuantity:(double)giveQuantity andGiveToken:(NSString*)giveToken andGetQuantity:(double)getQuantity andGetToken:(NSString*)getToken andExpiration:(int)expiration andFee:(int)fee andFeePerKB:(int)feePerKB andCompletion:(completionBlock)completionBlock{
    
    
    NSMutableDictionary * tmpDic = [[NSMutableDictionary alloc] init];
    [tmpDic setObject:source forKey:@"source"];
    [tmpDic setObject:[NSNumber numberWithDouble: giveQuantity] forKey:@"give_quantity"];
    [tmpDic setObject:giveToken forKey:@"give_token"];
    [tmpDic setObject:[NSNumber numberWithDouble:getQuantity] forKey:@"get_quantity"];
    [tmpDic setObject:getToken forKey:@"get_token"];
    [tmpDic setObject:[NSNumber numberWithInt:expiration] forKey:@"expiration"];
    
    if(feePerKB != -1){
        [tmpDic setObject:[NSNumber numberWithInt:feePerKB] forKey:@"fee_per_kb"];
    }
    if(fee != -1){
        [tmpDic setObject:[NSNumber numberWithInt:fee] forKey:@"fee"];
    }
    
    NSDictionary *postDic = [NSDictionary dictionaryWithDictionary:tmpDic];
    
    NSString *jsonRequest = [self dictionaryToJSON:postDic];
    
    [self postAsync: [NSString stringWithFormat:@"%@transactions/order",self.baseUrl] andPost:jsonRequest andCompletion:^(NSError*error, NSDictionary *response) {
        if(error == NULL){
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(NULL, response );
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock([NSError errorWithDomain:@"IndieCore"  code:100 userInfo:@{ NSLocalizedDescriptionKey:response }],response);
                
            });
        }
        
    }];
    
    
    
}



-(void)createCancel:(NSString*)source andOfferHash:(NSString*)offerHash andCompletion:(completionBlock)completionBlock{
    
   
    [self createCancelMaster:source andOfferHash:offerHash andFee:-1 andFeePerKB:-1 andCompletion:^(NSError*error, NSDictionary *response) {
        
        
        completionBlock(error, response);
        
        
        
    }];
        
   
    
}

-(void)createCancel:(NSString*)source andOfferHash:(NSString*)offerHash andFeePerKB:(int)feePerKB andCompletion:(completionBlock)completionBlock{
    
  
    [self createCancelMaster:source andOfferHash:offerHash andFee:-1 andFeePerKB:feePerKB andCompletion:^(NSError*error, NSDictionary *response) {
        
        
        completionBlock(error, response);
        
        
        
    }];
        
    
    
    
}

-(void)createCancel:(NSString*)source andOfferHash:(NSString*)offerHash andFee:(int)fee andCompletion:(completionBlock)completionBlock{
  
        
    [self createCancelMaster:source andOfferHash:offerHash andFee:fee andFeePerKB:-1 andCompletion:^(NSError*error, NSDictionary *response) {
        
        
        completionBlock(error, response);
        
        
        
    }];
        
  
    
}

-(void)createCancelMaster:(NSString*)source andOfferHash:(NSString*)offerHash andFee:(int)fee andFeePerKB:(int)feePerKB andCompletion:(completionBlock)completionBlock{
    
    
    NSMutableDictionary * tmpDic = [[NSMutableDictionary alloc] init];
    [tmpDic setObject:source forKey:@"source"];
    [tmpDic setObject:offerHash forKey:@"offer_hash"];
    if(feePerKB != -1){
        [tmpDic setObject:[NSNumber numberWithInt:feePerKB] forKey:@"fee_per_kb"];
    }
    if(fee != -1){
        [tmpDic setObject:[NSNumber numberWithInt:fee] forKey:@"fee"];
    }
    
    NSDictionary *postDic = [NSDictionary dictionaryWithDictionary:tmpDic];
    
    NSString *jsonRequest = [self dictionaryToJSON:postDic];
    
    [self postAsync: [NSString stringWithFormat:@"%@transactions/cancel",self.baseUrl] andPost:jsonRequest andCompletion:^(NSError*error, NSDictionary *response) {
        if(error == NULL){
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(NULL, response );
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock([NSError errorWithDomain:@"IndieCore"  code:100 userInfo:@{ NSLocalizedDescriptionKey:response }],response);
                
            });
        }
        
    }];
    
    
}




 
-(NSDictionary *)post:(NSString *)postString url:(NSString*)urlString andIsJSON:(BOOL)isJSON{
    
    
    //Response data object
    NSData *returnData = [[NSData alloc]init];
    
    NSHTTPURLResponse* urlResponse = nil;
    
    NSError *error = nil;
    
    //Build the Request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    if(isJSON){
        
        NSData *requestData = [postString dataUsingEncoding:NSUTF8StringEncoding];
        
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:[NSString stringWithFormat:@"%d", [requestData length]] forHTTPHeaderField:@"Content-Length"];
        [request setHTTPBody: requestData];
        
    }
    else{
        [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[postString length]] forHTTPHeaderField:@"Content-length"];
    }
    
    [request setValue:self.apiKey forHTTPHeaderField:@"X-Api-Key"];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    //Send the Request
    returnData = [NSURLConnection sendSynchronousRequest: request returningResponse: &urlResponse  error: &error];
    
    //Get the Result of Request
    NSString *response = [[NSString alloc] initWithBytes:[returnData bytes] length:[returnData length] encoding:NSUTF8StringEncoding];
   
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) urlResponse;
    NSDictionary * dic = [NSDictionary dictionaryWithObjectsAndKeys:response,@"response", [NSString stringWithFormat:@"%ld",[httpResponse statusCode]],@"httpStatus", nil];
    
     NSLog(@"response %@",dic);
    
    return dic;
}

-(NSDictionary *)get:(NSString*)urlString{
    NSMutableURLRequest *request =
    [NSMutableURLRequest requestWithURL:[NSURL
                                         URLWithString:urlString]
                            cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                        timeoutInterval:20
     ];
    
    [request setHTTPMethod: @"GET"];
    [request setValue:self.apiKey forHTTPHeaderField:@"X-Api-Key"];
    NSError *requestError = nil;
    NSURLResponse *urlResponse = nil;
    //[NSURLConnection da
    
    NSData *response =
    [NSURLConnection sendSynchronousRequest:request
                          returningResponse:&urlResponse error:&requestError];
    
    
    NSString *res = [[NSString alloc] initWithBytes:[response  bytes] length:[response  length] encoding:NSUTF8StringEncoding];
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) urlResponse;
    
    
    NSDictionary * dic = [NSDictionary dictionaryWithObjectsAndKeys:res,@"response", [NSString stringWithFormat:@"%ld",[httpResponse statusCode]],@"httpStatus", nil];
    
    return dic;
}


-(void)broadcast:(NSString*)signedTx andCompletion:(completionBlock)completionBlock{
    
    NSArray *objects = [NSArray arrayWithObjects:signedTx, nil];
    
    NSArray *keys = [NSArray arrayWithObjects:@"tx", nil];
    
    NSDictionary *postDic = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    
    NSString *jsonRequest = [self dictionaryToJSON:postDic];
    
    [self postAsync: [NSString stringWithFormat:@"%@transactions/send",self.baseUrl] andPost:jsonRequest andCompletion:^(NSError*error, NSDictionary *response) {
        if(error == NULL){
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(NULL, response );
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock([NSError errorWithDomain:@"IndieCore"  code:100 userInfo:@{ NSLocalizedDescriptionKey:response }],response);
                
            });
        }
        
    }];
    
    
    
}


-(void)getAsync:(NSString*)urlString andCompletion:(completionBlock)completionBlock{
    NSMutableURLRequest *request =
    [NSMutableURLRequest requestWithURL:[NSURL
                                         URLWithString:urlString]
                            cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                        timeoutInterval:20
     ];
    
    [request setHTTPMethod: @"GET"];
    [request setValue:self.apiKey forHTTPHeaderField:@"X-Api-Key"];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
    {
        
       
         NSDictionary* responseJson = [NSJSONSerialization JSONObjectWithData:data
                                                       options:NSJSONReadingMutableContainers
                                                         error:&error];
        if ([data length] > 0 && error == nil)
            completionBlock(NULL,responseJson);
        else if ([data length] == 0 && error == nil)
           completionBlock([NSError errorWithDomain:@"IndieCore"  code:100 userInfo:@{ NSLocalizedDescriptionKey:responseJson }],responseJson);
        else if (error != nil)
             completionBlock([NSError errorWithDomain:@"IndieCore"  code:100 userInfo:@{ NSLocalizedDescriptionKey:responseJson }],responseJson);
    }];
    
 
}

-(void)postAsync:(NSString*)urlString andPost:(NSString*)postString andCompletion:(completionBlock)completionBlock{
    NSMutableURLRequest *request =
    [NSMutableURLRequest requestWithURL:[NSURL
                                         URLWithString:urlString]
                            cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                        timeoutInterval:20
     ];
    
    
    NSData *requestData = [postString dataUsingEncoding:NSUTF8StringEncoding];
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%d", [requestData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: requestData];
    
    [request setHTTPMethod: @"POST"];
    [request setValue:self.apiKey forHTTPHeaderField:@"X-Api-Key"];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         
         
         NSDictionary* responseJson = [NSJSONSerialization JSONObjectWithData:data
                                                                      options:NSJSONReadingMutableContainers
                                                                        error:&error];
         if ([data length] > 0 && error == nil)
             completionBlock(NULL,responseJson);
         else if ([data length] == 0 && error == nil)
             completionBlock([NSError errorWithDomain:@"IndieCore"  code:100 userInfo:@{ NSLocalizedDescriptionKey:responseJson }],responseJson);
         else if (error != nil)
             completionBlock([NSError errorWithDomain:@"IndieCore"  code:100 userInfo:@{ NSLocalizedDescriptionKey:responseJson }],responseJson);
     }];
    
    
}

-(void)postAsyncObject:(NSString*)urlString andPost:(NSString*)postString andCompletion:(completionBlock)completionBlock{
    NSMutableURLRequest *request =
    [NSMutableURLRequest requestWithURL:[NSURL
                                         URLWithString:urlString]
                            cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                        timeoutInterval:30
     ];
    
    
   
 
   
    NSData *postData = [postString dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%d",[postData length]];

    
 
   [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
   
   [request setHTTPBody:postData];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];

    [request setHTTPMethod: @"POST"];
    
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
 
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
              if(error == NULL){
                  
                  if(data != NULL){
                      
                      NSDictionary* responseJson = [NSJSONSerialization JSONObjectWithData:data
                                                                                   options:NSJSONReadingMutableContainers
                                                                                     error:&error];
                   
                       completionBlock(NULL,responseJson);
                  }else{
                 
                  completionBlock(NULL,[NSDictionary dictionaryWithObjectsAndKeys:@"success",@"status", nil]);
                  }
               
              
          }
         else{
               completionBlock(error,NULL);
         }
     }];
    
    
}



@end
