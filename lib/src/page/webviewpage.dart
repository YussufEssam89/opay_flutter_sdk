
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:opay_flutter_sdk/opay_flutter_sdk.dart';
import 'package:opay_flutter_sdk/src/model/web_js_response.dart';
import 'package:opay_flutter_sdk/src/view/opay_web_view.dart';

// ignore: must_be_immutable
class WebViewPage extends StatelessWidget{

  String webUrl;
  bool isLocalUrl;
  Function(WebJsResponse?)? backIconFunc;
  WebViewPage({Key? key, this.webUrl="",this.isLocalUrl=false,this.backIconFunc}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: MaterialApp(
        title: 'OPay webView',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: OPayWebView(webUrl: webUrl,isLocalUrl:isLocalUrl,
            backIconFunc: (WebJsResponse? result) {
              if(backIconFunc!=null){
                backIconFunc!.call(result);
              } else {
                Navigator.pop(context,result);
              }
            }
        ),
      ),
      onWillPop: () async{
        // WebJsResponse webJsResponse = WebJsResponse(
        //   "KEYCODE_BACK",
        //   PayResultStatus.pending,
        //   "",
        //   "",
        //   "",
        //   ""
        // );
        return false;
      },
    );
  }
}
