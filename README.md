# Bitcoin-client

## Techology and software used: 
 Xcode version 14.1 
 Minimum target iOS 11

## Project rchitecture
The project is divided into 3 layers, iOS, Domain, and HTTPNetwork.
- `iOS` is where the UI logic is. MVVM is used to separate the UI logic from the view controllers.
- `Domain` is where all the app logic is contained. This is the Mac framework.
- `HTTPNetwork` is where all the concrete HTTP implementation is. This is the Mac framework.

The reason why `Domain` and `HTTPNetwork` layers are mac framework is becaise they are agnostic to any UI implementation and also to speed up the testing in the app.

*** Coordinator pattern was not implemented because the app is quite small which implemented it would overengineer the implementation.


## API used
The website to retrieve the information is coingecko.com, please see the following URL for details: 
https://www.coingecko.com/en/api/documentation
The reason for not using www.coindesk.com is that the website provided was not working (http://www.coindesk.com/api/).
Also, a coindesk endpoint to get the historical price seems to be not working.

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

## Run the app
Select the target `iOS` then select run.

## Run test
Select the target you want to test then press ctr+U.
Targets avaialble: iOS, Domain and HTTPNetwork.

## Author
Luciano Perez 