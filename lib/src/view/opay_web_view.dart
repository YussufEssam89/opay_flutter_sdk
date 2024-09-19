
// ignore_for_file: must_be_immutable

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:opay_flutter_sdk/src/model/web_js_response.dart';
import 'package:webview_flutter/webview_flutter.dart';

class OPayWebView extends StatefulWidget{

  String webUrl;
  bool isLocalUrl;
  Function(WebJsResponse?) backIconFunc;



  OPayWebView({Key? key, this.webUrl="",this.isLocalUrl=false,required this.backIconFunc}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // ignore: no_logic_in_create_state
    return _OPayWebView();
  }
}

class _OPayWebView extends State<OPayWebView>{

  int _currentProgress=0;
  late WebViewController _webViewController;

  _OPayWebView();

  @override
  void initState() {
    super.initState();

    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..enableZoom(false)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            setState(() {
              _currentProgress = progress;
            });
          },
          onPageStarted: (String url) {
            debugPrint('Page started loading: $url');
          },
          onPageFinished: (String url) {
            debugPrint('Page finished loading: $url');
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('''
              Page resource error:
                code: ${error.errorCode}
                description: ${error.description}
                errorType: ${error.errorType}
                isForMainFrame: ${error.isForMainFrame}
            ''');
          },
          onNavigationRequest: (NavigationRequest request) {
            debugPrint(request.url);
            if(!request.url.startsWith("http")){
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onHttpError: (HttpResponseError error) {
            debugPrint('Error occurred on page: ${error.response?.statusCode}');
          },
          onUrlChange: (UrlChange change) {
            debugPrint('url change to ${change.url}');
          },
          onHttpAuthRequest: (HttpAuthRequest request) {
            //
          },
        ),
      )
      ..addJavaScriptChannel(
        'clickResultOKBtn',
        onMessageReceived: (JavaScriptMessage message) {
          String resultMsg = message.message;
          Map<String,dynamic> map = json.decode(resultMsg);
          WebJsResponse response = WebJsResponse.fromJson(map);
          _finishPage(response);
        },
      )
      ..addJavaScriptChannel(
        'clickResultCancelBtn',
        onMessageReceived: (JavaScriptMessage message) {
          String resultMsg = message.message;
          Map<String,dynamic> map = json.decode(resultMsg);
          WebJsResponse response = WebJsResponse.fromJson(map);
          _finishPage(response);
        },
      )
      ..addJavaScriptChannel(
        'clickReferenceCodeReturnBtn',
        onMessageReceived: (JavaScriptMessage message) {
          String resultMsg = message.message;
          Map<String,dynamic> map = json.decode(resultMsg);
          WebJsResponse response = WebJsResponse.fromJson(map);
          _finishPage(response);
        },
      )
      ..loadRequest(
          Uri.parse(
              widget.isLocalUrl ? Uri.dataFromString(widget.webUrl, mimeType: 'text/html', encoding: Encoding.getByName('utf-8'))
                  .toString(): widget.webUrl
          )
      );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: _buildBody()
    );
  }

  @override
  void dispose(){
    super.dispose();

  }


  Visibility _linearProgressIndicator(){
    return Visibility(
        visible: _currentProgress<100,
        child: LinearProgressIndicator(
          value: _currentProgress/100.0, // 当前进度
          backgroundColor: const Color(0xFFEEEEEE), // 进度条背景色
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.red), // 进度条当前进度颜色
          minHeight: 4, // 最小宽度
        ));
  }

  _buildBody() {
    return Column(

      children: <Widget>[
        const SizedBox(
          height: 1,
          width: double.infinity,
          child: DecoratedBox(decoration: BoxDecoration(color: Color(0xFFEEEEEE))),
        ),
        _linearProgressIndicator(),
        Expanded(
          flex: 1,
          child: WebViewWidget(
            controller: _webViewController,
          ),
        )
      ],
    );
  }

  _finishPage(WebJsResponse? webJsResponse){
    widget.backIconFunc(webJsResponse);
  }
}