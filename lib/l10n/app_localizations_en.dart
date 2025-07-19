// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get profile => 'Profile';

  @override
  String get changeLanguage => 'Change Language';

  @override
  String get changePassword => 'Change Password';

  @override
  String get currentPassword => 'Current Password';

  @override
  String get newPassword => 'New Password';

  @override
  String get cancel => 'Cancel';

  @override
  String get change => 'Change';

  @override
  String get passwordUpdated => 'Password updated';

  @override
  String get wrongPassword => 'Wrong current password';

  @override
  String get logout => 'Logout';

  @override
  String get about => 'About Us';

  @override
  String get aboutDescription =>
      'This is a secure chat application developed with end-to-end encryption.';

  @override
  String get privacy => 'Privacy Policy';

  @override
  String get privacyDescription =>
      'Secure Chat is a privacy-first communication platform developed by Hacker Atyrau — an elite team from Kazakhstan dedicated to cybersecurity, privacy engineering, and ethical communication technologies.\n\nWe do not collect, sell, or share your personal data. All messages are end-to-end encrypted using industry-standard cryptographic algorithms. Even our developers cannot access your private conversations.\n\n🔒 Every chat is stored encrypted.\n🕵️ No ads, no trackers, no profiling.\n🛡️ Open-source transparency and code audits.\n\nThis project was built under the mission of making Kazakhstan a global leader in secure digital communication. Hacker Atyrau is committed to defending your right to freedom, privacy, and secure expression in the digital age.\n\nWe are not just a messenger.\nWe are a movement for digital dignity.\n\n© 2025 Hacker Atyrau Team\nAll rights reserved.';

  @override
  String get ok => 'OK';

  @override
  String get changeAvatar => 'Change avatar';

  @override
  String get aboutMe => 'About Me';

  @override
  String get noBioYet => 'No bio yet';

  @override
  String get editBio => 'Edit Bio';

  @override
  String get editBioHint => 'Write something fun or meaningful...';

  @override
  String get save => 'Save';

  @override
  String get offlineCommunication => 'Offline Communication';

  @override
  String get offlineCommunicationDesc => 'Encrypted messaging without internet';

  @override
  String get offlineChatTitle => 'Offline Chat';

  @override
  String get offlineChatDesc =>
      'This feature is under development.\n\nYou will soon be able to send and receive encrypted messages even without internet using Bluetooth or mesh network.';

  @override
  String get vpn => 'Built-in VPN';

  @override
  String get vpnDesc => 'Protect your traffic using integrated VPN';

  @override
  String get vpnTitle => 'VPN Module';

  @override
  String get vpnDialogDesc =>
      'Our secure VPN feature is coming soon.\n\nYou’ll be able to route all your traffic through encrypted tunnels to stay private and secure.';

  @override
  String get proxy => 'Proxy Settings';

  @override
  String get proxyDesc => 'Custom proxy or Tor support';

  @override
  String get proxyTitle => 'Proxy & Tor';

  @override
  String get proxyDialogDesc =>
      'This feature is under construction.\n\nSoon you will be able to use your own proxy or connect through Tor for enhanced anonymity and censorship bypass.';

  @override
  String get requestVerification => 'Request Verification';

  @override
  String get requestVerificationDesc => 'Apply for the blue checkmark';

  @override
  String get chooseVerificationType => 'Choose Verification Type';

  @override
  String get personalIdentity => 'Personal Identity';

  @override
  String get businessOrganization => 'Business/Organization';

  @override
  String get sendResetEmail => 'Send Reset Email';

  @override
  String get welcomeBack => 'Welcome Back!';

  @override
  String get loginSubtitle => 'Login to continue your secure chats';

  @override
  String get emailOrUsername => 'Email or Username';

  @override
  String get password => 'Password';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get forgotPasswordDialog =>
      'To reset your password, please send an email to our support team:\n\nсyberwest.kz@gmail.com\n\nYour personal data will remain protected and confidential during this process.';

  @override
  String get login => 'Login';

  @override
  String get dontHaveAccount => 'Don\'t have an account? Register';

  @override
  String get contactSupport => 'Contact Support';

  @override
  String get createAccount => 'Create Account';

  @override
  String get joinSubtitle => 'Join the most secure messenger';

  @override
  String get username => 'Username';

  @override
  String get email => 'Email';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get register => 'Register';

  @override
  String get alreadyHaveAccount => 'Already have an account? Login';

  @override
  String get fillAllFields => 'Please fill in all fields';

  @override
  String get passwordTooShort => 'Password must be at least 8 characters';

  @override
  String get passwordsDontMatch => 'Passwords do not match';

  @override
  String get confirmEmailTitle => '📧 Confirm Email';

  @override
  String confirmEmailDesc(Object email) {
    return 'Do you really want to register with this email?\n\n$email';
  }

  @override
  String get confirm => 'Yes, Register';

  @override
  String get emailSent => '📨 Email Sent';

  @override
  String emailSentDesc(Object email) {
    return 'A verification email has been sent to:\n\n$email\n\nPlease check your inbox or spam folder before logging in.';
  }

  @override
  String get chats => 'Chats';

  @override
  String get stories => 'Stories';

  @override
  String get groups => 'Groups';

  @override
  String get noChats => 'No secure chats yet';

  @override
  String get inDevelopment => 'In Development';

  @override
  String get noGroups => 'No groups yet';

  @override
  String membersCount(Object count) {
    return 'Members: $count';
  }

  @override
  String get findUser => 'Find user';

  @override
  String get createGroup => 'Create group';

  @override
  String get createGroupTitle => 'Create Group';

  @override
  String get groupNameHint => 'Group name';

  @override
  String get groupCreationError => 'Failed to create group';

  @override
  String get contactBlocked => 'Contact is blocked';

  @override
  String get contactUnblocked => 'Contact is unblocked';

  @override
  String get deleteChat => 'Delete chat';

  @override
  String get areYouSure => 'Are you sure?';

  @override
  String get changeDecryption => 'Change decryption';

  @override
  String get pinChat => 'Pin chat';

  @override
  String get unpinChat => 'Chat unpinned';

  @override
  String get chatPinned => 'Chat pinned';

  @override
  String get featureInDev => 'Feature in development';

  @override
  String get delete => 'Delete';

  @override
  String get chooseDecryption => 'Choose decryption type';

  @override
  String get justNow => 'just now';

  @override
  String minutesAgo(Object minutes) {
    return '$minutes min ago';
  }

  @override
  String hoursAgo(Object hours) {
    return '$hours h ago';
  }

  @override
  String daysAgo(Object days) {
    return '$days d ago';
  }

  @override
  String get offline => 'Offline';

  @override
  String get online => 'Online';

  @override
  String get algorithm => 'Algorithm';
}
