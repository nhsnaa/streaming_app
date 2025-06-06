import 'package:flutter/material.dart';

class HoverMovieCard extends StatefulWidget {
  final String imageUrl;
  final double height;
  final double width;
  final VoidCallback? onTap;

  const HoverMovieCard({
    super.key,
    required this.imageUrl,
    this.height = 180,
    this.width = 120,
    this.onTap,
  });

  @override
  State<HoverMovieCard> createState() => _HoverMovieCardState();
}

class _HoverMovieCardState extends State<HoverMovieCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          height: widget.height,
          width: widget.width,
          transform: _isHovered
              ? (Matrix4.identity()
                ..translate(0, -10, 0)
                ..scale(1.1))
              : Matrix4.identity(),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : [],
          ),
          clipBehavior: Clip.hardEdge,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                widget.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey,
                    child: const Icon(Icons.broken_image, size: 40),
                  );
                },
              ),
              // Dark gradient overlay on hover
              AnimatedOpacity(
                opacity: _isHovered ? 0.4 : 0.0,
                duration: const Duration(milliseconds: 250),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              // Play icon appears on hover
              if (_isHovered)
                const Center(
                  child: Icon(
                    Icons.play_circle_fill,
                    color: Colors.white70,
                    size: 48,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}








