// lib/main.dart

import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'screens/home_page.dart';
import 'screens/program_page.dart';
import 'screens/techniques_page.dart';
import 'screens/profile_page.dart';
import 'screens/dojo_page.dart';

Future<void> setupPushNotifications() async {
  final fcm = FirebaseMessaging.instance;
  await fcm.requestPermission();
  try {
    final token = await fcm.getToken();
    debugPrint('FCM Token: $token');
    await fcm.subscribeToTopic('announcements');
    debugPrint('Subscribed to announcements topic');
  } catch (e) {
    debugPrint('Failed to get FCM token: $e');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initializeDateFormatting('el_GR', null);

  if (kIsWeb == false && (Platform.isAndroid || Platform.isIOS)) {
    await setupPushNotifications();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aikido Kalamata Dojo',
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('el', ''),
        Locale('en', ''),
      ],
      locale: const Locale('el'),
      theme: ThemeData(
        fontFamily: 'ZonaPro',
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          centerTitle: true,
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.red,
          ),
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  User? _currentUser;
  bool _isMemberActive = false;
  late StreamSubscription<User?> _authSubscription;

  @override
  void initState() {
    super.initState();
    _authSubscription =
        FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      _currentUser = user;
      if (user == null) {
        _isMemberActive = false;
        if (_selectedIndex == 2 || _selectedIndex == 3) {
          _selectedIndex = 0;
        }
      } else {
        await _checkUserStatus(user);
      }
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<void> _checkUserStatus(User user) async {
    final idToken = await user.getIdTokenResult(true);
    if (idToken.claims?['admin'] == true) {
      _isMemberActive = true;
      return;
    }
    final memberRef =
        FirebaseFirestore.instance.collection('members').doc(user.uid);
    final memberDoc = await memberRef.get();
    if (memberDoc.exists) {
      _isMemberActive = true;
      return;
    }
    final querySnapshot = await FirebaseFirestore.instance
        .collection('members')
        .where('email', isEqualTo: user.email?.toLowerCase())
        .limit(1)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      final oldDoc = querySnapshot.docs.first;
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.set(memberRef, oldDoc.data());
        transaction.delete(oldDoc.reference);
      });
      _isMemberActive = true;
      return;
    }
    _isMemberActive = false;
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  static final List<Widget> _widgetOptions = <Widget>[
    const HomePage(),
    const ProgramPage(),
    const TechniquesPage(),
    const ProfilePage(),
    const DojoPage(),
  ];

  void _onItemTapped(int index) {
    final bool isLoggedIn = _currentUser != null;
    if (!isLoggedIn && index == 3) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Πρέπει να συνδεθείτε για αυτή τη λειτουργία.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2)));
      return;
    }
    if (!_isMemberActive && index == 2) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Αυτή η λειτουργία είναι μόνο για ενεργά μέλη.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2)));
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool showLockForTechniques = !_isMemberActive;
    final bool showLockForProfile = _currentUser == null;

    // --- Η ΑΛΛΑΓΗ ΕΙΝΑΙ ΕΔΩ ---
    return WillPopScope(
      onWillPop: () async {
        // Αν δεν είμαστε στην αρχική σελίδα (index 0)
        if (_selectedIndex != 0) {
          // Πήγαινε στην αρχική σελίδα
          setState(() {
            _selectedIndex = 0;
          });
          // Πες στο σύστημα "Μην κλείσεις την εφαρμογή" (επέστρεψε false)
          return false;
        }
        // Αν είμαστε ήδη στην αρχική, άφησε την εφαρμογή να κλείσει (επέστρεψε true)
        return true;
      },
      child: Scaffold(
        body: Center(
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white,
          elevation: 5,
          items: <BottomNavigationBarItem>[
            const BottomNavigationBarItem(
                icon: Icon(Icons.home), label: 'Αρχική'),
            const BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today), label: 'Πρόγραμμα'),
            BottomNavigationBarItem(
              icon: Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  const Icon(Icons.book),
                  if (showLockForTechniques)
                    Positioned(
                      top: -2,
                      right: -4,
                      child: Container(
                        padding: const EdgeInsets.all(1),
                        decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(6)),
                        constraints:
                            const BoxConstraints(minWidth: 12, minHeight: 12),
                        child: const Icon(Icons.lock,
                            size: 8, color: Colors.white),
                      ),
                    )
                ],
              ),
              label: 'Τεχνικές',
            ),
            BottomNavigationBarItem(
              icon: Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  const Icon(Icons.person),
                  if (showLockForProfile)
                    Positioned(
                      top: -2,
                      right: -4,
                      child: Container(
                        padding: const EdgeInsets.all(1),
                        decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(6)),
                        constraints:
                            const BoxConstraints(minWidth: 12, minHeight: 12),
                        child: const Icon(Icons.lock,
                            size: 8, color: Colors.white),
                      ),
                    )
                ],
              ),
              label: 'Προφίλ',
            ),
            const BottomNavigationBarItem(
                icon: Icon(Icons.info), label: 'Dojo'),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.red,
          unselectedItemColor: const Color(0xFF2f2a2a),
          onTap: _onItemTapped,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }
}
