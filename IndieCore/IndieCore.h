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
- (void)didGenerateRandomDetailedWallet;
- (void)didCreateNumericTokenName:(NSString*)tokenName;
-(void)didGetBalance:(NSDictionary*)balance;
-(void)didGetBalanceError:(NSString*)error;

@end


@interface IndieCore : NSObject<UIWebViewDelegate>

typedef void (^completionBlock)(NSError* error, NSDictionary *response);

-(id)initWithViewController:(UIViewController*)parentController andAPIKey:(NSString*)apiKey andTestNet:(bool)testnet andCompletion:(completionBlock)completionBlock;
-(void)signTransacation:(NSString*)tx andPassphrase:(NSString*)passphrase andIndex:(int)index andDestination:(NSString*)destination andCompletion:(completionBlock)completionBlock;
-(void)signTransacation:(NSString*)tx andPassphrase:(NSString*)passphrase andIndex:(int)index andCompletion:(completionBlock)completionBlock;
-(void)createNewWallet:(completionBlock)completionBlock;
-(void)generateAddressForPassphrase:(NSString*)passphrase andIndex:(int)index andCompletion:(completionBlock)completionBlock;
-(void)generateRandomDetailedWallet:(completionBlock)completionBlock;
-(void)checkIfAddressIsValid:(NSString*)passphrase andCompletion:(completionBlock)completionBlock;

-(void)verifyMessage:(NSString*)message andSignature:(NSString*)signature andAddress:(NSString*)address andCompletion:(completionBlock)completionBlock;
-(void)signMessage:(NSString*)message andPassphrase:(NSString*)passphrase andIndex:(int)index andCompletion:(completionBlock)completionBlock;

-(void)broadcastTransaction:(NSString*)signedTx andCompletion:(completionBlock)completionBlock  __deprecated_msg("use broadcast instead");

-(BOOL)checkIfTokenExists:(NSString*)token;

-(void)createNumericTokenName:(completionBlock)completionBlock;



-(void)createSendTransaction:(NSString*)source andTokenName:(NSString*)token andDestination:(NSString*)destination andQuantity:(double)quantity andCompletion:(completionBlock)completionBlock  __deprecated_msg("use createSend instead");

-(void)createSendTransaction:(NSString*)source andTokenName:(NSString*)token andDestination:(NSString*)destination andQuantity:(double)quantity andFee:(int)fee andCompletion:(completionBlock)completionBlock  __deprecated_msg("use createSend instead");

-(void)createSendTransaction:(NSString*)source andTokenName:(NSString*)token andDestination:(NSString*)destination andQuantity:(double)quantity andFeePerKB:(int)feePerKB andCompletion:(completionBlock)completionBlock  __deprecated_msg("use createSend instead");



-(void)createOrderTransaction:(NSString*)source andGiveQuantity:(double)giveQuantity andGiveToken:(NSString*)giveToken andGetQuantity:(double)getQuantity andGetToken:(NSString*)getToken andExpiration:(int)expiration andCompletion:(completionBlock)completionBlock  __deprecated_msg("use createOrder instead");

-(void)createOrderTransaction:(NSString*)source andGiveQuantity:(double)giveQuantity andGiveToken:(NSString*)giveToken andGetQuantity:(double)getQuantity andGetToken:(NSString*)getToken andExpiration:(int)expiration andFee:(int)fee andCompletion:(completionBlock)completionBlock __deprecated_msg("use createOrder instead");

-(void)createOrderTransaction:(NSString*)source andGiveQuantity:(double)giveQuantity andGiveToken:(NSString*)giveToken andGetQuantity:(double)getQuantity andGetToken:(NSString*)getToken andExpiration:(int)expiration andFeePerKB:(int)feePerKB andCompletion:(completionBlock)completionBlock __deprecated_msg("use createOrder instead");


-(void)cancelOrder:(NSString*)source andOfferHash:(NSString*)offerHash andCompletion:(completionBlock)completionBlock __deprecated_msg("use createCancel instead");
-(void)cancelOrder:(NSString*)source andOfferHash:(NSString*)offerHash andFee:(int)fee andCompletion:(completionBlock)completionBlock __deprecated_msg("use createCancel instead");
-(void)cancelOrder:(NSString*)source andOfferHash:(NSString*)offerHash andFeePerKB:(int)feePerKB andCompletion:(completionBlock)completionBlock __deprecated_msg("use createCancel instead");









-(NSDictionary*)issueToken:(NSString*)source andTokenName:(NSString*)token andQuantity:(double)quantity andDivisible:(BOOL)divisible __deprecated_msg("use createIssuance instead");
-(NSDictionary*)issueToken:(NSString*)source andTokenName:(NSString*)token andQuantity:(double)quantity andDivisible:(BOOL)divisible andDescription:(NSString*)description __deprecated_msg("use createIssuance instead");
-(NSDictionary*)issueToken:(NSString*)source andTokenName:(NSString*)token andQuantity:(double)quantity andDivisible:(BOOL)divisible andDescription:(NSString*)description andWebsiteURL:(NSString*)websiteURL __deprecated_msg("use createIssuance instead");
-(NSDictionary*)issueToken:(NSString*)source andTokenName:(NSString*)token andQuantity:(double)quantity andDivisible:(BOOL)divisible andDescription:(NSString*)description andWebsiteURL:(NSString*)websiteURL andImageURL:(NSString*)imageURL __deprecated_msg("use createIssuance instead");
-(NSDictionary*)issueToken:(NSString*)source andTokenName:(NSString*)token andQuantity:(double)quantity andDivisible:(BOOL)divisible andDescription:(NSString*)description andWebsiteURL:(NSString*)websiteURL andImageURL:(NSString*)imageURL andFee:(int)fee __deprecated_msg("use createIssuance instead");
-(NSDictionary*)issueToken:(NSString*)source andTokenName:(NSString*)token andQuantity:(double)quantity andDivisible:(BOOL)divisible andDescription:(NSString*)description andWebsiteURL:(NSString*)websiteURL andImageURL:(NSString*)imageURL andFee:(int)fee andFeePerKB:(int)feePerKB __deprecated_msg("use createIssuance instead");


-(void)issueToken:(NSString*)source andTokenName:(NSString*)token andQuantity:(double)quantity andDivisible:(BOOL)divisible andCompletion:(completionBlock)completionBlock __deprecated_msg("use createIssuance instead");
-(void)issueToken:(NSString*)source andTokenName:(NSString*)token andQuantity:(double)quantity andDivisible:(BOOL)divisible andDescription:(NSString*)description andCompletion:(completionBlock)completionBlock __deprecated_msg("use createIssuance instead");

-(void)issueToken:(NSString*)source andTokenName:(NSString*)token andQuantity:(double)quantity andDivisible:(BOOL)divisible andDescription:(NSString*)description andWebsiteURL:(NSString*)websiteURL andCompletion:(completionBlock)completionBlock __deprecated_msg("use createIssuance instead");

-(void)issueToken:(NSString*)source andTokenName:(NSString*)token andQuantity:(double)quantity andDivisible:(BOOL)divisible andDescription:(NSString*)description andWebsiteURL:(NSString*)websiteURL andImageURL:(NSString*)imageURL andCompletion:(completionBlock)completionBlock __deprecated_msg("use createIssuance instead");

-(void)issueToken:(NSString*)source andTokenName:(NSString*)token andQuantity:(double)quantity andDivisible:(BOOL)divisible andDescription:(NSString*)description andWebsiteURL:(NSString*)websiteURL andImageURL:(NSString*)imageURL andFee:(int)fee andCompletion:(completionBlock)completionBlock __deprecated_msg("use createIssuance instead");

-(void)issueToken:(NSString*)source andTokenName:(NSString*)token andQuantity:(double)quantity andDivisible:(BOOL)divisible andDescription:(NSString*)description andWebsiteURL:(NSString*)websiteURL andImageURL:(NSString*)imageURL andFee:(int)fee andFeePerKB:(int)feePerKB andCompletion:(completionBlock)completionBlock __deprecated_msg("use createIssuance instead");


//javascript sdk functions
-(void)getBalance:(NSString*)source andCompletion:(completionBlock)completionBlock;
-(void)getHistory:(NSString*)source andCompletion:(completionBlock)completionBlock;
-(void)getTokenInfo:(NSString*)token andCompletion:(completionBlock)completionBlock;
-(void)getTokenHolders:(NSString*)token andCompletion:(completionBlock)completionBlock;
-(void)getTokenHistory:(NSString*)token andCompletion:(completionBlock)completionBlock;
-(void)getTokenDescription:(NSString*)token andCompletion:(completionBlock)completionBlock;


-(void)createSend:(NSString*)source andTokenName:(NSString*)token andDestination:(NSString*)destination andQuantity:(double)quantity andCompletion:(completionBlock)completionBlock;

-(void)createSend:(NSString*)source andTokenName:(NSString*)token andDestination:(NSString*)destination andQuantity:(double)quantity andFee:(int)fee andFeePerKB:(int)feePerKB andCompletion:(completionBlock)completionBlock;
-(void)createSend:(NSString*)source andTokenName:(NSString*)token andDestination:(NSString*)destination andQuantity:(double)quantity andFee:(int)fee andCompletion:(completionBlock)completionBlock;

-(void)createIssuance:(NSString*)source andTokenName:(NSString*)token andQuantity:(double)quantity andDivisible:(BOOL)divisible andCompletion:(completionBlock)completionBlock;
-(void)createIssuance:(NSString*)source andTokenName:(NSString*)token andQuantity:(double)quantity andDivisible:(BOOL)divisible andDescription:(NSString*)description andCompletion:(completionBlock)completionBlock;
-(void)createIssuance:(NSString*)source andTokenName:(NSString*)token andQuantity:(double)quantity andDivisible:(BOOL)divisible andDescription:(NSString*)description andWebsiteURL:(NSString*)websiteURL andCompletion:(completionBlock)completionBlock;
-(void)createIssuance:(NSString*)source andTokenName:(NSString*)token andQuantity:(double)quantity andDivisible:(BOOL)divisible andDescription:(NSString*)description andWebsiteURL:(NSString*)websiteURL andImageURL:(NSString*)imageURL andCompletion:(completionBlock)completionBlock;
-(void)createIssuance:(NSString*)source andTokenName:(NSString*)token andQuantity:(double)quantity andDivisible:(BOOL)divisible andDescription:(NSString*)description andWebsiteURL:(NSString*)websiteURL andImageURL:(NSString*)imageURL andFee:(int)fee andCompletion:(completionBlock)completionBlock;
-(void)createIssuance:(NSString*)source andTokenName:(NSString*)token andQuantity:(double)quantity andDivisible:(BOOL)divisible andDescription:(NSString*)description andWebsiteURL:(NSString*)websiteURL andImageURL:(NSString*)imageURL andFee:(int)fee andFeePerKB:(int)feePerKB andCompletion:(completionBlock)completionBlock;


-(void)createOrder:(NSString*)source andGiveQuantity:(double)giveQuantity andGiveToken:(NSString*)giveToken andGetQuantity:(double)getQuantity andGetToken:(NSString*)getToken andExpiration:(int)expiration andCompletion:(completionBlock)completionBlock;

-(void)createOrder:(NSString*)source andGiveQuantity:(double)giveQuantity andGiveToken:(NSString*)giveToken andGetQuantity:(double)getQuantity andGetToken:(NSString*)getToken andExpiration:(int)expiration andFee:(int)fee  andCompletion:(completionBlock)completionBlock;

-(void)createOrder:(NSString*)source andGiveQuantity:(double)giveQuantity andGiveToken:(NSString*)giveToken andGetQuantity:(double)getQuantity andGetToken:(NSString*)getToken andExpiration:(int)expiration andFeePerKB:(int)feePerKB   andCompletion:(completionBlock)completionBlock;

-(void)createOrder:(NSString*)source andGiveQuantity:(double)giveQuantity andGiveToken:(NSString*)giveToken andGetQuantity:(double)getQuantity andGetToken:(NSString*)getToken andExpiration:(int)expiration andFee:(int)fee  andFeePerKB:(int)feePerKB andCompletion:(completionBlock)completionBlock;

-(void)createCancel:(NSString*)source andOfferHash:(NSString*)offerHash andCompletion:(completionBlock)completionBlock;
-(void)createCancel:(NSString*)source andOfferHash:(NSString*)offerHash andFee:(int)fee andCompletion:(completionBlock)completionBlock;

-(void)createCancel:(NSString*)source andOfferHash:(NSString*)offerHash andFeePerKB:(int)feePerKB andCompletion:(completionBlock)completionBlock;
-(void)createCancel:(NSString*)source andOfferHash:(NSString*)offerHash andFee:(int)fee andFeePerKB:(int)feePerKB andCompletion:(completionBlock)completionBlock;


-(void)broadcast:(NSString*)signedTx andCompletion:(completionBlock)completionBlock;

-(void)signTransactionWithWallet:(NSString*)myUrlScheme andTx:(NSString *)unsignedTx andCompletion:(completionBlock)completionBlock;
-(void)getAddressFromWallet:(NSString*)myUrlScheme andCompletion:(completionBlock)completionBlock;

@property completionBlock currentCompletion;
@property BOOL testnet;
@property BOOL isDev;
@property (nonatomic,strong)NSString*baseUrl;
@property (nonatomic,strong)NSString*base;
@property(nonatomic,strong)UIWebView * webView;
@property(nonatomic,strong)NSString*apiKey;
@property BOOL webViewLoaded;
@property (nonatomic, weak) id <IndieCoreDelegate> delegate;
@end

