import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../config/app_config.dart';
import '../../services/avatar_cache_service.dart';

/// Виджет для отображения аватара пользователя
///
/// Поддерживает:
/// - Загрузку растрового фото аватара по URL (.jpg, .png, .webp)
/// - Градиентный аватар с парсингом бэкенд градиента (если нет фото или SVG)
/// - Инициалы пользователя как fallback
class AvatarWidget extends StatelessWidget {
  /// URL аватара
  final String? avatar;

  /// Градиент аватара (если нет изображения)
  final String? avatarGradient;

  /// Есть ли у пользователя аватар
  final bool hasAvatar;

  /// Имя пользователя для инициалов
  final String username;

  /// Размер аватара
  final double size;

  /// Радиус скругления (по умолчанию size / 2 - круглый)
  final double? borderRadius;

  /// Иконка для отображения (например, звезда для избранного)
  final FaIconData? icon;

  const AvatarWidget({
    super.key,
    this.avatar,
    this.avatarGradient,
    this.hasAvatar = false,
    required this.username,
    this.size = 48,
    this.borderRadius,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? size / 2;

    // Преобразуем URL аватара с использованием AppConfig.formatImageUrl
    final String? formattedUrl = AppConfig.formatImageUrl(avatar);

    // ВАЖНО: Проверяем, является ли аватар реальной растровой фоткой (.png, .jpg, .jpeg, .webp)
    final bool isSvg = formattedUrl != null &&
        (formattedUrl.toLowerCase().endsWith('.svg') ||
            formattedUrl.toLowerCase().contains('.svg?') ||
            formattedUrl.toLowerCase().contains('/svg/') ||
            formattedUrl.toLowerCase().contains('data:image/svg'));

    final bool isPhoto = formattedUrl != null &&
        !isSvg &&
        !formattedUrl.startsWith('data:') &&
        (formattedUrl.startsWith('http://') ||
            formattedUrl.startsWith('https://'));

    // Если нет реальной растровой фотки — показываем градиентный аватар с инициалами
    final bool showInitialsWithGradient = !isPhoto;

    // Используем переданный градиент с БЭКА (avatarGradient) или дефолтный детерминированный градиент
    final String defaultGrad;
    if (username.isEmpty) {
      defaultGrad = '333333,111111';
    } else {
      final code =
          username.codeUnits.fold<int>(0, (prev, element) => prev + element);
      final gradients = [
        '3A3A3A,121212', // Dark Charcoal
        '555555,222222', // Steel Grey
        '777777,333333', // Medium Slate
        '999999,444444', // Silver Onyx
        '4A4A4A,1C1C1C', // Matte Carbon
      ];
      defaultGrad = gradients[code % gradients.length];
    }

    final effectiveGradient = avatarGradient ?? defaultGrad;

    Widget fallback() => Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            gradient: _parseGradient(effectiveGradient),
          ),
          alignment: Alignment.center,
          child: (icon != null)
              ? FaIcon(icon, color: Colors.white, size: size * 0.5)
              : Text(
                  _getInitials(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: size * 0.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        );

    if (showInitialsWithGradient) {
      return SizedBox(width: size, height: size, child: fallback());
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        color: Colors.grey.withValues(alpha: 0.3),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: ValueListenableBuilder<int>(
        valueListenable: AvatarCacheService.instance.revision,
        builder: (context, revision, _) => FutureBuilder<File>(
          future: AvatarCacheService.instance.fileFor(formattedUrl),
          builder: (context, snapshot) {
            final file = snapshot.data;
            if (file == null) return fallback();
            return Image.file(
              file,
              key: ValueKey('${formattedUrl}_$revision'),
              width: size,
              height: size,
              fit: BoxFit.cover,
              gaplessPlayback: true,
              errorBuilder: (_, __, ___) => fallback(),
            );
          },
        ),
      ),
    );
  }

  /// Получить инициалы из имени пользователя
  String _getInitials() {
    if (username.isEmpty) return '?';

    // Если username начинается с @, убираем его
    final name = username.startsWith('@') ? username.substring(1) : username;

    if (name.isEmpty) return '?';

    // Берём первую букву
    return name[0].toUpperCase();
  }

  /// Парсит градиент из строки (поддерживает "FF1234,FF5678", "#123456,#654321", "linear-gradient(...)")
  LinearGradient? _parseGradient(String? gradient) {
    if (gradient == null || gradient.isEmpty) return null;

    try {
      String cleanGradient = gradient;
      // Если передана CSS функция linear-gradient(...)
      if (cleanGradient.contains('linear-gradient')) {
        final match =
            RegExp(r'#(?:[0-9a-fA-F]{3,8})').allMatches(cleanGradient);
        final hexes = match.map((m) => m.group(0)!.substring(1)).toList();
        if (hexes.isNotEmpty) {
          cleanGradient = hexes.join(',');
        }
      }

      final parts = cleanGradient.split(RegExp(r'[,|]'));
      final List<Color> colors = [];

      for (var part in parts) {
        var colorStr = part.trim();
        if (colorStr.startsWith('#')) {
          colorStr = colorStr.substring(1);
        }
        if (colorStr.length == 3) {
          colorStr = colorStr.split('').map((c) => '$c$c').join();
        }
        if (colorStr.length == 6) {
          colorStr = 'FF$colorStr';
        }
        if (colorStr.length == 8) {
          final colorVal = int.tryParse(colorStr, radix: 16);
          if (colorVal != null) {
            colors.add(Color(colorVal));
          }
        }
      }

      if (colors.isEmpty) return null;
      if (colors.length == 1) {
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors[0], colors[0]],
        );
      }

      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: colors,
      );
    } catch (e) {
      return null;
    }
  }
}
