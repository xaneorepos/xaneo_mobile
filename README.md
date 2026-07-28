# Xaneo Mobile v2

<div align="center">

![Xaneo Logo](assets/images/logo.png)

### **Современный защищённый мобильный и кроссплатформенный мессенджер на Flutter**

[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-%230175C2.svg?style=for-the-badge&logo=Dart&logoColor=white)](https://dart.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge)](LICENSE)
[![GitHub Stars](https://img.shields.io/github/stars/xaneorepos/xaneo_mobile?style=for-the-badge&logo=github&color=gold)](https://github.com/xaneorepos/xaneo_mobile/stargazers)
[![GitHub Forks](https://img.shields.io/github/forks/xaneorepos/xaneo_mobile?style=for-the-badge&logo=github)](https://github.com/xaneorepos/xaneo_mobile/network/members)
[![GitHub Issues](https://img.shields.io/github/issues/xaneorepos/xaneo_mobile?style=for-the-badge&logo=github)](https://github.com/xaneorepos/xaneo_mobile/issues)

[![Platforms](https://img.shields.io/badge/Platforms-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Desktop-blue?style=for-the-badge&logo=android)](https://github.com/xaneorepos/xaneo_mobile)

</div>

---

## 📌 О проекте

**Xaneo Mobile v2** — это защищённое кроссплатформенное мобильное приложение-мессенджер нового поколения, написанное на **Flutter** и **Dart**. 

Проект спроектирован с упором на сквозное шифрование (E2EE) по стандарту XSEC-2, зашифрованное локальное хранилище данных (SQLCipher), групповые и личные аудио/видеозвонки (LiveKit / WebRTC), push-уведомления и нативные экраны входящих вызовов (CallKit).

> **Примечание:** Это мобильный клиент экосистемы Xaneo.

---

## 🌟 Основные возможности

- 💬 **Чаты и Каналы**:
  - Личные сообщения, групповые чаты и информационные каналы.
  - Архивирование диалогов и быстрый поиск по сообщениям/контактам.
  - Голосовые сообщения (запись через `record`, воспроизведение через `just_audio`).
  - Передача изображений, видео (с превью), документов и аватарок.

- 📞 **Личные и Групповые Звонки**:
  - Голосовые и видеовызовы в реальном времени на базе **LiveKit** и **WebRTC**.
  - Нативная интеграция **Flutter CallKit Incoming** для стильных экранов входящего вызова при заблокированном экране.

- 🔒 **Криптография и Безопасность (XSEC-2)**:
  - Сквозное шифрование (E2E) с использованием криптографических алгоритмов **Argon2**, **X25519** и **PointyCastle**.
  - Зашифрованная локальная база данных **Drift + SQLCipher** (`sqlcipher_flutter_libs`).
  - Безопасное хранение токенов и сессий в **Flutter Secure Storage**.
  - Опциональная биометрическая аутентификация (`local_auth`).

- 🔔 **Push-Уведомления**:
  - Интеграция с **Firebase Cloud Messaging (FCM)** и **Flutter Local Notifications** для моментального получения сообщений и вызовов.

- 🎨 **Современный UI/UX**:
  - Адаптивный и интуитивный интерфейс с поддержкой плавных Lottie-анимаций, кастомных шрифтов **Inter** и Google Fonts.

---

## 🛠 Технологический стек

### Core & Framework
| Технология | Описание |
| :--- | :--- |
| **Flutter 3.x** | Кроссплатформенный UI фреймворк |
| **Dart SDK ^3.0.0** | Основной язык разработки |
| **Provider** | Управление состоянием (State Management) |

### База данных & Хранение (Database & Storage)
| Технология | Описание |
| :--- | :--- |
| **Drift (SQLite ORM)** | Реактивная ORM база данных |
| **SQLCipher** | Полнодисковое шифрование локальной БД |
| **Flutter Secure Storage** | Нативное безопасное хранилище ключей (Keystore / Keychain) |

### Сеть и Протоколы (Networking)
| Технология | Описание |
| :--- | :--- |
| **gRPC & Protobuf** | Высокопроизводительные gRPC вызовы |
| **WebSockets** | Сигнальный сервис реального времени |
| **Dio & Http** | REST API клиенты с поддержкой куки (`cookie_jar`) |

### Звонки, Медиа & Push-уведомления
| Технология | Описание |
| :--- | :--- |
| **LiveKit Client & WebRTC** | Видио- и аудиосвязь для личных и групповых звонков |
| **Flutter CallKit Incoming** | Нативный экран входящего вызова на Android / iOS |
| **Firebase Messaging & Local Notifications** | Push-уведомления |
| **Just Audio & Record** | Запись и воспроизведение голосовых сообщений |
| **Chewie & Video Player** | Воспроизведение видео в чатах |

---

## 🚀 Запуск и Сборка

### Требования
- Flutter SDK (3.x+)
- Dart SDK (^3.0.0)
- Android Studio / Xcode (для сборки под мобильные ОС)

### Запуск в режиме разработки

```bash
# Установка зависимостей
flutter pub get

# Генерация файлов Drift БД и gRPC
flutter pub run build_runner build --delete-conflicting-outputs

# Запуск на подключённом устройстве или эмуляторе
flutter run
```

### Сборка релизных пакетов

#### Android (APK / AAB)
```bash
flutter build apk --release
flutter build appbundle --release
```

#### iOS (IPA)
```bash
flutter build ipa --release
```

---

## 📄 Лицензия

Проект распространяется под лицензией **MIT License**. Подробнее см. в файле [LICENSE](LICENSE).

<div align="center">
  <sub>Created with ❤️ by <a href="https://github.com/xaneorepos">Xaneo Repos</a></sub>
</div>
