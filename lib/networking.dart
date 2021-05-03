import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';

class NetworkHelper {
  final String url;

  NetworkHelper({@required this.url});

  Future<List> getData() async {
    List data = [];
    try {
      http.Response response = await http.get(url);
//TODO handel SocketException: Failed host lookup: no enternet(pop up an exit)
      print(response.statusCode);
      //true,true ,data
      data.add(true);
      if (response.statusCode == 200) {
        data.add(true);
      } else {
        //true , false ,['error']
        data.add(false);
        print(response.statusCode);
        print('url : $url');
      }
      data.add(jsonDecode(response.body));
    } catch (e) {
      //false ,false,errorMsg
      data.add(false);
      data.add(false);
      data.add('Failed host lookup\n(check your enternet connection)');
    }
    return data;
  }
}
