import 'package:flutter/material.dart';
import 'package:streaming_app/widgets/movie_info_dialog.dart';

class HoverMovieCard extends StatefulWidget {
  final dynamic item; // Movie or TV show data
  final double height;
  final double width;
  final VoidCallback? onTap; // Optional tap callback

  const HoverMovieCard({
    super.key,
    required this.item,
    this.height = 180,
    this.width = 120,
    this.onTap,
  });

  @override
  State<HoverMovieCard> createState() => _HoverMovieCardState();
}

class _HoverMovieCardState extends State<HoverMovieCard> {
  bool _isHovered = false;

  // Tap handler: use custom callback if provided, else show default dialog
  void _handleTap() {
    if (widget.onTap != null) {
      widget.onTap!();
    } else {
      showDialog(
        context: context,
        builder: (context) => MovieInfoDialog(item: widget.item),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = 'https://image.tmdb.org/t/p/w500${widget.item['poster_path']}';

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: _handleTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          transformAlignment: Alignment.center,
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
              // ✅ Poster Image with loading indicator
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey,
                    child: const Icon(Icons.broken_image, size: 40),
                  );
                },
              ),

              // ✅ Hover overlay gradient
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

              // ✅ Center play icon on hover
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
