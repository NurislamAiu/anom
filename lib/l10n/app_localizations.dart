import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
  ];

  /// No description provided for @profile.
  ///
  /// In ru, this message translates to:
  /// **'Профиль'**
  String get profile;

  /// No description provided for @changeLanguage.
  ///
  /// In ru, this message translates to:
  /// **'Сменить язык'**
  String get changeLanguage;

  /// No description provided for @changePassword.
  ///
  /// In ru, this message translates to:
  /// **'Сменить пароль'**
  String get changePassword;

  /// No description provided for @currentPassword.
  ///
  /// In ru, this message translates to:
  /// **'Текущий пароль'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In ru, this message translates to:
  /// **'Новый пароль'**
  String get newPassword;

  /// No description provided for @cancel.
  ///
  /// In ru, this message translates to:
  /// **'Отмена'**
  String get cancel;

  /// No description provided for @change.
  ///
  /// In ru, this message translates to:
  /// **'Изменить'**
  String get change;

  /// No description provided for @passwordUpdated.
  ///
  /// In ru, this message translates to:
  /// **'Пароль обновлён'**
  String get passwordUpdated;

  /// No description provided for @wrongPassword.
  ///
  /// In ru, this message translates to:
  /// **'Неверный текущий пароль'**
  String get wrongPassword;

  /// No description provided for @logout.
  ///
  /// In ru, this message translates to:
  /// **'Выйти'**
  String get logout;

  /// No description provided for @about.
  ///
  /// In ru, this message translates to:
  /// **'О нас'**
  String get about;

  /// No description provided for @aboutDescription.
  ///
  /// In ru, this message translates to:
  /// **'Это защищённое чат-приложение с сквозным шифрованием.'**
  String get aboutDescription;

  /// No description provided for @privacy.
  ///
  /// In ru, this message translates to:
  /// **'Политика конфиденциальности'**
  String get privacy;

  /// No description provided for @privacyDescription.
  ///
  /// In ru, this message translates to:
  /// **'Secure Chat — это защищённый мессенджер, разработанный командой Hacker Атырау — ведущими специалистами Казахстана в области кибербезопасности и приватных технологий.\n\nМы не собираем ваши личные данные. Все сообщения зашифрованы сквозным шифрованием (end-to-end) и недоступны даже для наших разработчиков.\n\n🔒 Все чаты хранятся в зашифрованном виде.\n🕵️ Отсутствуют рекламные трекеры, сбор аналитики и слежка.\n🛡️ Код прозрачен и поддаётся внешнему аудиту.\n\nПроект создан с целью сделать Казахстан мировым лидером в области цифровой безопасности. Hacker Атырау — это не просто разработчики, это движение за цифровую свободу и достоинство.\n\nМы не просто мессенджер.\nМы — щит вашей цифровой личности.\n\n© 2025 Hacker Атырау\nВсе права защищены.'**
  String get privacyDescription;

  /// No description provided for @ok.
  ///
  /// In ru, this message translates to:
  /// **'ОК'**
  String get ok;

  /// No description provided for @changeAvatar.
  ///
  /// In ru, this message translates to:
  /// **'Изменить аватар'**
  String get changeAvatar;

  /// No description provided for @aboutMe.
  ///
  /// In ru, this message translates to:
  /// **'О себе'**
  String get aboutMe;

  /// No description provided for @noBioYet.
  ///
  /// In ru, this message translates to:
  /// **'Биография не указана'**
  String get noBioYet;

  /// No description provided for @editBio.
  ///
  /// In ru, this message translates to:
  /// **'Редактировать биографию'**
  String get editBio;

  /// No description provided for @editBioHint.
  ///
  /// In ru, this message translates to:
  /// **'Напишите что-нибудь интересное или осмысленное...'**
  String get editBioHint;

  /// No description provided for @save.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить'**
  String get save;

  /// No description provided for @offlineCommunication.
  ///
  /// In ru, this message translates to:
  /// **'Офлайн-связь'**
  String get offlineCommunication;

  /// No description provided for @offlineCommunicationDesc.
  ///
  /// In ru, this message translates to:
  /// **'Шифрованные сообщения без интернета'**
  String get offlineCommunicationDesc;

  /// No description provided for @offlineChatTitle.
  ///
  /// In ru, this message translates to:
  /// **'Офлайн-чат'**
  String get offlineChatTitle;

  /// No description provided for @offlineChatDesc.
  ///
  /// In ru, this message translates to:
  /// **'Эта функция в разработке.\n\nСкоро вы сможете отправлять и получать зашифрованные сообщения даже без интернета с помощью Bluetooth или mesh-сети.'**
  String get offlineChatDesc;

  /// No description provided for @vpn.
  ///
  /// In ru, this message translates to:
  /// **'Встроенный VPN'**
  String get vpn;

  /// No description provided for @vpnDesc.
  ///
  /// In ru, this message translates to:
  /// **'Защитите трафик через встроенный VPN'**
  String get vpnDesc;

  /// No description provided for @vpnTitle.
  ///
  /// In ru, this message translates to:
  /// **'VPN-модуль'**
  String get vpnTitle;

  /// No description provided for @vpnDialogDesc.
  ///
  /// In ru, this message translates to:
  /// **'Функция безопасного VPN скоро появится.\n\nВы сможете перенаправлять весь трафик через зашифрованный туннель для максимальной конфиденциальности.'**
  String get vpnDialogDesc;

  /// No description provided for @proxy.
  ///
  /// In ru, this message translates to:
  /// **'Настройки прокси'**
  String get proxy;

  /// No description provided for @proxyDesc.
  ///
  /// In ru, this message translates to:
  /// **'Поддержка собственного прокси или Tor'**
  String get proxyDesc;

  /// No description provided for @proxyTitle.
  ///
  /// In ru, this message translates to:
  /// **'Прокси и Tor'**
  String get proxyTitle;

  /// No description provided for @proxyDialogDesc.
  ///
  /// In ru, this message translates to:
  /// **'Эта функция в разработке.\n\nСкоро вы сможете использовать собственный прокси или подключаться через Tor для анонимности и обхода цензуры.'**
  String get proxyDialogDesc;

  /// No description provided for @requestVerification.
  ///
  /// In ru, this message translates to:
  /// **'Запросить верификацию'**
  String get requestVerification;

  /// No description provided for @requestVerificationDesc.
  ///
  /// In ru, this message translates to:
  /// **'Подайте заявку на значок подтверждения'**
  String get requestVerificationDesc;

  /// No description provided for @chooseVerificationType.
  ///
  /// In ru, this message translates to:
  /// **'Выберите тип верификации'**
  String get chooseVerificationType;

  /// No description provided for @personalIdentity.
  ///
  /// In ru, this message translates to:
  /// **'Личная личность'**
  String get personalIdentity;

  /// No description provided for @businessOrganization.
  ///
  /// In ru, this message translates to:
  /// **'Бизнес / Организация'**
  String get businessOrganization;

  /// No description provided for @sendResetEmail.
  ///
  /// In ru, this message translates to:
  /// **'Отправить письмо для сброса'**
  String get sendResetEmail;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
