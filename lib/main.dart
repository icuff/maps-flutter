import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/directions.dart' as Dir;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Google Maps Flutter'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Completer<GoogleMapController> _controller = Completer();
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  Map<PolylineId, Polyline> polylines = <PolylineId, Polyline>{};
  final directions = Dir.GoogleMapsDirections(apiKey: 'AIzaSyAxFARM9NrPcw8lyIsFrwPRrG1v5kdaKL4');

  @override
  void initState() {
    super.initState();
    setMarkers();
    getMapRoute();
  }

  void setMarkers() {
    MarkerId roraimaId = MarkerId('roraima');
    final Marker origin = Marker(
      markerId: roraimaId,
      position: LatLng(2.8235, -60.6758),
      infoWindow: InfoWindow(title: 'Roraima', snippet: '*'),
    );
    markers[roraimaId] = origin;

    MarkerId portoAlegreId = MarkerId('porto_alegre');
    final Marker destination = Marker(
      markerId: portoAlegreId,
      position: LatLng(-30.0277, -51.2287),
      infoWindow: InfoWindow(title: 'Porto Alegre', snippet: '*'),
    );
    markers[portoAlegreId] = destination;
  }

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(-14, -55),
    zoom: 4.5,
  );

  void getMapRoute() async {
    Dir.Location origin = Dir.Location(2.8235, -60.6758);
    Dir.Location destination = Dir.Location(-30.0277, -51.2287);
    Dir.DirectionsResponse res = await directions.directionsWithLocation(origin, destination);


    Polyline polyline;
    res.routes.asMap().forEach((index, route) {
      route.legs.asMap().forEach((index2, leg) {
        leg.steps.asMap().forEach((index3, step) {
          List<LatLng> points = [];

          double latStart = double.parse(step.startLocation.toString().split(',')[0]);
          double lgtStart = double.parse(step.startLocation.toString().split(',')[1]);
          LatLng latLngStart = LatLng(latStart, lgtStart);
          points.add(latLngStart);

//          double latEnd = double.parse(step.endLocation.toString().split(',')[0]);
//          double lgtEnd = double.parse(step.endLocation.toString().split(',')[1]);
//          LatLng latLngEnd = LatLng(latEnd, lgtEnd);
//          points.add(latLngEnd);

          PolylineId teste = PolylineId('teste' + index3.toString());
          polyline = Polyline(
            polylineId: teste,
            color: Colors.orange,
            width: 5,
            points: points
          );
          polylines[teste] = polyline;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: _kGooglePlex,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        markers: Set<Marker>.of(markers.values),
        polylines: Set<Polyline>.of(polylines.values),
      )
    );
  }
}
