// lib/screens/profile_page.dart

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

import 'package:aikido_kalamata_app/screens/member_management_page.dart';
import 'package:aikido_kalamata_app/screens/announcements_management_page.dart';
import 'package:aikido_kalamata_app/screens/subscriptions_history_page.dart';
import 'package:aikido_kalamata_app/screens/inbox_page.dart';
import 'package:aikido_kalamata_app/screens/member_messages_page.dart';
import 'package:aikido_kalamata_app/screens/rank_history_page.dart';
import 'package:aikido_kalamata_app/screens/progress_page.dart';
import 'package:aikido_kalamata_app/screens/nafudakake_page.dart';
import 'package:aikido_kalamata_app/screens/financial_summary_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isAdmin = false;
  bool _isLoading = true;
  DocumentSnapshot? _memberData;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (!_isLoading) setState(() => _isLoading = true);
    
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    final idTokenResult = await user.getIdTokenResult(true);
    final isAdminClaim = idTokenResult.claims?['admin'] as bool? ?? false;

    if (!isAdminClaim) {
      try {
        final doc = await FirebaseFirestore.instance.collection('members').doc(user.uid).get();
        if (doc.exists) {
          _memberData = doc;
        } else {
          _memberData = null;
        }
      } catch (e) {
        debugPrint("Error fetching member data: $e");
        _memberData = null;
      }
    }
    
    if (mounted) {
      setState(() {
        _isAdmin = isAdminClaim;
        _isLoading = false;
      });
    }
  }

  Future<void> _pickAndSaveImage() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    setState(() => _isUploading = true);

    try {
      final imageBytes = await pickedFile.readAsBytes();
      final image = img.decodeImage(imageBytes);
      if (image == null) return;

      final resizedImage = img.copyResize(image, width: 400);
      final compressedBytes = img.encodeJpg(resizedImage, quality: 85);
      final base64String = base64Encode(compressedBytes);

      await FirebaseFirestore.instance.collection('members').doc(user.uid).update({
        'photoBase64': base64String,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Η φωτογραφία προφίλ ενημερώθηκε!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      debugPrint("Image Processing Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Παρουσιάστηκε σφάλμα: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
        _loadUserData(); 
      }
    }
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  void _showContactDialog() {
    final messageController = TextEditingController();
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Αποστολή Μηνύματος'),
          content: TextField(
            controller: messageController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Γράψτε το μήνυμά σας εδώ...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Άκυρο'),
            ),
            TextButton(
              onPressed: () {
                final messageText = messageController.text.trim();
                if (messageText.isNotEmpty) {
                  FirebaseFirestore.instance.collection('inbox').add({
                    'messageText': messageText,
                    'senderEmail': user.email,
                    'senderId': user.uid,
                    'timestamp': FieldValue.serverTimestamp(),
                    'isRead': false,
                  });
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Το μήνυμά σας στάλθηκε!'), backgroundColor: Colors.green),
                  );
                }
              },
              child: const Text('Αποστολή'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMemberProfile() {
    if (_memberData == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Card(
                color: Colors.amberAccent,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.info_outline, size: 40),
                      SizedBox(height: 10),
                      Text('Ο λογαριασμός σας δεν έχει ενεργοποιηθεί ακόμα.', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text('Παρακαλούμε επικοινωνήστε με το Dojo για να ολοκληρωθεί η εγγραφή σας ή πατήστε το παρακάτω κουμπί.', textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _showContactDialog,
                icon: const Icon(Icons.send_to_mobile),
                label: const Text('Επικοινωνία με το Dojo'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700, foregroundColor: Colors.white),
              ),
            ],
          ),
        ),
      );
    }
    
    final data = _memberData!.data() as Map<String, dynamic>;
    final String fullName = data['fullName'] ?? 'Άγνωστο Όνομα';
    final String rankType = data['rankType'] ?? 'Kyu';
    final int rankLevel = data['rankLevel'] as int? ?? 0;
    final String? photoBase64 = data['photoBase64'];

    ImageProvider<Object>? getProfileImage() {
      if (photoBase64 != null && photoBase64.isNotEmpty) {
        try {
          final Uint8List imageBytes = base64Decode(photoBase64);
          return MemoryImage(imageBytes);
        } catch (e) {
          debugPrint("Error decoding Base64 image: $e");
          return null;
        }
      }
      return null;
    }

    final bool isDanRank = rankType.toLowerCase().contains('dan');
    final String beltImage = isDanRank 
        ? 'assets/images/black_belt.png' 
        : 'assets/images/white_belt.png';

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 200,
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: const AssetImage('assets/images/techniques_background.png'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.white.withOpacity(0.2),
                    BlendMode.dstATop,
                  ),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                      radius: 62,
                      backgroundColor: Colors.black,
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey.shade300,
                        backgroundImage: getProfileImage(),
                        child: getProfileImage() == null 
                          ? const Icon(Icons.person, size: 60, color: Colors.white)
                          : null,
                      ),
                    ),
                    Positioned(
                      bottom: 2,
                      right: 2,
                      child: Material(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(16),
                        elevation: 2,
                        child: InkWell(
                          onTap: _isUploading ? null : _pickAndSaveImage,
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: _isUploading 
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Icon(Icons.edit, color: Colors.white, size: 18),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.badge_outlined, size: 30),
              title: const Text('Ονοματεπώνυμο', style: TextStyle(fontSize: 16)),
              subtitle: Text(fullName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Image.asset(beltImage, width: 30),
              title: const Text('Βαθμός', style: TextStyle(fontSize: 16)),
              subtitle: Text('$rankLevelº $rankType', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
              trailing: ElevatedButton.icon(
                icon: const Icon(Icons.history, size: 18),
                label: const Text('Ιστορικό'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2f2a2a),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => RankHistoryPage(memberId: _memberData!.id),
                  ));
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const ProgressPage()),
                  );
                },
                icon: Icon(Icons.trending_up, color: Colors.blue.shade700),
                label: Text(
                  'Η Πρόοδός μου',
                  style: TextStyle(color: Colors.grey.shade800, decoration: TextDecoration.underline),
                ),
                style: TextButton.styleFrom(
                  alignment: Alignment.centerLeft,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const NafudakakePage())),
              icon: const Icon(Icons.groups_2_outlined),
              label: const Text('Nafudakake'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFd2b48c), foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 12)),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => SubscriptionsHistoryPage(memberId: _memberData!.id))),
              icon: const Icon(Icons.history),
              label: const Text('Οι Συνδρομές μου'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
            ),
            const SizedBox(height: 8),
            StreamBuilder<QuerySnapshot>(
              stream: _memberData!.reference.collection('messages').where('isRead', isEqualTo: false).snapshots(),
              builder: (context, snapshot) {
                final unreadCount = snapshot.hasData ? snapshot.data!.docs.length : 0;
                return ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => MemberMessagesPage(memberId: _memberData!.id))),
                  icon: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(Icons.mark_email_unread_outlined),
                      if (unreadCount > 0) Positioned(top: -8, right: -12, child: CircleAvatar(radius: 10, backgroundColor: Colors.red, child: Text(unreadCount.toString(), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)))),
                    ],
                  ),
                  label: const Text('Μηνύματα από το Dojo'),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2f2a2a), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
                );
              },
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _showContactDialog,
              icon: const Icon(Icons.send_to_mobile),
              label: const Text('Επικοινωνία με το Dojo'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade800, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminProfile() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Chip(label: Text('ADMIN ACCESS', style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: Colors.amber, avatar: Icon(Icons.shield, color: Colors.black), padding: EdgeInsets.all(8)),
          const SizedBox(height: 16),
          Text(FirebaseAuth.instance.currentUser?.email ?? 'Admin', textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const FinancialSummaryPage()));
            },
            icon: const Icon(Icons.account_balance_wallet_outlined),
            label: const Text('Οικονομική Διαχείριση'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
          ),
          const SizedBox(height: 8),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('inbox').where('isRead', isEqualTo: false).snapshots(),
            builder: (context, snapshot) {
              final unreadCount = snapshot.hasData ? snapshot.data!.docs.length : 0;
              return ElevatedButton.icon(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const InboxPage())),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2f2a2a), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.inbox),
                    if (unreadCount > 0) Positioned(top: -8, right: -12, child: CircleAvatar(radius: 10, backgroundColor: Colors.red, child: Text(unreadCount.toString(), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)))),
                  ],
                ),
                label: const Text('Εισερχόμενα'),
              );
            },
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const MemberManagementPage())),
            icon: const Icon(Icons.group),
            label: const Text('Διαχείριση Μελών'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AnnouncementsManagementPage())),
            icon: const Icon(Icons.campaign_outlined),
            label: const Text('Διαχείριση Ανακοινώσεων'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade800, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          toolbarHeight: 45,
          title: const Text('Το Προφίλ μου'),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: TextButton(
                onPressed: _signOut,
                child: const Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadUserData,
                child: _isAdmin ? _buildAdminProfile() : _buildMemberProfile(),
              ),
      ),
    );
  }
}