import 'package:flutter/widgets.dart';

import '../services/runtime_translations.dart';

/// Localization helper for phone entry and phone verification flows in mobile auth.
/// Fully supports built-in locales, canonical manifest fallback, and user custom language packs.
class PhoneAuthLocalizations {
  final String languageCode;

  const PhoneAuthLocalizations(this.languageCode);

  factory PhoneAuthLocalizations.of(BuildContext context) =>
      PhoneAuthLocalizations(Localizations.localeOf(context).languageCode);

  static const _values = <String, Map<String, String>>{
    'ru': {
      'voiceCallSubtitle': 'Вам поступит звонок на номер\n{phone}\nВведите код, который продиктует робот:',
      'phoneStepTitle': 'Номер телефона',
      'phoneStepRuSubtitle':
          'Для подтверждения потребуется совершить бесплатный звонок на 8-800',
      'phoneStepIntlSubtitle':
          'Для зарубежных номеров поступит проверочный звонок',
      'phoneConfirmation': 'Подтверждение номера',
      'inboundCallSubtitle':
          'Совершите бесплатный звонок с вашего номера\n{phone}',
      'callFree': 'Позвонить (бесплатно)',
      'waitingForCall': 'Ожидание звонка…',
      'phoneVerifiedSuccess': 'Номер успешно подтверждён!',
      'inboundCallHint':
          'Звонок бесплатный. Вызов сбросится автоматически, отвечать не потребуется.',
      'changePhone': 'Изменить номер',
      'flashCallSubtitle':
          'Мы совершаем проверочный звонок на номер\n{phone}\nВведите последние 4 цифры входящего номера:',
      'requestCallAgain': 'Запросить звонок повторно',
      'invalidCode': 'Неверный код',
      'codeVerificationError': 'Ошибка проверки кода',
      'phoneVerificationInitError': 'Ошибка при инициализации верификации',
    },
    'en': {
      'voiceCallSubtitle': 'You will receive a call at\n{phone}\nEnter the code spoken during the call:',
      'phoneStepTitle': 'Phone number',
      'phoneStepRuSubtitle':
          'To verify, you will need to make a free call to 8-800',
      'phoneStepIntlSubtitle':
          'For international numbers, you will receive a verification call',
      'phoneConfirmation': 'Phone confirmation',
      'inboundCallSubtitle':
          'Make a toll-free call from your number\n{phone}',
      'callFree': 'Call (toll-free)',
      'waitingForCall': 'Waiting for call…',
      'phoneVerifiedSuccess': 'Phone successfully verified!',
      'inboundCallHint':
          'The call is toll-free. It hangs up automatically, no need to answer.',
      'changePhone': 'Change number',
      'flashCallSubtitle':
          'Incoming verification call to\n{phone}\nEnter the last 4 digits of the caller number:',
      'requestCallAgain': 'Request call again',
      'invalidCode': 'Invalid code',
      'codeVerificationError': 'Code verification error',
      'phoneVerificationInitError': 'Phone verification initialization error',
    },
    'es': {
      'voiceCallSubtitle': 'Recibirás una llamada al\n{phone}\nIntroduce el código que escuches:',
      'phoneStepTitle': 'Número de teléfono',
      'phoneStepRuSubtitle':
          'Para verificar, deberá realizar una llamada gratuita al 8-800',
      'phoneStepIntlSubtitle':
          'Para números internacionales, recibirá una llamada de verificación',
      'phoneConfirmation': 'Confirmación de teléfono',
      'inboundCallSubtitle':
          'Realice una llamada gratuita desde su número\n{phone}',
      'callFree': 'Llamar (gratis)',
      'waitingForCall': 'Esperando llamada…',
      'phoneVerifiedSuccess': '¡Número verificado con éxito!',
      'inboundCallHint':
          'La llamada es gratuita y se cortará automáticamente.',
      'changePhone': 'Cambiar número',
      'flashCallSubtitle':
          'Llamada de verificación a\n{phone}\nIngrese los últimos 4 dígitos del número entrante:',
      'requestCallAgain': 'Solicitar llamada de nuevo',
      'invalidCode': 'Código incorrecto',
      'codeVerificationError': 'Error al verificar el código',
      'phoneVerificationInitError': 'Error al inicializar la verificación',
    },
    'fr': {
      'voiceCallSubtitle': 'Vous recevrez un appel au\n{phone}\nSaisissez le code dicté pendant cet appel :',
      'phoneStepTitle': 'Numéro de téléphone',
      'phoneStepRuSubtitle':
          'Pour confirmer, un appel gratuit au 8-800 sera nécessaire',
      'phoneStepIntlSubtitle':
          'Pour les numéros internationaux, un appel de confirmation sera émis',
      'phoneConfirmation': 'Confirmation du numéro',
      'inboundCallSubtitle':
          'Passez un appel gratuit depuis votre numéro\n{phone}',
      'callFree': 'Appeler (gratuit)',
      'waitingForCall': 'En attente de l’appel…',
      'phoneVerifiedSuccess': 'Numéro vérifié avec succès !',
      'inboundCallHint':
          'L’appel est gratuit et raccrochera automatiquement.',
      'changePhone': 'Modifier le numéro',
      'flashCallSubtitle':
          'Appel de vérification vers le\n{phone}\nEntrez les 4 derniers chiffres du numéro entrant :',
      'requestCallAgain': 'Demander un nouvel appel',
      'invalidCode': 'Code invalide',
      'codeVerificationError': 'Erreur de vérification du code',
      'phoneVerificationInitError': 'Erreur d’initialisation de la vérification',
    },
    'zh': {
      'voiceCallSubtitle': '您将收到拨打\n{phone}\n的电话。请输入语音播报的验证码：',
      'phoneStepTitle': '手机号码',
      'phoneStepRuSubtitle': '验证时需拨打 8-800 免费电话',
      'phoneStepIntlSubtitle': '国际号码将收到来电验证',
      'phoneConfirmation': '验证手机号',
      'inboundCallSubtitle': '请使用您的号码拨打免费电话\n{phone}',
      'callFree': '拨打电话（免费）',
      'waitingForCall': '等待来电中…',
      'phoneVerifiedSuccess': '手机号码验证成功！',
      'inboundCallHint': '通话免费，系统会自动挂断，无需接听。',
      'changePhone': '修改号码',
      'flashCallSubtitle': '我们将致电\n{phone}\n请输入来电号码的后 4 位：',
      'requestCallAgain': '重新请求来电',
      'invalidCode': '验证码错误',
      'codeVerificationError': '验证码校验失败',
      'phoneVerificationInitError': '初始化验证失败',
    },
    'ja': {
      'voiceCallSubtitle': '{phone} に確認の電話が届きます。\n音声で案内されるコードを入力してください：',
      'phoneStepTitle': '電話番号',
      'phoneStepRuSubtitle': '確認のため 8-800 への無料通話が必要です',
      'phoneStepIntlSubtitle': '国際電話番号の場合は確認電話が発信されます',
      'phoneConfirmation': '電話番号の確認',
      'inboundCallSubtitle': 'ご自身の番号から無料通話を発信してください\n{phone}',
      'callFree': '発信（無料）',
      'waitingForCall': '着信待機中…',
      'phoneVerifiedSuccess': '電話番号の確認が完了しました！',
      'inboundCallHint': '通話料は無料です。自動で切断されるため応答は不要です。',
      'changePhone': '番号を変更',
      'flashCallSubtitle': '{phone} へ確認の着信があります。\n着信番号の下4桁を入力してください：',
      'requestCallAgain': 'もう一度電話をリクエスト',
      'invalidCode': 'コードが無効です',
      'codeVerificationError': 'コード確認エラー',
      'phoneVerificationInitError': '認証の初期化に失敗しました',
    },
    'ko': {
      'voiceCallSubtitle': '{phone} 번호로 인증 전화가 옵니다.\n음성으로 안내되는 코드를 입력하세요:',
      'phoneStepTitle': '전화번호',
      'phoneStepRuSubtitle': '인증을 위해 8-800 무료 통화가 필요합니다',
      'phoneStepIntlSubtitle': '해외 번호는 인증 전화가 발신됩니다',
      'phoneConfirmation': '전화번호 인증',
      'inboundCallSubtitle': '해당 번호로 무료 전화를 걸어주세요\n{phone}',
      'callFree': '통화 연결 (무료)',
      'waitingForCall': '통화 대기 중…',
      'phoneVerifiedSuccess': '전화번호가 성공적으로 인증되었습니다!',
      'inboundCallHint': '무료 통화이며 자동으로 끊어지므로 받을 필요가 없습니다.',
      'changePhone': '번호 변경',
      'flashCallSubtitle': '{phone} 번호로 확인 전화가 수신됩니다.\n수신된 번호의 마지막 4자리를 입력하세요:',
      'requestCallAgain': '전화 다시 요청',
      'invalidCode': '잘못된 코드입니다',
      'codeVerificationError': '코드 확인 오류',
      'phoneVerificationInitError': '인증 초기화 오류',
    },
    'ar': {
      'voiceCallSubtitle': 'ستتلقى مكالمة على الرقم\n{phone}\nأدخل الرمز الذي تسمعه:',
      'phoneStepTitle': 'رقم الهاتف',
      'phoneStepRuSubtitle': 'للتأكيد، يلزم إجراء مكالمة مجانية إلى 8-800',
      'phoneStepIntlSubtitle': 'للأرقام الدولية، سيتم إجراء مكالمة تحقق',
      'phoneConfirmation': 'تأكيد رقم الهاتف',
      'inboundCallSubtitle': 'يرجى إجراء مكالمة مجانية من رقمك\n{phone}',
      'callFree': 'اتصال (مجاني)',
      'waitingForCall': 'بانتظار المكالمة…',
      'phoneVerifiedSuccess': 'تم تأكيد رقم الهاتف بنجاح!',
      'inboundCallHint': 'المكالمة مجانية وسيتم إنهاؤها تلقائيًا دون الحاجة للرد.',
      'changePhone': 'تغيير الرقم',
      'flashCallSubtitle': 'جارٍ الاتصال بالرقم\n{phone}\nأدخل آخر 4 أرقام من الرقم المتصل:',
      'requestCallAgain': 'طلب مكالمة مرة أخرى',
      'invalidCode': 'رمز غير صحيح',
      'codeVerificationError': 'خطأ في التحقق من الرمز',
      'phoneVerificationInitError': 'خطأ أثناء تهيئة التحقق',
    },
  };

  /// Returns translated string for given key, resolving user custom language pack first.
  String text(String name, {Map<String, dynamic>? params}) {
    final valuesForLocale =
        _values[languageCode] ?? _values['ru'] ?? _values['en']!;
    var result = valuesForLocale[name] ?? (_values['ru']?[name] ?? name);

    // 1. Resolve through active user custom pack if present
    final rt = RuntimeTranslations.instance;
    if (rt.hasActiveCustomPack) {
      final customResolved =
          rt.resolve('register.$name', result, params: params);
      if (customResolved != result) {
        return customResolved;
      }
      final resolvedByText = rt.resolveByText(result);
      if (resolvedByText != result) {
        result = resolvedByText;
      }
    }

    if (params != null && params.isNotEmpty) {
      params.forEach((k, v) {
        result = result.replaceAll('{$k}', v.toString());
      });
    }

    return result;
  }
}
