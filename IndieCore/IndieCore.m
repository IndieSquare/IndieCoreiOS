#import "IndieCore.h"

@implementation IndieCore

-(id)initWithViewController:(UIViewController*)parentVC andAPIKey:(NSString *)apiKey{
    self = [super init];
    if(self){
        self.webView = [[UIWebView alloc] initWithFrame:parentVC.view.frame];
        self.webView.delegate = self;
        self.apiKey = apiKey;
        self.webView.hidden = true; //hide webview so it runs unnoticed to the user
        [parentVC.view addSubview:self.webView];
        
        
        NSString * path = [[NSBundle mainBundle] pathForResource:@"IndieCore.bundle/functions" ofType:@"html"];
        if([[NSFileManager defaultManager] fileExistsAtPath:path]){
            
            NSURL *theURL = [NSURL fileURLWithPath:path];
            
            
            [self.webView loadRequest:[NSURLRequest requestWithURL:theURL]];
            
        }else{
            
            
        }
        
    }
    return self;
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
        [self.delegate didInitiateCore:@"success"];
    }
    
}


-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    if(self.webViewLoaded == false){
        NSLog(@"IndieCore loading error");
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
        
        
        
    }
    
    if([request.URL.absoluteString rangeOfString:@"address_passphrase"].location != NSNotFound){
        
        NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:request.URL
                                                    resolvingAgainstBaseURL:NO];
        NSArray *queryItems = urlComponents.queryItems;
        NSString * res = [self valueForKey:@"address_passphrase"
                            fromQueryItems:queryItems];
        
        if([res rangeOfString:@"error"].location != NSNotFound){
            [self.delegate generateAddressError:res];
        }else{
            [self.delegate didGenerateAddress:res];
        }
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

        
      
        [self.delegate didGenerateRandomDetailedWallet:priv_key andWif:priv_key_wif andPublicKey:public_key andAddress:address];
        
    }
    
    
    if([request.URL.absoluteString rangeOfString:@"create_passphrase"].location != NSNotFound){
        
        NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:request.URL
                                                    resolvingAgainstBaseURL:NO];
        NSArray *queryItems = urlComponents.queryItems;
        NSString * res = [self valueForKey:@"create_passphrase"
                            fromQueryItems:queryItems];
        
        
        
        if([res rangeOfString:@"error"].location != NSNotFound){
            [self.delegate createWalletError:res];
        }else{
            [self.delegate didCreateWallet:res];
        }
        
    }
    
    if([request.URL.absoluteString rangeOfString:@"address_valid"].location != NSNotFound){
        
        NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:request.URL
                                                    resolvingAgainstBaseURL:NO];
        NSArray *queryItems = urlComponents.queryItems;
        NSString * res = [self valueForKey:@"address_valid"
                            fromQueryItems:queryItems];
        
        
        
        if([res isEqualToString:@"true"]){
            [self.delegate didCheckAddressValid:true];
        }else{
            [self.delegate didCheckAddressValid:false];
        }
        
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
        
        
    }
    
    
    return YES;
}
-(void)showNotLoadedError{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:@"Library has not initiated yet"
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    
    
}
-(void)signTransacation:(NSString*)tx andPassphrase:(NSString*)passphrase andIndex:(int)index andDestination:(NSString*)destination{
    
    if(self.webViewLoaded == false){
        
        [self showNotLoadedError];
        return;
    }
    
    NSString * request = [NSString stringWithFormat:@"signTransaction(\"%@\",%d,\"%@\",\"%@\",\"%@\")",passphrase,index,tx,destination,self.apiKey];
   
     dispatch_async(dispatch_get_main_queue(), ^{
    
         [self.webView stringByEvaluatingJavaScriptFromString:request];
         
     });
    
}

-(void)signTransacation:(NSString*)tx andPassphrase:(NSString*)passphrase andIndex:(int)index{
    
    if(self.webViewLoaded == false){
        
        [self showNotLoadedError];
        return;
    }
    
    NSString * request = [NSString stringWithFormat:@"signTransactionNoDest(\"%@\",%d,\"%@\",\"%@\")",passphrase,index,tx,self.apiKey];

    
    dispatch_async(dispatch_get_main_queue(), ^{
    
        [self.webView stringByEvaluatingJavaScriptFromString:request];
    
        
    });
    
}

-(void)generateRandomDetailedWallet{
    if(self.webViewLoaded == false){
        
        [self showNotLoadedError];
        return;
    }
    [self.webView stringByEvaluatingJavaScriptFromString:@"createRandomDetailedWallet()"];

}
-(void)createNewWallet{
    if(self.webViewLoaded == false){
        
        [self showNotLoadedError];
        return;
    }
    [self.webView stringByEvaluatingJavaScriptFromString:@"createNewPassphrase()"];
    
}
-(void)checkIfAddressIsValid:(NSString *)address{
    
    if(self.webViewLoaded == false){
            
        [self showNotLoadedError];
            
        return;
    }
        
    NSString * request = [NSString stringWithFormat:@"isValidBitcoinAddress(\"%@\")",address];
    
    [self.webView stringByEvaluatingJavaScriptFromString:request];
        

}
-(void)generateAddressForPassphrase:(NSString*)passphrase andIndex:(int)index{
    if(self.webViewLoaded == false){
        
        [self showNotLoadedError];
        
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



-(void)issueToken:(NSString*)source andTokenName:(NSString*)token andQuantity:(double)quantity andDivisible:(BOOL)divisible andCompletion:(completionBlock)completionBlock{
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSDictionary* response = [self issueTokenMaster:source andTokenName:token andQuantity:quantity andDivisible:divisible andDescription:NULL andWebsiteURL:NULL andImageURL:NULL andFee:-1 andFeePerKB:-1];
        
        NSString * status = [response objectForKey:@"status"];
        if(![status isEqualToString:@"error"]){
            completionBlock(YES, response);
        }else{
            completionBlock(NO, response);
        }
        
        
    });
    
}
-(void)issueToken:(NSString*)source andTokenName:(NSString*)token andQuantity:(double)quantity andDivisible:(BOOL)divisible andDescription:(NSString*)description andCompletion:(completionBlock)completionBlock{
    
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSDictionary* response = [self issueTokenMaster:source andTokenName:token andQuantity:quantity andDivisible:divisible andDescription:description andWebsiteURL:NULL andImageURL:NULL andFee:-1 andFeePerKB:-1];
        
        NSString * status = [response objectForKey:@"status"];
        if(![status isEqualToString:@"error"]){
            completionBlock(YES, response);
        }else{
            completionBlock(NO, response);
        }
        
        
    });
    
}
-(void)issueToken:(NSString*)source andTokenName:(NSString*)token andQuantity:(double)quantity andDivisible:(BOOL)divisible andDescription:(NSString*)description andWebsiteURL:(NSString*)websiteURL andCompletion:(completionBlock)completionBlock{
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSDictionary* response = [self issueTokenMaster:source andTokenName:token andQuantity:quantity andDivisible:divisible andDescription:description andWebsiteURL:websiteURL andImageURL:NULL andFee:-1 andFeePerKB:-1];
        NSString * status = [response objectForKey:@"status"];
        if(![status isEqualToString:@"error"]){
            completionBlock(YES, response);
        }else{
            completionBlock(NO, response);
        }
        
        
    });
}

-(void)issueToken:(NSString*)source andTokenName:(NSString*)token andQuantity:(double)quantity andDivisible:(BOOL)divisible andDescription:(NSString*)description andWebsiteURL:(NSString*)websiteURL andImageURL:(NSString*)imageURL andCompletion:(completionBlock)completionBlock{
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSDictionary* response =  [self issueTokenMaster:source andTokenName:token andQuantity:quantity andDivisible:divisible andDescription:description andWebsiteURL:websiteURL andImageURL:imageURL andFee:-1 andFeePerKB:-1];
        
        NSString * status = [response objectForKey:@"status"];
        if(![status isEqualToString:@"error"]){
            completionBlock(YES, response);
        }else{
            completionBlock(NO, response);
        }
        
    });
    
}
-(void)issueToken:(NSString*)source andTokenName:(NSString*)token andQuantity:(double)quantity andDivisible:(BOOL)divisible andDescription:(NSString*)description andWebsiteURL:(NSString*)websiteURL andImageURL:(NSString*)imageURL andFee:(int)fee andCompletion:(completionBlock)completionBlock{
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSDictionary* response = [self issueTokenMaster:source andTokenName:token andQuantity:quantity andDivisible:divisible andDescription:description andWebsiteURL:websiteURL andImageURL:imageURL andFee:fee andFeePerKB:-1];
        
        NSString * status = [response objectForKey:@"status"];
        if(![status isEqualToString:@"error"]){
            completionBlock(YES, response);
        }else{
            completionBlock(NO, response);
        }
        
        
    });
    
}



-(void)issueToken:(NSString*)source andTokenName:(NSString*)token andQuantity:(double)quantity andDivisible:(BOOL)divisible andDescription:(NSString*)description andWebsiteURL:(NSString*)websiteURL andImageURL:(NSString*)imageURL andFee:(int)fee andFeePerKB:(int)feePerKB andCompletion:(completionBlock)completionBlock{
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSDictionary* response =  [self issueTokenMaster:source andTokenName:token andQuantity:quantity andDivisible:divisible andDescription:description andWebsiteURL:websiteURL andImageURL:imageURL andFee:fee andFeePerKB:feePerKB];
        
        NSString * status = [response objectForKey:@"status"];
        if(![status isEqualToString:@"error"]){
            completionBlock(YES, response);
        }else{
            completionBlock(NO, response);
        }
        
        
    });
}









-(BOOL)checkIfTokenExists:(NSString*)token{
    
    NSDictionary * response = [self get:[NSString stringWithFormat:@"https://api.indiesquare.me/v2/tokens/%@",token]];
    
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
        return [NSDictionary dictionaryWithObjectsAndKeys:@"error",@"status",@"response","token already exists", nil];
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
    
    NSDictionary * res = [self post:jsonRequest url:[NSString stringWithFormat:@"https://api.indiesquare.me/v2/files/enhancedtokeninfo/%@",token] andIsJSON:true];
    
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
    
    NSDictionary * res = [self post:jsonRequest url:@"https://api.indiesquare.me/v2/transactions/issuance" andIsJSON:true];
    
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
    
    NSDictionary * res = [self post:jsonRequest url:@"https://api.indiesquare.me/v2/transactions/broadcast" andIsJSON:true];
    
    NSString * httpStatus = [res objectForKey:@"httpStatus"];
    
    
    
    if(![httpStatus isEqualToString:@"200"]){
        
        completionBlock(NO, res);
    }
    else{
         completionBlock(YES, res);
    }
    

   
    
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




@end
