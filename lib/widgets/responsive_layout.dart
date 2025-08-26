import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= AppColors.desktopBreakpoint) {
          return desktop ?? tablet ?? mobile;
        } else if (constraints.maxWidth >= AppColors.tabletBreakpoint) {
          return tablet ?? mobile;
        } else {
          return mobile;
        }
      },
    );
  }
}

class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int mobileCrossAxisCount;
  final int? tabletCrossAxisCount;
  final int? desktopCrossAxisCount;
  final double mobileChildAspectRatio;
  final double? tabletChildAspectRatio;
  final double? desktopChildAspectRatio;
  final double mobileCrossAxisSpacing;
  final double? tabletCrossAxisSpacing;
  final double? desktopCrossAxisSpacing;
  final double mobileMainAxisSpacing;
  final double? tabletMainAxisSpacing;
  final double? desktopMainAxisSpacing;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.mobileCrossAxisCount = 2,
    this.tabletCrossAxisCount,
    this.desktopCrossAxisCount,
    this.mobileChildAspectRatio = 0.8,
    this.tabletChildAspectRatio,
    this.desktopChildAspectRatio,
    this.mobileCrossAxisSpacing = 16.0,
    this.tabletCrossAxisSpacing,
    this.desktopCrossAxisSpacing,
    this.mobileMainAxisSpacing = 20.0,
    this.tabletMainAxisSpacing,
    this.desktopMainAxisSpacing,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount;
        double childAspectRatio;
        double crossAxisSpacing;
        double mainAxisSpacing;

        if (constraints.maxWidth >= AppColors.desktopBreakpoint) {
          crossAxisCount = desktopCrossAxisCount ?? tabletCrossAxisCount ?? mobileCrossAxisCount;
          childAspectRatio = desktopChildAspectRatio ?? tabletChildAspectRatio ?? mobileChildAspectRatio;
          crossAxisSpacing = desktopCrossAxisSpacing ?? tabletCrossAxisSpacing ?? mobileCrossAxisSpacing;
          mainAxisSpacing = desktopMainAxisSpacing ?? tabletMainAxisSpacing ?? mobileMainAxisSpacing;
        } else if (constraints.maxWidth >= AppColors.tabletBreakpoint) {
          crossAxisCount = tabletCrossAxisCount ?? mobileCrossAxisCount;
          childAspectRatio = tabletChildAspectRatio ?? mobileChildAspectRatio;
          crossAxisSpacing = tabletCrossAxisSpacing ?? mobileCrossAxisSpacing;
          mainAxisSpacing = tabletMainAxisSpacing ?? mobileMainAxisSpacing;
        } else {
          crossAxisCount = mobileCrossAxisCount;
          childAspectRatio = mobileChildAspectRatio;
          crossAxisSpacing = mobileCrossAxisSpacing;
          mainAxisSpacing = mobileMainAxisSpacing;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: crossAxisSpacing,
            mainAxisSpacing: mainAxisSpacing,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: children.length,
          itemBuilder: (context, index) => children[index],
        );
      },
    );
  }
}

class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? mobilePadding;
  final EdgeInsets? tabletPadding;
  final EdgeInsets? desktopPadding;
  final double? mobileMaxWidth;
  final double? tabletMaxWidth;
  final double? desktopMaxWidth;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.mobilePadding,
    this.tabletPadding,
    this.desktopPadding,
    this.mobileMaxWidth,
    this.tabletMaxWidth,
    this.desktopMaxWidth,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        EdgeInsets padding;
        double? maxWidth;

        if (constraints.maxWidth >= AppColors.desktopBreakpoint) {
          padding = desktopPadding ?? tabletPadding ?? mobilePadding ?? EdgeInsets.zero;
          maxWidth = desktopMaxWidth ?? tabletMaxWidth ?? mobileMaxWidth;
        } else if (constraints.maxWidth >= AppColors.tabletBreakpoint) {
          padding = tabletPadding ?? mobilePadding ?? EdgeInsets.zero;
          maxWidth = tabletMaxWidth ?? mobileMaxWidth;
        } else {
          padding = mobilePadding ?? EdgeInsets.zero;
          maxWidth = mobileMaxWidth;
        }

        Widget container = Container(
          padding: padding,
          child: child,
        );

        if (maxWidth != null) {
          container = Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: container,
            ),
          );
        }

        return container;
      },
    );
  }
}
