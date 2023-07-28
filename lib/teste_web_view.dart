import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:url_launcher/url_launcher.dart';

class MyWebsite extends StatefulWidget {
  const MyWebsite({Key? key}) : super(key: key);
  @override
  State<MyWebsite> createState() => _MyWebsiteState();
}

class _MyWebsiteState extends State<MyWebsite> {
  void requestPermission() async {
    Map<Permission, PermissionStatus> statuses =
        await [Permission.location].request();
  }

  @override
  void initState() {
    super.initState();
    requestPermission();
  }

  double _progress = 0;
  late InAppWebViewController inAppWebViewController;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        var isLastPage = await inAppWebViewController.canGoBack();
        if (isLastPage) {
          inAppWebViewController.goBack();
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: Stack(
          children: [
            InAppWebView(
              initialUrlRequest: URLRequest(
                  url: Uri.parse(
                      "https://srm-operacoes-financeiras-cliente-homologacao.srmasset.com/#/login")),
              onWebViewCreated: (InAppWebViewController controller) {
                inAppWebViewController = controller;
              },
              shouldOverrideUrlLoading: (controller, navigationAction) async {
                print("URL REQUEST >> ");
                final uri = navigationAction.request.url;

                return NavigationActionPolicy.ALLOW;
              },
              onReceivedServerTrustAuthRequest: (controller, challenge) async {
                return ServerTrustAuthResponse(
                    action: ServerTrustAuthResponseAction.PROCEED);
              },
              androidOnPermissionRequest: (InAppWebViewController controller,
                  String origin, List<String> resources) async {
                return PermissionRequestResponse(
                    resources: resources,
                    action: PermissionRequestResponseAction.GRANT);
              },
              onProgressChanged:
                  (InAppWebViewController controller, int progress) {
                setState(() {
                  _progress = progress / 100;
                });
              },
              onLoadStop: (controller, url) {
                print("start onLoadStop");
                print('onLoadStop ${url.toString()}');

      
                if (url.toString().startsWith('intent')) {
                  var decoded = Uri.decodeFull(url.toString());
                  decoded = decoded.replaceAll('intent://access?u=', '');

                  print('URL undecoded: ' + decoded);

                  List<String> stringParts = decoded.split('&');

                  var urlDocument = stringParts.first;

                  print('URL urlDocument: ' + urlDocument);

                  setState(() async {
                    if (!await launchUrl(
                        Uri.parse(urlDocument),
                        mode: LaunchMode.externalApplication)) {
                      throw 'Could not launch ';
                    }

                    URLRequest urlRequest = URLRequest(
                        url: Uri.parse(
                            'https://signer.srmasset.com/private/documents/7b2b9aa6-07a8-468d-a4b3-f87a547dde28/sign'));
                    controller.loadUrl(urlRequest: urlRequest);
                    print("end onLoadStop");
                  });
                }
              },
              onLoadError: (_, __, ___, ____) {
                setState(() {
                  print("onLoadError");
                });
              },
              onLoadHttpError: (_, __, ___, ____) {
                setState(() {
                  print("onLoadHttpError");
                });
              },
            ),
            _progress < 1
                ? Container(
                    child: LinearProgressIndicator(
                      value: _progress,
                    ),
                  )
                : SizedBox()
          ],
        ),
      ),
    );
  }
}
