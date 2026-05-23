import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/map_route_model.dart';

class MapRouteInfoSheet extends StatelessWidget {
  const MapRouteInfoSheet({
    super.key,
    required this.route,
    required this.onClose,
  });

  final MapRouteModel route;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: true,
      child: Container(
        margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
        decoration: BoxDecoration(
          color: AppColors.softCardColor(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x24000000),
              blurRadius: 12,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  'Walking',
                  style: TextStyle(
                    color: AppColors.primaryGreen,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Montserrat',
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: onClose,
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFF838383),
                        width: 2.5,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      color: Color(0xFF6F6F6F),
                      size: 28,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _transportItem(Icons.directions_car, route.carLabel),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _transportItem(Icons.directions_walk, route.walkLabel),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _transportItem(Icons.pedal_bike, route.bikeLabel),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _transportItem(IconData icon, String value) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF767676), size: 34),
          const SizedBox(width: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Color(0xFF707070),
              fontSize: 22,
              fontWeight: FontWeight.w500,
              fontFamily: 'Montserrat',
            ),
          ),
        ],
      ),
    );
  }
}
