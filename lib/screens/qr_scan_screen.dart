import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../services/crypto/crypto_service.dart';
import '../providers/auth_provider.dart';

/// Экран сканирования и авторизации устройств по QR-коду
class QrScanScreen extends StatefulWidget {
  const QrScanScreen({super.key});

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen>
    with WidgetsBindingObserver {
  late final MobileScannerController _scannerController;
  bool _isProcessing = false;
  bool _cameraStarted = false;
  bool _cameraStarting = false;
  bool _cameraSuspended = false;
  bool _cameraStartAllowed = false;
  bool _cameraStartScheduled = false;
  Future<void>? _cameraStop;
  Object? _cameraError;
  Animation<double>? _routeAnimation;

  double _zoomScale = 0.0;
  double _baseZoomScale = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Виджет сканера монтируем заранее, но нативную камеру запускаем
    // отдельно. Иначе MobileScanner запускает CameraX/ML Kit во время
    // первой отрисовки экрана и роняет кадры анимации.
    _scannerController = MobileScannerController(
      autoStart: false,
      detectionSpeed: DetectionSpeed.normal,
      detectionTimeoutMs: 350,
      facing: CameraFacing.back,
      formats: const [BarcodeFormat.qrCode],
      torchEnabled: false,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_cameraStartScheduled) return;
    _cameraStartScheduled = true;

    _routeAnimation = ModalRoute.of(context)?.animation;
    if (_routeAnimation case final animation?) {
      if (animation.isCompleted) {
        _startCameraAfterFrame();
      } else {
        animation.addStatusListener(_onRouteAnimationStatus);
      }
    } else {
      _startCameraAfterFrame();
    }
  }

  void _onRouteAnimationStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    _routeAnimation?.removeStatusListener(_onRouteAnimationStatus);
    _startCameraAfterFrame();
  }

  void _startCameraAfterFrame() {
    // Даём Flutter показать хотя бы один готовый кадр экрана до тяжёлой
    // нативной инициализации CameraX/AVFoundation.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _cameraStartAllowed = true;
        unawaited(_startCamera());
      }
    });
  }

  Future<void> _startCamera() async {
    if (!_cameraStartAllowed || _cameraStarted || _cameraStarting) return;
    _cameraStarting = true;
    if (_cameraError != null && mounted) {
      setState(() => _cameraError = null);
    }
    try {
      await _scannerController.start();
      if (_cameraSuspended) {
        await _scannerController.stop();
        return;
      }
      if (!_scannerController.value.isRunning) {
        throw _scannerController.value.error ??
            StateError('Камеру не удалось запустить');
      }
      if (mounted) setState(() => _cameraStarted = true);
    } catch (error) {
      if (mounted) setState(() => _cameraError = error);
    } finally {
      _cameraStarting = false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _cameraSuspended = false;
      final pendingStop = _cameraStop;
      if (pendingStop == null) {
        unawaited(_startCamera());
      } else {
        unawaited(
          pendingStop.whenComplete(() {
            _cameraStop = null;
            if (mounted && !_cameraSuspended) return _startCamera();
          }),
        );
      }
    } else if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _cameraSuspended = true;
      _cameraStarted = false;
      _cameraStop ??= _scannerController.stop();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _routeAnimation?.removeStatusListener(_onRouteAnimationStatus);
    unawaited(_scannerController.dispose());
    super.dispose();
  }

  Future<void> _handleQrCode(String code) async {
    if (_isProcessing || code.trim().isEmpty) return;
    setState(() => _isProcessing = true);

    try {
      String? token;
      String? webPub;

      try {
        final decoded = jsonDecode(code.trim());
        if (decoded is Map<String, dynamic>) {
          token = decoded['token']?.toString() ?? decoded['t']?.toString();
          webPub = decoded['web_pub']?.toString() ?? decoded['k']?.toString();
        }
      } catch (_) {
        final uri = Uri.tryParse(code.trim());
        if (uri != null && uri.queryParameters.containsKey('token')) {
          token = uri.queryParameters['token'];
          webPub = uri.queryParameters['web_pub'] ?? uri.queryParameters['k'];
        } else {
          token = code.trim();
        }
      }

      if (token == null || token.isEmpty) {
        throw Exception('Неверный формат токена авторизации');
      }

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final cryptoService = Provider.of<CryptoService?>(context, listen: false);

      Map<String, dynamic>? transferPayload;
      if (webPub != null && webPub.isNotEmpty && cryptoService != null) {
        transferPayload = await cryptoService.createQrTransferPayload(webPub);
      }

      final authService = authProvider.authService;
      final success = await authService.approveQrLogin(
        token: token,
        transferPayload: transferPayload,
      );

      if (!mounted) return;

      if (success) {
        await _showSuccessDialog();
        if (mounted) Navigator.of(context).pop(true);
      } else {
        throw Exception('Не удалось подтвердить авторизацию по QR-коду');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Ошибка: ${e.toString().replaceAll('Exception: ', '')}',
            style: const TextStyle(color: Colors.white, fontFamily: 'Inter'),
          ),
          backgroundColor: const Color(0xFF27272A),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _showSuccessDialog() async {
    final l10n = AppLocalizations.of(context);
    final titleText = l10n?.qrScanSuccessTitle ?? 'Устройство авторизовано';
    final descText = l10n?.qrScanSuccessDesc ??
        'Авторизация прошла успешно. Ключи сквозного шифрования (E2EE) переданы на новое устройство.';

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF18181B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF27272A)),
        ),
        title: Row(
          children: [
            const Icon(Icons.check_circle_outline_rounded,
                color: Colors.white, size: 26),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                titleText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ],
        ),
        content: Text(
          descText,
          style: const TextStyle(
            color: Color(0xFFA1A1AA),
            fontSize: 14,
            fontFamily: 'Inter',
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Готово',
              style:
                  TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Inter'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final titleText = l10n?.qrScanTitle ?? 'Авторизация устройства';
    final subtitleText = l10n?.qrScanSubtitle ??
        'Наведите камеру на QR-код на экране веб-версии или ПК-клиента Xaneo';
    final processingText =
        l10n?.qrScanProcessing ?? 'Авторизация устройства...';

    // Вычисляем красивое значение зума от 1.0x до 4.0x для индикатора
    final double displayZoom = 1.0 + (_zoomScale * 3.0);

    return Scaffold(
      backgroundColor: const Color(0xFF09090B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF09090B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          titleText,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
          ),
        ),
        actions: _cameraStarted
            ? [
                IconButton(
                  icon: ValueListenableBuilder(
                    valueListenable: _scannerController,
                    builder: (context, state, child) {
                      return Icon(
                        state.torchState == TorchState.on
                            ? Icons.flash_on_rounded
                            : Icons.flash_off_rounded,
                        color: Colors.white,
                      );
                    },
                  ),
                  onPressed: () => _scannerController.toggleTorch(),
                ),
                IconButton(
                  icon: const Icon(Icons.cameraswitch_rounded,
                      color: Colors.white),
                  onPressed: () => _scannerController.switchCamera(),
                ),
              ]
            : null,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Подзаголовок
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Text(
                subtitleText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFA1A1AA),
                  fontSize: 14,
                  fontFamily: 'Inter',
                ),
              ),
            ),

            // Область сканирования QR-кода с щипковым жестом зумирования (pinch-to-zoom)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onScaleStart: (_) {
                    _baseZoomScale = _zoomScale;
                  },
                  onScaleUpdate: (details) {
                    if (_cameraStarted && details.scale != 1.0) {
                      final double delta = (details.scale - 1.0) * 0.6;
                      final double newZoom =
                          (_baseZoomScale + delta).clamp(0.0, 1.0);
                      if ((newZoom - _zoomScale).abs() > 0.005) {
                        setState(() {
                          _zoomScale = newZoom;
                        });
                        _scannerController.setZoomScale(newZoom);
                      }
                    }
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Фон
                      Container(color: const Color(0xFF09090B)),

                      // Лёгкая Flutter-часть монтируется сразу, а камера
                      // стартует только после анимации роута.
                      MobileScanner(
                        controller: _scannerController,
                        onDetect: (capture) {
                          for (final barcode in capture.barcodes) {
                            final raw = barcode.rawValue;
                            if (raw != null && raw.isNotEmpty) {
                              _handleQrCode(raw);
                              break;
                            }
                          }
                        },
                      ),

                      if (!_cameraStarted && _cameraError == null)
                        const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),

                      if (_cameraError != null)
                        Center(
                          child: FilledButton.icon(
                            onPressed: _startCamera,
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('Повторить'),
                          ),
                        ),

                      // Рамка видоискателя
                      Container(
                        width: 270,
                        height: 270,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white, width: 2.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(140),
                              blurRadius: 24,
                              spreadRadius: 8,
                            ),
                          ],
                        ),
                      ),

                      // Индикатор зума над рамой
                      if (_cameraStarted)
                        Positioned(
                          bottom: 20,
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 200),
                            opacity: _zoomScale > 0.01 ? 1.0 : 0.6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black.withAlpha(180),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white24),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.zoom_in_rounded,
                                      color: Colors.white70, size: 16),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${displayZoom.toStringAsFixed(1)}x',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                      // Оверлей во время обработки QR
                      if (_isProcessing)
                        Container(
                          color: const Color(0xB3000000),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2),
                                const SizedBox(height: 16),
                                Text(
                                  processingText,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
