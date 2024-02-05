import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:metamask_connect/utils.dart';
import 'package:metamask_connect/utils/utils.dart';
import 'package:metamask_connect/w3m_service.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';

import 'models/coindata.dart';
import 'utils/custom_double_extension.dart';

class MetamaskHomeScreen extends StatefulWidget {
  const MetamaskHomeScreen({super.key});

  @override
  State<MetamaskHomeScreen> createState() => _MetamaskHomeScreenState();
}

class _MetamaskHomeScreenState extends State<MetamaskHomeScreen> {
  late W3mConnector w3mCtrl = W3mConnector(waletBalanceFetch);
  String signHash = "";
  String txnHash = "";
  CoinData? coinData;
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void waletBalanceFetch(CoinData val) {
    print("updating ");
    setState(() {
      coinData = val;
    });
  }

  @override
  void initState() {
    super.initState();
    w3mCtrl.init();
    w3mCtrl.initService(connectListener);
  }

  @override
  void dispose() {
    super.dispose();
    w3mCtrl.closeService(connectListener);
  }

  void connectListener() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Blockconnect"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12),
          child: SmartRefresher(
            controller: _refreshController,
            onRefresh: () async {
              w3mCtrl.getWalletBalance();
              await Future.delayed(const Duration(seconds: 1));
              _refreshController.refreshCompleted();
            },
            child: Column(
              children: <Widget>[
                const SizedBox(height: 8),
                ...[
                  W3MConnectWalletButton(service: w3mCtrl.service),
                  const SizedBox(height: 10),
                  Visibility(
                    visible: coinData?.remainingAmount != null &&
                        w3mCtrl.service.isConnected,
                    child: Text(
                      "Wallet balance - ${coinData?.remainingAmount} ",
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ],
                const Spacer(),
                if (w3mCtrl.service.isConnected) ...[
                  ElevatedButton(
                    onPressed: () {
                      getMessageDialog();
                    },
                    child: const Text("Sign Message"),
                  ),
                  const SizedBox(height: 8),
                  Visibility(
                      visible: signHash.isNotEmpty,
                      child: Text("Sign hash is $signHash")),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    // onPressed: genTxnHash,
                    onPressed: () async {
                      if (coinData == null) {
                        await w3mCtrl.getWalletBalance();
                      }
                      showTransactionDialog();
                    },
                    child: const Text("Transact"),
                  ),
                  const SizedBox(height: 8),
                  Visibility(
                      visible: txnHash.isNotEmpty,
                      child: Text("transaction hash is $txnHash")),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showTransactionDialog() {
    print("gas fee ${coinData?.gasFee?.toStringAsFixed(18)}");
    TextEditingController amountCtrl = TextEditingController();
    TextEditingController addressCtrl = TextEditingController(
        text: "0x8491C4546977f98F01e7629Dd234882c17d1C86E");
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Transaction Details"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Wallet Balance - ${coinData?.remainingAmount}"),
            const SizedBox(height: 30),
            SizedBox(
              height: 50,
              child: TextField(
                controller: addressCtrl,
                decoration: const InputDecoration(
                  labelText: "Address",
                  isDense: true,
                  suffixIcon: Icon(Icons.qr_code),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 30,
              child: TextField(
                controller: amountCtrl,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                    isDense: true,
                    suffixIcon: GestureDetector(
                      onTap: () {
                        if (coinData != null) {
                          if (coinData!.remainingAmount != null &&
                              coinData!.gasFee != null) {
                            final minAmount = coinData!.gasFee?.toDouble() ?? 0;
                            if (coinData!.remainingAmount! > minAmount) {
                              amountCtrl.text =
                                  (coinData!.remainingAmount! - minAmount)
                                      .reduceByPercent(percent: 0.5)
                                      .toString();
                            }
                          }
                        }
                      },
                      child: Text(
                        "Max",
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                    ),
                    contentPadding: EdgeInsets.zero),
              ),
            ),
            const SizedBox(height: 15),
            if (coinData != null)
              if (coinData!.gasFee != null)
                Text(
                    "Gas Fee - ${(coinData!.gasFee! * pow(10, 18)).toInt()} Wei")
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              createTxn(
                  toAddress: addressCtrl.text,
                  amount: double.parse(amountCtrl.text));
              Navigator.of(ctx).pop();
            },
            child: const Text("Pay"),
          ),
        ],
      ),
    );
  }

  void getMessageDialog() {
    TextEditingController signMessageCtrl = TextEditingController(text: "");
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Enter Message"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 30),
            SizedBox(
              height: 50,
              child: TextField(
                controller: signMessageCtrl,
                decoration: const InputDecoration(
                  labelText: "Message",
                  isDense: true,
                  suffixIcon: Icon(Icons.qr_code),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              if(signMessageCtrl.text.isEmpty) {
                Utils.showToast(message: "Message cannot be empty.") ;
              } else {
                genSignedMsg(message: signMessageCtrl.text);
              }
              Navigator.of(ctx).pop();
            },
            child: const Text("Sign"),
          ),
        ],
      ),
    );
  }

  void createTxn({required String toAddress, required double amount}) async {
    final val = await w3mCtrl.createTransaction(
        toAddress: toAddress, tokenAmount: amount);
    if (val != null) {
      setState(() {
        txnHash = val;
      });
    }
  }

  void genSignedMsg({required String message}) async {
    final val = await w3mCtrl.onPersonalSign(message: message);
    if (val != null) {
      setState(() {
        signHash = val;
      });
    }
  }
}
