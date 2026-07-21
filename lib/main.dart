
import 'package:flutter/material.dart';

import 'data/modifiednetwork/ApiConfig.dart';
import 'data/modifiednetwork/ApiService.dart';
import 'screen/app.dart';


void main () async {


  // ApiConfig.baseUrl = 'https://uat.lead2money.com/';
  //ApiConfig.baseUrl = 'https://apidev.lead2money.com/';
  ApiService().init(baseUrl: ApiConfig.baseUrl);

  WidgetsFlutterBinding.ensureInitialized();
  await runReadPDFApp();

}