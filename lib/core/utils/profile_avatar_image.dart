import 'package:aimy/domain/domain.dart';
import 'package:flutter/material.dart';

/// Local [ProfileEntity.avatarAssetPath] takes precedence over [ProfileEntity.avatarUrl].
ImageProvider<Object>? profileAvatarImageProvider(ProfileEntity p) {
  final asset = p.avatarAssetPath;
  if (asset != null && asset.isNotEmpty) {
    return AssetImage(asset);
  }
  final url = p.avatarUrl;
  if (url != null && url.isNotEmpty) {
    return NetworkImage(url);
  }
  return null;
}
