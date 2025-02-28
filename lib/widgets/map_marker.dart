import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MapMarker extends StatefulWidget {
final Color color;
final IconData? icon;
final String? label;
final double size;
final VoidCallback? onTap;
final bool isCurrentLocation;
final bool showPulse;

const MapMarker({
    Key? key,
    this.color = Colors.red,
    this.icon,
    this.label,
    this.size = 40.0,
    this.onTap,
    this.isCurrentLocation = false,
    this.showPulse = false,
}) : super(key: key);

@override
State<MapMarker> createState() => _MapMarkerState();
}

class _MapMarkerState extends State<MapMarker> with SingleTickerProviderStateMixin {
late AnimationController _controller;
late Animation<double> _scaleAnimation;
late Animation<double> _bounceAnimation;

@override
void initState() {
    super.initState();
    _controller = AnimationController(
    duration: const Duration(milliseconds: 800),
    vsync: this,
    );
    
    // Scale from 0 to 1
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
    CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    ),
    );
    
    // Bounce effect
    _bounceAnimation = TweenSequence<double>([
    TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.2), weight: 1),
    TweenSequenceItem(tween: Tween<double>(begin: 1.2, end: 0.9), weight: 1),
    TweenSequenceItem(tween: Tween<double>(begin: 0.9, end: 1.0), weight: 1),
    ]).animate(
    CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
    ),
    );
    
    _controller.forward();
}

@override
void dispose() {
    _controller.dispose();
    super.dispose();
}

@override
Widget build(BuildContext context) {
    // Start pulsing animation if this is the current location and should pulse
    if (widget.isCurrentLocation && widget.showPulse) {
        _controller.repeat();
    }
    
    return AnimatedBuilder(
    animation: _controller,
    builder: (context, child) {
        return Transform.scale(
        scale: _scaleAnimation.value * _bounceAnimation.value,
        child: GestureDetector(
            onTap: widget.onTap,
            child: SingleChildScrollView(
                child: Column(
                mainAxisSize: MainAxisSize.min,
            children: [
                // Map Pin
                Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                    color: widget.color,
                    shape: BoxShape.circle,
                    boxShadow: [
                    BoxShadow(
                        color: widget.color.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 2,
                        offset: const Offset(0, 2),
                    ),
                    ],
                ),
                child: Center(
                    child: widget.icon != null
                        ? Icon(
                            widget.icon,
                            color: Colors.white,
                            size: widget.size * 0.6,
                        )
                        : Container(),
                ),
                ),
                
                // Pointer under pin
                Transform.translate(
                offset: const Offset(0, -5),
                child: Container(
                    width: widget.size * 0.3,
                    height: widget.size * 0.3,
                    decoration: BoxDecoration(
                    color: widget.color,
                    borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                    ),
                    boxShadow: [
                        BoxShadow(
                        color: widget.color.withOpacity(0.3),
                        blurRadius: 2,
                        spreadRadius: 1,
                        offset: const Offset(0, 1),
                        ),
                    ],
                    ),
                    transform: Matrix4.rotationZ(0.785), // 45 degrees in radians
                ),
                ),
                
                // Optional label
                if (widget.label != null)
                Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                        BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        spreadRadius: 1,
                        ),
                    ],
                    ),
                    child: Text(
                    widget.label!,
                    style: TextStyle(
                        color: widget.color.withOpacity(0.8),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                    ),
                    ),
                ),
            ],
            ),
            ),
        ),
        );
    },
    );
}
}

