// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name =
        (locale.countryCode?.isEmpty ?? false)
            ? locale.languageCode
            : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Email`
  String get email {
    return Intl.message('Email', name: 'email', desc: '', args: []);
  }

  /// `Password`
  String get password {
    return Intl.message('Password', name: 'password', desc: '', args: []);
  }

  /// `Log In`
  String get login {
    return Intl.message('Log In', name: 'login', desc: '', args: []);
  }

  /// `Logging in...`
  String get logging_in {
    return Intl.message(
      'Logging in...',
      name: 'logging_in',
      desc: '',
      args: [],
    );
  }

  /// `Welcome {userName} 👋`
  String welcomeMessage(Object userName) {
    return Intl.message(
      'Welcome $userName 👋',
      name: 'welcomeMessage',
      desc: '',
      args: [userName],
    );
  }

  /// `Latest News`
  String get latestNewsTitle {
    return Intl.message(
      'Latest News',
      name: 'latestNewsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Today's Reservations`
  String get todaysReservationsTitle {
    return Intl.message(
      'Today\'s Reservations',
      name: 'todaysReservationsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Today's Visitors`
  String get todaysVisitorsTitle {
    return Intl.message(
      'Today\'s Visitors',
      name: 'todaysVisitorsTitle',
      desc: '',
      args: [],
    );
  }

  /// `New Reservation`
  String get newReservation {
    return Intl.message(
      'New Reservation',
      name: 'newReservation',
      desc: '',
      args: [],
    );
  }

  /// `New Visitor`
  String get newVisitor {
    return Intl.message('New Visitor', name: 'newVisitor', desc: '', args: []);
  }

  /// `—`
  String get sectionDivider {
    return Intl.message('—', name: 'sectionDivider', desc: '', args: []);
  }

  /// `Niddo`
  String get appTitle {
    return Intl.message('Niddo', name: 'appTitle', desc: '', args: []);
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'es'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
