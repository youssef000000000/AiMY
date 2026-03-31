import 'package:flutter/material.dart';

/// AiMY Phone — Design tokens for Figma parity.
/// Use these constants when building screens to match the design spec.
/// Base frame: 390 × 844 (iPhone 14).
class AimyPhoneDesignTokens {
  AimyPhoneDesignTokens._();

  // ─────────────────────────────────────────────────────────────────────────
  // Device & Layout
  // ─────────────────────────────────────────────────────────────────────────

  /// Base design width (iPhone 14).
  static const double designWidth = 390;

  /// Base design height (iPhone 14).
  static const double designHeight = 844;

  /// Horizontal screen padding.
  static const double screenPaddingH = 20;

  /// Vertical screen padding.
  static const double screenPaddingV = 24;

  /// Safe area bottom (home indicator).
  static const double safeAreaBottom = 34;

  /// Safe area top (notch / status).
  static const double safeAreaTop = 59;

  // ─────────────────────────────────────────────────────────────────────────
  // Spacing
  // ─────────────────────────────────────────────────────────────────────────

  static const double space4 = 4;
  static const double space8 = 8;
  static const double space12 = 12;
  static const double space16 = 16;
  static const double space20 = 20;
  static const double space24 = 24;
  static const double space32 = 32;
  static const double space48 = 48;
  static const double space64 = 64;

  // ─────────────────────────────────────────────────────────────────────────
  // Border Radius
  // ─────────────────────────────────────────────────────────────────────────

  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 24;

  // ─────────────────────────────────────────────────────────────────────────
  // Incoming Call Screen
  // ─────────────────────────────────────────────────────────────────────────

  static const double incomingCallAvatarSize = 120;
  static const double incomingCallAvatarTop = 180;
  static const double incomingCallContextCardWidth = 350;
  static const double incomingCallContextCardHeight = 140;
  static const double incomingCallContextCardTop = 400;
  static const double incomingCallActionButtonSize = 72;
  static const double incomingCallActionButtonSpacing = 48;
  static const double incomingCallActionIconSize = 32;
  static const double incomingCallActionsBottomPadding = 24;

  // ─────────────────────────────────────────────────────────────────────────
  // Active Call Screen
  // ─────────────────────────────────────────────────────────────────────────

  static const double activeCallTopBarHeight = 56;
  static const double activeCallTranscriptTop = 140;
  static const double activeCallTranscriptHeight = 380;
  static const double activeCallControlButtonSize = 64;
  static const double activeCallControlIconSize = 28;
  static const double activeCallControlSpacing = 40;
  static const double activeCallNudgeCardWidth = 140;
  static const double activeCallNudgeCardHeight = 80;
  static const double activeCallHandoffButtonHeight = 44;

  // ─────────────────────────────────────────────────────────────────────────
  // Post-Call Screen
  // ─────────────────────────────────────────────────────────────────────────

  static const double postCallHeaderHeight = 80;
  static const double postCallSummaryCardHeight = 200;
  static const double postCallInsightCardHeight = 72;
  static const double postCallActionCardHeight = 56;
  static const double postCallSaveButtonHeight = 52;

  // ─────────────────────────────────────────────────────────────────────────
  // Profile (Tap-to-Call)
  // ─────────────────────────────────────────────────────────────────────────

  static const double profileAvatarSize = 64;
  static const double profileCallButtonSize = 56;
  static const double profileCallButtonIconSize = 24;
  static const double profileContactSectionHeight = 88;

  // ─────────────────────────────────────────────────────────────────────────
  // Mini-Player
  // ─────────────────────────────────────────────────────────────────────────

  static const double miniPlayerHeight = 72;
  static const double miniPlayerAvatarSize = 48;
  static const double miniPlayerTotalHeight = 106; // 72 + safe area

  // ─────────────────────────────────────────────────────────────────────────
  // Touch Targets (min 44pt)
  // ─────────────────────────────────────────────────────────────────────────

  static const double minTouchTarget = 44;

  // ─────────────────────────────────────────────────────────────────────────
  // Typography (font sizes)
  // ─────────────────────────────────────────────────────────────────────────

  static const double textDisplay = 28;
  static const double textH1 = 24;
  static const double textH2 = 20;
  static const double textH3 = 18;
  static const double textBody = 16;
  static const double textBodySm = 14;
  static const double textCaption = 12;
  static const double textLabel = 14;

  // ─────────────────────────────────────────────────────────────────────────
  // Semantic Colors (extend AppColors for Phone-specific)
  // ─────────────────────────────────────────────────────────────────────────

  static const Color answerGreen = Color(0xFF3FB950);
  static const Color declineRed = Color(0xFFF85149);
  static const Color remindAmber = Color(0xFFD29922);
}
