import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/services/channel.dart';

class RadioPlayerPage extends StatefulWidget {
  final Channel channel;
  const RadioPlayerPage({super.key, required this.channel});

  @override
  State<RadioPlayerPage> createState() => _RadioPlayerPageState();
}

class _RadioPlayerPageState extends State<RadioPlayerPage> {
  final AudioPlayer _player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _player.setUrl(widget.channel.link);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  // ================= LOGO =================
  Widget _buildLogo(Channel ch) {
    if (ch.logo.trim().isEmpty) {
      return const Icon(Icons.radio, size: 120);
    }

    return CachedNetworkImage(
      imageUrl: ch.logo,
      width: 150,
      height: 150,
      fit: BoxFit.contain,
      placeholder: (_, __) =>
      const CircularProgressIndicator(strokeWidth: 2),
      errorWidget: (_, __, ___) =>
      const Icon(Icons.radio, size: 120),
    );
  }

  Future<void> _openWebsite(String url) async {
    if (url.isEmpty) return;
    await launchUrl(Uri.parse(url),
        mode: LaunchMode.externalApplication);
  }

  Future<void> _openWhatsApp(String phone) async {
    if (phone.isEmpty) return;
    final clean = phone.replaceAll(RegExp(r'[^0-9]'), '');
    await launchUrl(
      Uri.parse('https://wa.me/$clean'),
      mode: LaunchMode.externalApplication,
    );
  }

  // ================= PLAYER BUTTON =================
  Widget _buildPlayButton(Color color) {
    return StreamBuilder<PlayerState>(
      stream: _player.playerStateStream,
      builder: (context, snapshot) {
        final state = snapshot.data;
        final processingState = state?.processingState;
        final playing = state?.playing ?? false;

        // BUFFERING / LOADING
        if (processingState == ProcessingState.loading ||
            processingState == ProcessingState.buffering) {
          return const SizedBox(
            width: 72,
            height: 72,
            child: CircularProgressIndicator(strokeWidth: 3),
          );
        }

        // PLAY
        if (!playing) {
          return IconButton(
            iconSize: 80,
            icon: Icon(Icons.play_circle_fill, color: color),
            onPressed: _player.play,
          );
        }

        // PAUSE
        return IconButton(
          iconSize: 80,
          icon: Icon(Icons.pause_circle_filled, color: color),
          onPressed: _player.pause,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final ch = widget.channel;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Radio Player'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // LOGO
            _buildLogo(ch),

            const SizedBox(height: 24),

            // INFO
            Text(
              ch.nama,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              '${ch.freq} • ${ch.kota}',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: cs.onSurfaceVariant),
            ),

            const SizedBox(height: 36),

            // ================= PLAY BUTTON =================
            _buildPlayButton(cs.primary),

            const SizedBox(height: 40),

            // ================= ACTIONS =================
            if (ch.request.isNotEmpty || ch.website.isNotEmpty)
              Column(
                children: [
                  if (ch.request.isNotEmpty)
                    _actionButton(
                      icon: Icons.chat,
                      label: 'Request Lagu (WhatsApp)',
                      color: Colors.green,
                      onTap: () => _openWhatsApp(ch.request),
                    ),
                  if (ch.website.isNotEmpty)
                    _actionButton(
                      icon: Icons.language,
                      label: 'Lihat Website',
                      color: cs.primary,
                      onTap: () => _openWebsite(ch.website),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          icon: Icon(icon, color: color),
          label: Text(label),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            side: BorderSide(color: color.withOpacity(0.4)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          onPressed: onTap,
        ),
      ),
    );
  }
}
