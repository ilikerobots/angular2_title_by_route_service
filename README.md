# angular2_title_by_route_service
[![Pub](https://img.shields.io/pub/v/angular2_title_by_route_service.svg?maxAge=2592000?style=flat-square)](https://pub.dartlang.org/packages/angular2_title_by_route_service)
[![Travis](https://img.shields.io/travis/ilikerobots/angular2_title_by_route_service.svg?maxAge=2592000?style=flat-square)](https://github.com/ilikerobots/angular2_title_by_route_service)


An Angular2 service for setting document titles on Route changes.

## Usage

Provide  ```TitleByRouteService```, e.g. 
 
```dart
    providers: const [
      ROUTER_PROVIDERS,
      TitleByRouteService,
    ] 
``` 
and inject the same into your component, e.g.

```dart
  AppComponent(TitleByRouteService _titleSet) { }

```

By default, `TitleRouteService` will update the document title to the route name on route changes.  A custom name strategy can be utilized instead by setting the `nameStrategy` field.  Example:

```
  AppComponent(TitleByRouteService _titleSet) {
    _titleSet.nameStrategy = _setTitle;
  }

  String _setTitle(String name, RouteData routeData, Map<String,String> params) {
    StringBuffer sb = new StringBuffer();
    sb.write("Title Set Demo | ");

    if (routeData.data.containsKey('title')) { // if title is in data, use it
      sb.write(routeData.data['title']);
    } else { //otherwise use route name
      sb.write(name);
    }

    if (params.containsKey('id')) { // if detail id in params, append it
      sb.write(": ${params['id']}");
    }
    return sb.toString();
  }
```


## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/ilikerobots/angular2_title_by_route_service/issues
