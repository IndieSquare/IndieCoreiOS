//
//  IndieCore.h
//  IndieCore
//
//  Created by Chris on 25/10/2016.
//  Copyright © 2016 IndieSquare. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class IndieCore;
@protocol IndieCoreDelegate <NSObject>
@optional
- (void)didSignTransaction:(NSString*)signedTx;
- (void)signTransactionError:(NSString*)errorMessage;
- (void)didGenerateAddress:(NSString*)address;
- (void)generateAddressError:(NSString*)errorMessage;
- (void)didCreateWallet:(NSString*)passphrase;
- (void)createWalletError:(NSString*)errorMessage;
- (void)didInitiateCore:(NSString*)message;
- (void)didCheckAddressValid:(BOOL)isValid;
- (void)didGenerateRandomDetailedWallet:(NSString*)privateKey andWif:(NSString*)wif andPublicKey:(NSString*)publicKey andAddress:(NSString*)address;
- (void)didCreateNumericTokenName:(NSString*)tokenName;
@end


@interface IndieCore : NSObject<UIWebViewDelegate>

typedef void (^completionBlock)(BOOL success, NSDictionary *response);

-(id)initWithViewController:(UIViewController*)parentController andAPIKey:(NSString*)apiKey;
-(void)signTransacation:(NSString*)tx andPassphrase:(NSString*)passphrase andIndex:(int)index andDestination:(NSString*)destination;
-(void)signTransacation:(NSString*)tx andPassphrase:(NSString*)passphrase andIndex:(int)index;
-(void)createNewWallet;
-(void)generateAddressForPassphrase:(NSString*)passphrase andIndex:(int)index;
-(void)generateRandomDetailedWallet;
-(void)checkIfAddressIsValid:(NSString*)passphrase;



-(void)broadcastTransaction:(NSString*)signedTx andCompletion:(completionBlock)completionBlock;

-(BOOL)checkIfTokenExists:(NSString*)token;

-(void)createNumericTokenName;

-(NSDictionary*)issueToken:(NSString*)source andTokenName:(NSString*)token andQuantity:(double)quantity andDivisible:(BOOL)divisible;
-(NSDictionary*)issueToken:(NSString*)source andTokenName:(NSString*)token andQuantity:(double)quantity andDivisible:(BOOL)divisible andDescription:(NSString*)description;
-(NSDictionary*)issueToken:(NSString*)source andTokenName:(NSString*)token andQuantity:(double)quantity andDivisible:(BOOL)divisible andDescription:(NSString*)description andWebsiteURL:(NSString*)websiteURL;
-(NSDictionary*)issueToken:(NSString*)source andTokenName:(NSString*)token andQuantity:(double)quantity andDivisible:(BOOL)divisible andDescription:(NSString*)description andWebsiteURL:(NSString*)websiteURL andImageURL:(NSString*)imageURL;
-(NSDictionary*)issueToken:(NSString*)source andTokenName:(NSString*)token andQuantity:(double)quantity andDivisible:(BOOL)divisible andDescription:(NSString*)description andWebsiteURL:(NSString*)websiteURL andImageURL:(NSString*)imageURL andFee:(int)fee;
-(NSDictionary*)issueToken:(NSString*)source andTokenName:(NSString*)token andQuantity:(double)quantity andDivisible:(BOOL)divisible andDescription:(NSString*)description andWebsiteURL:(NSString*)websiteURL andImageURL:(NSString*)imageURL andFee:(int)fee andFeePerKB:(int)feePerKB;


-(void)issueToken:(NSString*)source andTokenName:(NSString*)token andQuantity:(double)quantity andDivisible:(BOOL)divisible andCompletion:(completionBlock)completionBlock;
-(void)issueToken:(NSString*)source andTokenName:(NSString*)token andQuantity:(double)quantity andDivisible:(BOOL)divisible andDescription:(NSString*)description andCompletion:(completionBlock)completionBlock;

-(void)issueToken:(NSString*)source andTokenName:(NSString*)token andQuantity:(double)quantity andDivisible:(BOOL)divisible andDescription:(NSString*)description andWebsiteURL:(NSString*)websiteURL andCompletion:(completionBlock)completionBlock;

-(void)issueToken:(NSString*)source andTokenName:(NSString*)token andQuantity:(double)quantity andDivisible:(BOOL)divisible andDescription:(NSString*)description andWebsiteURL:(NSString*)websiteURL andImageURL:(NSString*)imageURL andCompletion:(completionBlock)completionBlock;

-(void)issueToken:(NSString*)source andTokenName:(NSString*)token andQuantity:(double)quantity andDivisible:(BOOL)divisible andDescription:(NSString*)description andWebsiteURL:(NSString*)websiteURL andImageURL:(NSString*)imageURL andFee:(int)fee andCompletion:(completionBlock)completionBlock;

-(void)issueToken:(NSString*)source andTokenName:(NSString*)token andQuantity:(double)quantity andDivisible:(BOOL)divisible andDescription:(NSString*)description andWebsiteURL:(NSString*)websiteURL andImageURL:(NSString*)imageURL andFee:(int)fee andFeePerKB:(int)feePerKB andCompletion:(completionBlock)completionBlock;



@property BOOL isDev;
@property(nonatomic,strong)UIWebView * webView;
@property(nonatomic,strong)NSString*apiKey;
@property BOOL webViewLoaded;
@property (nonatomic, weak) id <IndieCoreDelegate> delegate;
@end

