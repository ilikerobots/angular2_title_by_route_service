// Copyright (c) 2016, Mike Hoolehan. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'package:angular2/core.dart';
import 'package:angular2/platform/browser.dart';
import 'package:angular2/router.dart';

/// A strategy 
typedef String TitleNamingFunction(String routeName, RouteData data, Map<String,String> params);

/// Sets document titles from route events
@Injectable()
class TitleByRouteService {
  
  /// Naming strategy for this service
  TitleNamingFunction nameStrategy;

  Router _router;

  TitleByRouteService(this._router) {
    nameStrategy = _defaultNameStrategy;
    _router.subscribe(_setTitleFromRoute);
  }

  Future<Null> _setTitleFromRoute(String url) async {
    //identify component instruction from routed url
    ComponentInstruction cInst = (await _router.recognize(url))?.component;
    if (cInst != null) {
      new Title().setTitle(nameStrategy(cInst.routeName, cInst.routeData, cInst.params));
    }
  }

  String _defaultNameStrategy(String routeName, RouteData data, Map<String,String> params) => routeName;

}
