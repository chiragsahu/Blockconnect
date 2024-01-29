import 'package:flutter/material.dart';
import 'package:metamask_connect/w3m_service.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';

class MetamaskHomeScreen extends StatefulWidget {
  const MetamaskHomeScreen({super.key});

  @override
  State<MetamaskHomeScreen> createState() => _MetamaskHomeScreenState();
}

class _MetamaskHomeScreenState extends State<MetamaskHomeScreen> {
  W3mConnector w3mCtrl = W3mConnector();
  String signHash = "";
  String txnHash = "";

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
        title: const Text("Blockchain"),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            const SizedBox(height: 8),
            W3MConnectWalletButton(service: w3mCtrl.service),
            const Spacer(),
            if (w3mCtrl.service.isConnected) ...[
              ElevatedButton(
                onPressed: genSignedMsg,
                child: const Text("Personal Sign"),
              ),
              const SizedBox(height: 8),
              Visibility(
                  visible: signHash.isNotEmpty,
                  child: Text("Sign hash is $signHash")),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: genTxnHash,
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
    );
  }

  void genTxnHash() async {
    final val = await w3mCtrl.onCreateTransaction();
    if (val != null) {
      setState(() {
        txnHash = val;
      });
    }
  }

  void genSignedMsg() async {
    final val = await w3mCtrl.onPersonalSign();
    if (val != null) {
      setState(() {
        signHash = val;
      });
    }
  }
}
