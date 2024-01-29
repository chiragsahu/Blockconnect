import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:metamask_connect/utils.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';

class W3mConnector {
  late W3MService _w3mService;
  final _amount = 0.001;

  W3MService get service => _w3mService;

  late final W3MChainInfo _sepoliaChain = W3MChainInfo(
    chainName: 'Sepolia',
    namespace: 'eip155:${Utils.sepoliaChainId}',
    chainId: Utils.sepoliaChainId,
    tokenName: 'ETH',
    rpcUrl: 'https://rpc.sepolia.org/',
    blockExplorer: W3MBlockExplorer(
      name: 'Sepolia Explorer',
      url: 'https://sepolia.etherscan.io/',
    ),
  );

  initService(VoidCallback func) {
    _w3mService.addListener(func);
  }

  closeService(VoidCallback func) {
    _w3mService.removeListener(func);
  }

  Future<String?> onCreateTransaction() async {
    double val = _amount * pow(10, 18).toDouble();
    final finalAmt = val.toInt().toRadixString(16);
    debugPrint("amount ${val.toInt().toRadixString(16)}");

    await _w3mService.launchConnectedWallet();
    var hash = await _w3mService.web3App?.request(
      topic: _w3mService.session!.topic!,
      chainId: 'eip155:${Utils.sepoliaChainId}',
      request: SessionRequestParams(
        method: 'eth_sendTransaction',
        params: [
          {
            "from": _w3mService.session?.address,
            "to": "0x8491C4546977f98F01e7629Dd234882c17d1C86E",
            "data": "0x",
            // "gasPrice": "0x029104e28c",
            // "gas": "0x5208",
            "value": finalAmt,
          }
        ],
      ),
    );
    return hash;
  }

  Future<String?> onPersonalSign() async {
    await _w3mService.launchConnectedWallet();
    var hash = await _w3mService.web3App?.request(
      topic: _w3mService.session!.topic!,
      chainId: 'eip155:${Utils.sepoliaChainId}',
      request: SessionRequestParams(
        method: 'personal_sign',
        params: ['Hello World!!', _w3mService.session?.address],
      ),
    );
    return hash;
  }

  void init() async {
    W3MChainPresets.chains
        .putIfAbsent(Utils.sepoliaChainId, () => _sepoliaChain);
    _w3mService = W3MService(
      projectId: '91fea5ea39fc5898af040c6fd6c478c2',
      metadata: const PairingMetadata(
        name: 'Blockchain on Flutter',
        description: 'Blockchain Demo',
        url: 'https://www.walletconnect.com/',
        icons: ['https://walletconnect.com/walletconnect-logo.png'],
        redirect: Redirect(
          native: 'flutterdapp://',
          universal: 'https://www.walletconnect.com',
        ),
      ),
      featuredWalletIds: {Utils.metamaskId},
    );
    await _w3mService.init();
  }

  disconnect() {
    _w3mService.disconnect();
  }
}
