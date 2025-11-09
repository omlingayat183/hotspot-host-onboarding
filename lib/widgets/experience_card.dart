// lib/features/experience/widgets/experience_card.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../data/models/experience.dart';

class ExperienceCard extends StatelessWidget {
  final Experience experience;
  final bool selected;
  final VoidCallback onTap;

  const ExperienceCard({
    super.key,
    required this.experience,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final img = CachedNetworkImageProvider(experience.imageUrl);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            if (selected)
              BoxShadow(
                color: Colors.black.withOpacity(.2),
                blurRadius: 10, offset: const Offset(0, 4),
              ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            fit: StackFit.expand,
            children: [
              ColorFiltered(
                colorFilter: selected
                    ? const ColorFilter.mode(Colors.transparent, BlendMode.dst)
                    : const ColorFilter.matrix(<double>[
                        0.2126, 0.7152, 0.0722, 0, 0,
                        0.2126, 0.7152, 0.0722, 0, 0,
                        0.2126, 0.7152, 0.0722, 0, 0,
                        0,      0,      0,      1, 0,
                      ]),
                child: Image(
                  image: img,
                  fit: BoxFit.cover,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.center,
                    colors: [Colors.black54, Colors.transparent],
                  ),
                ),
              ),
              Positioned(
                left: 10, right: 10, bottom: 10,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        experience.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    AnimatedScale(
                      duration: const Duration(milliseconds: 180),
                      scale: selected ? 1 : 0.9,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: selected ? Colors.green : Colors.white70,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          selected ? Icons.check : Icons.add,
                          size: 16,
                          color: selected ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
