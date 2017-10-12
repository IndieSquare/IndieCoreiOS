# IndieCoreiOS

# Description
iOS SDK for IndieSquare API written in objective-c, futher api documentation can be found [here](https://developer.indiesquare.me/)
 
# Installation

Download the .bundle and .a files from the releases section or download the xcode project file and include it in your own project. Make sure to add the IndieCore.bundle to "Copy Bundle Resources" and libIndieCore.a to "Link Binary With Library" under "build phases"

See the example project below for set up and usage, (all results are logged in the console)
[example project demo app](https://github.com/IndieSquare/IndieCoreiOSExampleApp)

# Basic Usage
Full usage can be seen in the example project below (all results are logged in the console)
[example project demo app](https://github.com/IndieSquare/IndieCoreiOSExampleApp)

# Example Usage

## Create a send transcation and request signing on the users IndieSquare Wallet

First initialize IndieCore in your main viewcontroller and wait for callback
```
 self.iCore = [[IndieCore alloc] initWithViewController:self andAPIKey:@"fd244d6b1660b353fb58c8c31ec91a3d" andTestNet:false andCompletion:^(NSError*error, NSDictionary *response) {
        NSLog(@"%@",response);
  //is initialised
    }];

 ```
Create a send transaction
```
   [self.iCore createSend:@"12sWrxRY7E7Nhmuyjbz4TtGE9jRewGqEZD" andTokenName:@"NETX" andDestination:@"1M1LeAiECEiGb1n8pEBdoybRw6e5gQD34w" andQuantity:1 andCompletion:^(NSError *error, NSDictionary *response) {
         NSLog(@"response %@",response);
         //unsigned tx is returned here
    }];
 ```
Sign transaction with users installed IndieSquare Wallet
 ```  
[self.iCore signTransactionWithWallet:@"MYURLSCHEME" andTx:unsigned_hex andCompletion:^(NSError *error, NSDictionary *response) {
           NSLog(@"sig %@",response);
           //signed transaction is returned here
    }];
   ``` 
Broadast signed transaction
```
 [self.iCore broadcast:signedTx andCompletion:^(NSError *error, NSDictionary *response) {
          NSLog(@"response: %@",response);
        //returns tx id
    }];
    
 ```
 
## Request user's IndieSquare wallet address and verify user owns address through message signature

You must add your apps urlscheme (represented by MYURLSCHEME) in your plist, so IndieSquare and return to your app after users authorizes address usage.

```
 [self.iCore getAddressFromWallet:@"MYURLSCHEME" andCompletion:^(NSError *error, NSDictionary *response) {
         NSLog(@"address %@",response);
        //returns users address is verified or error if unable to verify
    }];
```

# Further Reading

* [Official Project Documentation](https://developer.indiesquare.me)
