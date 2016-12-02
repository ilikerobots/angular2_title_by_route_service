// Copyright (c) 2016, Mike Hoolehan. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

@TestOn("browser || content-shell")

import 'dart:async';
import 'package:angular2_title_by_route_service/angular2_title_by_route_service.dart';
import 'package:test/test.dart';
import 'package:angular2/angular2.dart';
import 'package:angular2/router.dart';
import 'package:angular2/platform/browser.dart';
import 'package:angular2/platform/common_dom.dart';
import 'package:angular2/reflection.dart';
import 'package:mockito/mockito.dart';

final List<Map<String, dynamic>> routeFixtures = [
  {"url": "/", "name": "Root", "data" : {"data":"bab"}, "params" : {"param": "bip"}},
  {"url": "/pageA", "name": "Page Alpha", "data" : {"data":"bab"}, "params" : {"param": "bip"}},
  {"url": "/pageB", "name": "Page Bravo", "data" : {}, "params" : {}},
  {"url": "/pageC", "name": "Page Charlie", "data" : null, "params" : null}
];

class MockRouter extends Mock implements Router {
  EventEmitter<dynamic> subject = new EventEmitter<dynamic>(false);

  @override
  Object subscribe(void onNext(dynamic value), [void onError(dynamic value)]) {
    return subject.listen(onNext, onError: onError);
  }
}

class MockInstruction extends Mock implements Instruction {}

class MockComponentInstruction extends Mock implements ComponentInstruction {}

class MockBrowserDomAdapter extends Mock implements BrowserDomAdapter {
  StreamController<String> titleChangeController = new StreamController<String>();

  void setTitle(String s) {
    titleChangeController.add(s);
  }

  void reset() {
    if (titleChangeController != null) {
      titleChangeController.close();
    }

    titleChangeController = new StreamController<String>();
  }

}


MockBrowserDomAdapter mockDomApadater = new MockBrowserDomAdapter();

void main() {
  allowRuntimeReflection();
  setRootDomAdapter(mockDomApadater);


  group('Basic tests', () {
    Injector inj;
    TitleByRouteService titleService;
    MockRouter router;

    Future<Null> _emitRouteEvents(Iterable<dynamic> urls) async {
      urls.forEach((String u) => router.subject.emit(u.toString()));
      return new Future<Null>.delayed(const Duration(milliseconds: 0));
    }

    Future<Null> _listenExpectRouteEvents(List<dynamic> exp) async {
      int routeNum = 0;
      Stream<String> stream = mockDomApadater.titleChangeController.stream;
      stream.listen(expectAsync1((String result) {
        expect(result, exp[routeNum++].toString());
      }, count: exp.length, max: exp.length));
    }

    setUp(() {
      inj = ReflectiveInjector.resolveAndCreate([
        provide(TitleByRouteService, useClass: TitleByRouteService),
        provide(Router, useClass: MockRouter)
      ]);
      titleService = inj.get(TitleByRouteService);
      router = inj.get(Router);
      mockDomApadater.reset();

      routeFixtures.forEach((r) {
        MockInstruction simpleInst = new MockInstruction();
        MockComponentInstruction simpleCompInst = new MockComponentInstruction();

        when(router.recognize(r['url'])).thenReturn(simpleInst);
        when(simpleInst.component).thenReturn(simpleCompInst);

        when(simpleCompInst.routeName).thenReturn(r['name']);
        when(simpleCompInst.routeData).thenReturn(new RouteData(r['data']));
        when(simpleCompInst.params).thenReturn(r['params']);
      });
    });

    test('Test Default Name', () async {
      _listenExpectRouteEvents(routeFixtures.map((Map<String, dynamic> rt) => rt['name']).toList());
      await _emitRouteEvents(routeFixtures.map((Map<String, dynamic> r) => r['url']));
    });

    test('Test Custom Name', () async {
      _listenExpectRouteEvents(
          routeFixtures.map((Map<String, dynamic> rt) => "${rt['name']} : ${rt['data']} : ${rt['params']}").toList());

      titleService.nameStrategy = (String n, RouteData r, Map<String, String> p) => "$n : ${r.data} : $p";
      await _emitRouteEvents(routeFixtures.map((Map<String, dynamic> r) => r['url']));
    });


    test('Test Custom Name Change', () async {
      List<String> exp = [];
      exp.addAll(routeFixtures.map((Map<String, dynamic> rt) => "${rt['name']} : ${rt['data']} : ${rt['params']}"));
      exp.addAll(routeFixtures.map((Map<String, dynamic> rt) => "T: ${rt['data']} : ${rt['params']}: ${rt['name']}"));

      _listenExpectRouteEvents(exp);

      titleService.nameStrategy = (String n, RouteData r, Map<String, String> p) => "$n : ${r.data} : $p";
      await _emitRouteEvents(routeFixtures.map((Map<String, dynamic> r) => r['url']));
      titleService.nameStrategy = (String n, RouteData r, Map<String, String> p) => "T: ${r.data} : $p: $n";
      await _emitRouteEvents(routeFixtures.map((Map<String, dynamic> r) => r['url']));
    });

    test('Test Custom Name Change2', () async {
      List<String> exp = [];
      exp.addAll(
          routeFixtures.map((Map<String, dynamic> rt) => "AAA: ${rt['name']} : ${rt['data']} : ${rt['params']}"));
      exp.addAll(routeFixtures.map((Map<String, dynamic> rt) => "BBB: ${rt['data']} : ${rt['params']}: ${rt['name']}"));

      _listenExpectRouteEvents(exp);

      titleService.nameStrategy = (String n, RouteData r, Map<String, String> p) => "AAA: $n : ${r.data} : $p";
      await _emitRouteEvents(routeFixtures.map((Map<String, dynamic> r) => r['url']));
      titleService.nameStrategy = (String n, RouteData r, Map<String, String> p) => "BBB: ${r.data} : $p: $n";
      await _emitRouteEvents(routeFixtures.map((Map<String, dynamic> r) => r['url']));
    });
  });
}
  

