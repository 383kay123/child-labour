import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';

class GPSField extends StatefulWidget {
  final String question;

  const GPSField({super.key, required this.question});

  @override
  _GPSFieldState createState() => _GPSFieldState();
}

class _GPSFieldState extends State<GPSField> {
  double? latitude;
  double? longitude;
  double? altitude;

  void _recordGPS() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enable location services')),
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location permissions are denied')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location permissions are permanently denied')),
      );
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      latitude = position.latitude;
      longitude = position.longitude;
      altitude = position.altitude;
    });
  }

  void _clearGPS() {
    setState(() {
      latitude = null;
      longitude = null;
      altitude = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasData = latitude != null && longitude != null && altitude != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.question,
          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade400),
          ),
          child: hasData
              ? Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'N (Latitude)',
                            style: GoogleFonts.poppins(
                                fontSize: 12, color: Colors.grey.shade700),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            latitude!.toStringAsFixed(6),
                            style: GoogleFonts.poppins(
                                fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'W (Longitude)',
                            style: GoogleFonts.poppins(
                                fontSize: 12, color: Colors.grey.shade700),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            longitude!.toStringAsFixed(6),
                            style: GoogleFonts.poppins(
                                fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'A (Altitude)',
                            style: GoogleFonts.poppins(
                                fontSize: 12, color: Colors.grey.shade700),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${altitude!.toStringAsFixed(1)} m',
                            style: GoogleFonts.poppins(
                                fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: _clearGPS,
                      child: Icon(
                        Icons.close,
                        size: 20,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                )
              : GestureDetector(
                  onTap: _recordGPS,
                  child: Center(
                    child: Text(
                      'Tap to record GPS',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFF00754B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
