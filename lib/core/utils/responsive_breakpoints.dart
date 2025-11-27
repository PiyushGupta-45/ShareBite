import 'package:flutter/material.dart';

const double kTabletBreakpoint = 600;
const double kDesktopBreakpoint = 1024;

bool isTablet(BuildContext context) =>
    MediaQuery.sizeOf(context).width >= kTabletBreakpoint &&
    MediaQuery.sizeOf(context).width < kDesktopBreakpoint;

bool isDesktop(BuildContext context) =>
    MediaQuery.sizeOf(context).width >= kDesktopBreakpoint;

