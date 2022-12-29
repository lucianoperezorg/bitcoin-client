# Bitcoin-client

## Techology and software used: 
 Xcode version 14.1 
 Minimum target iOS 11

## Open Project
Double click in the workspace `bitcoin-client.xcworkspace`

## Run the app
Select the target `iOS` then press run.

## Project architecture
The project is divided into 3 layers, iOS, Domain, and HTTPNetwork.
- `iOS` is where the UI logic is. MVVM is used to separate the UI logic from the view controllers.
- `Domain` is where all the app logic is contained. This is the Mac framework.
- `HTTPNetwork` is where all the concrete HTTP implementation is. This is the Mac framework.

The reason why `Domain` and `HTTPNetwork` layers are mac framework is because they are agnostic to any UI implementation and also to speed up the testing in the app.

You can change the refresh frequency or the amount of day for the bitcoin Historical price in the struct `Config.swift`.

## API used
The website to retrieve the Bitcoin prices is `coingecko.com`, please see the following URL for details: 
https://www.coingecko.com/en/api/documentation

The app uses 3 different endpoints to get the data. 

The first screen uses the following 2 URLs:
- https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=eur
This URL is to get the current price every some time, this is a quite light payload, and that was the reason why this was selected.


The second screen use the following URL:
- https://api.coingecko.com/api/v3/coins/bitcoin/market_chart?vs_currency=eur&days=20&interval=daily
This URL gets the bitcoin historical price for some days and intervals.


The second screen uses the following URL:
- https://api.coingecko.com/api/v3/coins/bitcoin/history?date=01-12-2022&localization=false
This URL provides the bitcoin price for a particular date in different currencies.

## Run test
Select the target you want to test then press ctr+U.
Targets avaialble: `iOS`, `Domain`, `HTTPNetwork`, `UnitTestAllModule` `iOSUIEndToEndTest`.

`UnitestAllModule` contains all module unit tests but you can run them independently by selecting the schema and then ctrl+u.
iOSUIEndToEndTest is a minimal UI test to test the navigation. This schema is not meant to be run everytime. It can be run every time someone merges a new branch to develop a branch or when the app is going to be released.

## Author
Luciano Perez 
