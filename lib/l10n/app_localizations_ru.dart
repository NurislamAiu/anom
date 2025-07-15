// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get profile => 'Профиль';

  @override
  String get changeLanguage => 'Сменить язык';

  @override
  String get changePassword => 'Сменить пароль';

  @override
  String get currentPassword => 'Текущий пароль';

  @override
  String get newPassword => 'Новый пароль';

  @override
  String get cancel => 'Отмена';

  @override
  String get change => 'Изменить';

  @override
  String get passwordUpdated => 'Пароль обновлён';

  @override
  String get wrongPassword => 'Неверный текущий пароль';

  @override
  String get logout => 'Выйти';

  @override
  String get about => 'О нас';

  @override
  String get aboutDescription =>
      'Это защищённое чат-приложение с сквозным шифрованием.';

  @override
  String get privacy => 'Политика конфиденциальности';

  @override
  String get privacyDescription =>
      'Secure Chat — это защищённый мессенджер, разработанный командой Hacker Атырау — ведущими специалистами Казахстана в области кибербезопасности и приватных технологий.\n\nМы не собираем ваши личные данные. Все сообщения зашифрованы сквозным шифрованием (end-to-end) и недоступны даже для наших разработчиков.\n\n🔒 Все чаты хранятся в зашифрованном виде.\n🕵️ Отсутствуют рекламные трекеры, сбор аналитики и слежка.\n🛡️ Код прозрачен и поддаётся внешнему аудиту.\n\nПроект создан с целью сделать Казахстан мировым лидером в области цифровой безопасности. Hacker Атырау — это не просто разработчики, это движение за цифровую свободу и достоинство.\n\nМы не просто мессенджер.\nМы — щит вашей цифровой личности.\n\n© 2025 Hacker Атырау\nВсе права защищены.';

  @override
  String get ok => 'ОК';
}
