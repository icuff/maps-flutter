import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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

  @override
  void initState() {
    super.initState();
    setMarkers();
  }

  void setMarkers() {
    MarkerId roraimaId = MarkerId('roraima');
    final Marker origem = Marker(
      markerId: roraimaId,
      position: LatLng(2.8235, -60.6758),
      infoWindow: InfoWindow(title: 'Roraima', snippet: '*'),
    );
    markers[roraimaId] = origem;

    MarkerId portoAlegreId = MarkerId('porto_alegre');
    final Marker destino = Marker(
      markerId: portoAlegreId,
      position: LatLng(-30.0277, -51.2287),
      infoWindow: InfoWindow(title: 'Porto Alegre', snippet: '*'),
    );
    markers[portoAlegreId] = destino;
  }

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(-14, -55),
    zoom: 4.5,
  );

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
      )
    );
  }
}
