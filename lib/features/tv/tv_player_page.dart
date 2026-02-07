import 'package:flutter/material.dart';
import 'package:better_player/better_player.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../data/services/channel.dart';

class ChannelPlayerScreen extends StatefulWidget {
  final Channel channel;
  const ChannelPlayerScreen({super.key, required this.channel});

  @override
  State<ChannelPlayerScreen> createState() => _ChannelPlayerScreenState();
}

class _ChannelPlayerScreenState extends State<ChannelPlayerScreen> {
  BetterPlayerController? _controller;
  final GlobalKey _playerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  void _initPlayer() {
    final dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      widget.channel.link,
      liveStream: true,
      useAsmsTracks: true,
      useAsmsSubtitles: true,
      useAsmsAudioTracks: true,
    );

    _controller = BetterPlayerController(
      BetterPlayerConfiguration(
        autoPlay: true,
        looping: true,
        fit: BoxFit.contain,
        allowedScreenSleep: false,
        controlsConfiguration: const BetterPlayerControlsConfiguration(
          enableFullscreen: true,
          enablePlayPause: true,
          enableMute: true,
          enableProgressText: true,
          enableQualities: true,
          enableAudioTracks: true,
          enableSubtitles: true,
          enablePip: true,
          liveTextColor: Colors.red,
        ),
      ),
      betterPlayerDataSource: dataSource,
    );
  }

  void _reloadStream() {
    _controller?.setupDataSource(
      BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        widget.channel.link,
        liveStream: true,
      ),
    );
  }

  void _enterPip() async {
    if (await _controller?.isPictureInPictureSupported() ?? false) {
      _controller?.enablePictureInPicture(_playerKey);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Perangkat tidak mendukung PiP")),
      );
    }
  }

  Future<void> _openUrl(String url) async {
    if (url.isEmpty) return;
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ch = widget.channel;

    return Scaffold(
      appBar: AppBar(
        title: Text("${ch.nama} - ${ch.kota}"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_in_picture),
            onPressed: _enterPip,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _reloadStream,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ================= PLAYER =================
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: _controller != null
                      ? BetterPlayer(
                    key: _playerKey,
                    controller: _controller!,
                  )
                      : const Center(child: CircularProgressIndicator()),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ================= INFO CARD =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      if (ch.logo.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            ch.logo,
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                            const Icon(Icons.tv, size: 48),
                          ),
                        ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          "${ch.nama}\n${ch.kota}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            if (ch.keterangan.isNotEmpty) ...[
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  ch.keterangan,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15),
                ),
              ),
            ],

            const SizedBox(height: 20),

            // ================= ACTION BUTTONS =================
            if (ch.req.isNotEmpty)
              _actionTile(
                icon: FontAwesomeIcons.music,
                color: Colors.blue,
                title: "Request Lagu",
                url:
                "https://wa.me/${ch.req.replaceAll(RegExp(r'[^0-9]'), '')}",
              ),

            if (ch.konsul.isNotEmpty)
              _actionTile(
                icon: FontAwesomeIcons.whatsapp,
                color: const Color(0xFF25D366),
                title: "Konsultasi",
                url:
                "https://wa.me/${ch.konsul.replaceAll(RegExp(r'[^0-9]'), '')}",
              ),

            // ================= MARKETPLACE =================
            if (ch.marketplace != null && ch.marketplace!.isNotEmpty) ...[
              const SizedBox(height: 28),
              const Center(
                child: Text(
                  "Order Produk di Marketplace",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              for (final entry in ch.marketplace!.entries)
                _marketplaceTile(entry.key, entry.value),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ================= UI HELPERS =================

  Widget _actionTile({
    required IconData icon,
    required Color color,
    required String title,
    required String url,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          leading: FaIcon(icon, color: color, size: 24),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _openUrl(url),
        ),
      ),
    );
  }

  Widget _marketplaceTile(String key, Map data) {
    String url = data['url'] ?? '';
    if (key.toLowerCase() == 'wa' && !url.startsWith('http')) {
      url = "https://wa.me/${url.replaceAll(RegExp(r'[^0-9]'), '')}";
    }

    return _actionTile(
      icon: _marketplaceIcon(key),
      color: _marketplaceColor(key),
      title: data['label'] ?? key,
      url: url,
    );
  }

  IconData _marketplaceIcon(String key) {
    switch (key.toLowerCase()) {
      case 'shopee':
        return FontAwesomeIcons.bagShopping;
      case 'lazada':
        return FontAwesomeIcons.cartShopping;
      case 'tiktok':
        return FontAwesomeIcons.tiktok;
      case 'wa':
      case 'whatsapp':
        return FontAwesomeIcons.whatsapp;
      default:
        return FontAwesomeIcons.store;
    }
  }

  Color _marketplaceColor(String key) {
    switch (key.toLowerCase()) {
      case 'shopee':
        return const Color(0xFFFF5722);
      case 'lazada':
        return const Color(0xFF5A00D6);
      case 'tiktok':
        return Colors.black;
      case 'wa':
      case 'whatsapp':
        return const Color(0xFF25D366);
      default:
        return Colors.deepPurple;
    }
  }
}
