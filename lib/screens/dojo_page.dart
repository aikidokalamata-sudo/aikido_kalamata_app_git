// lib/screens/dojo_page.dart

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DojoPage extends StatelessWidget {
  const DojoPage({super.key});

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!(await launchUrl(uri, mode: LaunchMode.externalApplication))) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Το Dojo μας'),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Image.asset('assets/images/aikido_logo.png', height: 120),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16.0, 0, 16.0, 24.0),
            child: Text(
              'Σύγχρονη προσέγγιση μιας πολεμικής τέχνης υψηλής αισθητικής και εκπληκτικής ισχύος!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            ),
          ),
          const Divider(indent: 16, endIndent: 16),

          _buildInfoTile(
            icon: Icons.location_on,
            title: 'Διεύθυνση',
            subtitle: 'Σανταρόζα 45, Καλαμάτα',
            onTap: () {
              const address = "Σανταρόζα 45, Καλαμάτα, Ελλάδα";
              final encodedAddress = Uri.encodeComponent(address);
              final url = 'https://www.google.com/maps/search/?api=1&query=$encodedAddress';
              _launchUrl(url);
            },
          ),
          _buildInfoTile(
            icon: Icons.phone,
            title: 'Τηλέφωνο',
            subtitle: '+30 698 301 4904',
            onTap: () => _launchUrl('tel:+306983014904'),
          ),
          _buildInfoTile(
            icon: Icons.email,
            title: 'Email',
            subtitle: 'aikidokalamata@gmail.com',
            onTap: () => _launchUrl('mailto:aikidokalamata@gmail.com'),
          ),
          _buildInfoTile(
            icon: Icons.language,
            title: 'Website',
            subtitle: 'aikidokalamata.gr',
            onTap: () => _launchUrl('https://www.aikidokalamata.gr'),
          ),
          
          const Divider(indent: 16, endIndent: 16),
          
          // --- Η ΚΑΡΤΑ NAFUDAKAKE ΕΧΕΙ ΑΦΑΙΡΕΘΕΙ ΑΠΟ ΕΔΩ ---
          
          _buildInfoTile(
            icon: Icons.facebook,
            title: 'Facebook',
            onTap: () => _launchUrl('https://www.facebook.com/aikidokalamata.gr'),
          ),
          _buildInfoTile(
            icon: Icons.camera_alt,
            title: 'Instagram',
            onTap: () => _launchUrl('https://www.instagram.com/aikidokalamata/'),
          ),
           _buildInfoTile(
            icon: Icons.video_library,
            title: 'YouTube',
            onTap: () => _launchUrl('https://www.youtube.com/@AikidoKalamataDojo'),
          ),
          _buildInfoTile(
            icon: Icons.music_note,
            title: 'TikTok',
            onTap: () => _launchUrl('https://www.tiktok.com/@aikido.kalamata'),
          ),
          _buildInfoTile(
            icon: Icons.article,
            title: 'Blog',
            onTap: () => _launchUrl('https://aikidokalamata.blogspot.com/'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({required IconData icon, required String title, String? subtitle, VoidCallback? onTap}) {
    return Card(
      elevation: 1.5,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: const Color(0xFFf7f2fa),
      child: ListTile(
        leading: Icon(icon, color: Colors.red.shade700, size: 30),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: subtitle != null ? Text(subtitle) : null,
        onTap: onTap,
        trailing: onTap != null ? const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey) : null,
      ),
    );
  }
}