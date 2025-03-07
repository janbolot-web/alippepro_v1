// ignore_for_file: constant_identifier_names, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum AppIcons {
  elementPlus,
  archiveTick,
  add,
  trash,
  hh,
  folder,
  Vector,
  MoreVertical,
}

class AppIcon extends StatelessWidget {
  final AppIcons icon;
  final double? size;
  final Color? color;
  final bool changeableColorAccordingToTheme;

  const AppIcon(
    this.icon, {
    super.key,
    this.size = 24,
    this.color,
    this.changeableColorAccordingToTheme = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: SvgPicture.asset(
        'assets/svg/${icon.name}.svg',
        color: changeableColorAccordingToTheme
            ? Theme.of(context).colorScheme.onBackground
            : color,
        height: size,
        width: size,
      ),
    );
  }
}

class OvalIcon extends StatelessWidget {
  /// Icon type
  final AppIcons icon;

  /// Size of the oval
  final double? size;

  /// Icon color
  final Color? color;

  /// If true, the oval background will be visible
  final bool bgRectangleVisible;

  /// If true, the icon color will be changed according to the theme
  final bool changeableColorAccordingToTheme;

  /// Size of the oval background
  final double? bgOvalSize;

  final double? iconSize;

  const OvalIcon(
    this.icon, {
    super.key,
    this.size = 40,
    this.color,
    this.bgRectangleVisible = true,
    this.changeableColorAccordingToTheme = true,
    this.bgOvalSize,
    this.iconSize = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.transparent,
        border: Border.all(color: Theme.of(context).colorScheme.onBackground),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          bgRectangleVisible
              ? Positioned(
                  top: MediaQuery.of(context).size.width * 0.02,
                  right: MediaQuery.of(context).size.width * 0.02,
                  child: Container(
                    width: bgOvalSize ?? 14,
                    height: bgOvalSize ?? 14,
                    clipBehavior: Clip.none,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                  ),
                )
              : const SizedBox.shrink(),
          Center(
            child: AppIcon(
              icon,
              size: iconSize,
              color: changeableColorAccordingToTheme
                  ? Theme.of(context).colorScheme.onBackground
                  : color,
            ),
          ),
        ],
      ),
    );
  }
}
