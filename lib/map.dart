import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/directions.dart' as Dir;
import 'package:fluttertoast/fluttertoast.dart';

class MapApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MapPage(title: 'Google Maps Flutter'),
    );
  }
}

class MapPage extends StatefulWidget {
  MapPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Completer<GoogleMapController> _controller = Completer();
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  Map<PolylineId, Polyline> polylines = <PolylineId, Polyline>{};
  final directions = Dir.GoogleMapsDirections(apiKey: 'AIzaSyAxFARM9NrPcw8lyIsFrwPRrG1v5kdaKL4');

  @override
  void initState() {
    super.initState();
    DateTime begin = DateTime.now();
    setMarkers();
    getMapRoute();
    showToast(begin, DateTime.now());
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
    Map<PolylineId, Polyline> polylinesLocal = <PolylineId, Polyline>{};

    Polyline polyline;
    res.routes.asMap().forEach((index, route) {
      route.legs.asMap().forEach((index2, leg) {
        leg.steps.asMap().forEach((index3, step) {
          List<LatLng> points = [];

          double latStart = double.parse(step.startLocation.toString().split(',')[0]);
          double lgtStart = double.parse(step.startLocation.toString().split(',')[1]);
          LatLng latLngStart = LatLng(latStart, lgtStart);
          points.add(latLngStart);

          double latEnd = double.parse(step.endLocation.toString().split(',')[0]);
          double lgtEnd = double.parse(step.endLocation.toString().split(',')[1]);
          LatLng latLngEnd = LatLng(latEnd, lgtEnd);
          points.add(latLngEnd);

          PolylineId teste = PolylineId('teste' + index3.toString());
          polyline = Polyline(
            polylineId: teste,
            color: Colors.orange,
            width: 5,
            points: points
          );
          polylinesLocal[teste] = polyline;
        });
      });
    });

    setState(() {
      polylines = polylinesLocal;
    });
  }

  void showToast(DateTime begin, DateTime end) {
    String duration = end.difference(begin).inMilliseconds.toString();
    Fluttertoast.showToast(
        msg: 'Finished in ' + duration + 'ms',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        timeInSecForIos: 1,
        textColor: Colors.white,
        fontSize: 16.0
    );
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
