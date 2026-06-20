import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:kickpro/core/l10n/app_translations.dart';
import 'package:kickpro/core/theme/app_colors.dart';
import 'package:latlong2/latlong.dart';

class AdminStadiumMapPicker extends StatefulWidget {
  const AdminStadiumMapPicker({
    super.key,
    this.latitude,
    this.longitude,
    required this.onLocationPicked,
  });

  final double? latitude;
  final double? longitude;
  final void Function(double lat, double lng) onLocationPicked;

  @override
  State<AdminStadiumMapPicker> createState() => _AdminStadiumMapPickerState();
}

class _AdminStadiumMapPickerState extends State<AdminStadiumMapPicker> {
  static const _defaultCenter = LatLng(33.5731, -7.5898);

  late LatLng _pin;

  @override
  void initState() {
    super.initState();
    _pin = LatLng(widget.latitude ?? _defaultCenter.latitude, widget.longitude ?? _defaultCenter.longitude);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.tr.mapLocation, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Text(context.tr.tapMapToPin, style: const TextStyle(color: AppColors.textHint, fontSize: 12)),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 200,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: _pin,
                initialZoom: 12,
                onTap: (_, point) {
                  setState(() => _pin = point);
                  widget.onLocationPicked(point.latitude, point.longitude);
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.kickpro.app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _pin,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.location_pin, color: AppColors.primary, size: 36),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Lat ${_pin.latitude.toStringAsFixed(5)}, Lng ${_pin.longitude.toStringAsFixed(5)}',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
      ],
    );
  }
}
