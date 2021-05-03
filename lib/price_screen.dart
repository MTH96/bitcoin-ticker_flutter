import 'package:bitcoin_ticker/coin_data.dart';
import 'package:bitcoin_ticker/networking.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io' show Platform;

const aPIURL = 'https://rest.coinapi.io/v1/exchangerate';
const apiKey = '78ED9D18-6A89-44F6-9364-F96A94734CC8';

class PriceScreen extends StatefulWidget {
  @override
  _PriceScreenState createState() => _PriceScreenState();
}

class _PriceScreenState extends State<PriceScreen> {
  String seletedCurrency = 'USD';
  String bTCRate = '?';
  String eTHRate = '?';
  String lTCRate = '?';
  List bTCdata;
  List eTHdata;
  List lTCdata;
  bool error = false;
  String errorMsg = '';

  Widget androidDropMenu() {
    List<DropdownMenuItem<String>> itemsList = [];

    for (String currency in currenciesList)
      itemsList.add(DropdownMenuItem(child: Text(currency), value: currency));

    return DropdownButton<String>(
      value: seletedCurrency,
      items: itemsList,
      onChanged: (value) {
        updateUI(value);
      },
    );
  }

  Widget iOSPicker() {
    List<Widget> itemList = [];
    for (String currency in currenciesList) itemList.add(Text(currency));
    return CupertinoPicker(
      backgroundColor: Colors.lightBlue,
      itemExtent: 32.0,
      onSelectedItemChanged: (selectedIndex) {
        updateUI(currenciesList[selectedIndex]);
      },
      children: itemList,
    );
  }

  Future<List> getData({String cryptoCurr, String realCurr}) async {
    NetworkHelper networkHelper = NetworkHelper(
      url: '$aPIURL/$cryptoCurr/$realCurr?apikey=$apiKey',
    );
    List data = await networkHelper.getData();
    return data;
  }

  void updateUI(String toCurrency) async {
    setState(() {
      seletedCurrency = toCurrency;
      bTCRate = '?';
      eTHRate = '?';
      lTCRate = '?';
      error = false;
    });
    try {
      bTCdata = await getData(cryptoCurr: 'BTC', realCurr: seletedCurrency);
      eTHdata = await getData(cryptoCurr: 'ETH', realCurr: seletedCurrency);
      lTCdata = await getData(cryptoCurr: 'LTC', realCurr: seletedCurrency);
    } catch (e) {
      print(e);
    }
    setState(() {
      if (bTCdata[0]) {
        //connection worked

        if (bTCdata[1]) {
          bTCRate = bTCdata[2]['rate'].toStringAsFixed(2);
          eTHRate = eTHdata[2]['rate'].toStringAsFixed(2);
          lTCRate = lTCdata[2]['rate'].toStringAsFixed(2);
          seletedCurrency = toCurrency;
        } else {
          bTCRate = 'error';
          eTHRate = 'error';
          lTCRate = 'error';
          error = true;
          errorMsg = bTCdata[2]['error'];
        }
      } else {
        bTCRate = 'error';
        eTHRate = 'error';
        lTCRate = 'error';
        error = true;
        errorMsg = bTCdata[2];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('🤑 Coin Ticker'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CurrencyCard(
                  cryptoCur: 'BTC', rate: bTCRate, realCur: seletedCurrency),
              CurrencyCard(
                  cryptoCur: 'ETH', rate: eTHRate, realCur: seletedCurrency),
              CurrencyCard(
                  cryptoCur: 'LTC', rate: lTCRate, realCur: seletedCurrency)
            ],
          ),
          Container(
            child: error
                ? Text(errorMsg,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.red, fontSize: 20.0))
                : null,
          ),
          Container(
            height: 150.0,
            alignment: Alignment.center,
            padding: EdgeInsets.only(bottom: 30.0),
            color: Colors.lightBlue,
            child: Platform.isIOS ? iOSPicker() : androidDropMenu(),
          ),
        ],
      ),
    );
  }
}

class CurrencyCard extends StatelessWidget {
  final String cryptoCur;
  final String rate;
  final String realCur;

  CurrencyCard({this.cryptoCur, this.rate, this.realCur});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(18.0, 18.0, 18.0, 0),
      child: Card(
        color: Colors.lightBlueAccent,
        elevation: 5.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 28.0),
          child: Text(
            '1 $cryptoCur = $rate $realCur',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20.0,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
