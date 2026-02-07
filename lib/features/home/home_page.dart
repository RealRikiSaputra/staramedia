import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../data/services/api_service.dart';
import '../../data/services/channel.dart';
import '../tv/tv_player_page.dart';
import '../tv/tv_page.dart';
import '../radio/radio_page.dart';
import '../radio/radio_player_page.dart';
import '../program/program_page.dart';
import '../profile/profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Stara Media Group',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),

      // ================= BODY =================
      body: _buildBody(),

      // ================= BOTTOM NAV =================
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: theme.colorScheme.onSurfaceVariant,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.tv), label: 'TV'),
          BottomNavigationBarItem(icon: Icon(Icons.radio), label: 'Radio'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month), label: 'Program'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  // ================= SWITCH BODY =================
  Widget _buildBody() {
    switch (_currentIndex) {
      case 1:
        return const TvPage();
      case 2:
        return const RadioPage();
      case 3:
        return const ProgramPage(); // 🔥
      case 4:
        return const ProfilePage(); // 🔥
      default:
        return _homeContent();
    }
  }

  // ================= HOME CONTENT =================
  Widget _homeContent() {
    return FutureBuilder<Map<String, dynamic>>(
      future: ApiService.fetchAllData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              snapshot.error.toString(),
              textAlign: TextAlign.center,
            ),
          );
        }

        final data = snapshot.data!;

        final tvChannels = data['tv']
            .values
            .map<Channel>((e) => Channel.fromTvJson(e))
            .toList();

        final radioChannels = data['radio']
            .values
            .map<Channel>((e) => Channel.fromRadioJson(e))
            .toList();

        // ====== HOME LIMIT ======
        final popularTv = tvChannels.take(5).toList();
        final previewTv = tvChannels.take(4).toList();
        final previewRadio = radioChannels.take(4).toList();

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            _sectionTitle('Popular'),
            const SizedBox(height: 12),
            _popularList(popularTv),

            const SizedBox(height: 28),
            _sectionHeader(
              title: 'Live TV',
              onTap: () => setState(() => _currentIndex = 1),
            ),
            const SizedBox(height: 12),
            _tvList(previewTv),

            const SizedBox(height: 28),
            _sectionHeader(
              title: 'Live Radio',
              onTap: () => setState(() => _currentIndex = 2),
            ),
            const SizedBox(height: 12),
            _radioList(previewRadio),
          ],
        );
      },
    );
  }

  // ================= UI HELPERS =================

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _sectionHeader({
    required String title,
    required VoidCallback onTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _sectionTitle(title),
        TextButton(
          onPressed: onTap,
          child: const Text('Lihat Semua'),
        ),
      ],
    );
  }

  // ================= POPULAR TV =================
  Widget _popularList(List<Channel> list) {
    final cs = Theme.of(context).colorScheme;

    return SizedBox(
      height: 190,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: list.length,
        itemBuilder: (context, index) {
          final ch = list[index];

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChannelPlayerScreen(channel: ch),
                ),
              );
            },
            child: Container(
              width: 260,
              margin: const EdgeInsets.only(right: 14),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: cs.outlineVariant),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CachedNetworkImage(
                    imageUrl: ch.logo,
                    height: 52,
                    fit: BoxFit.contain,
                    errorWidget: (_, __, ___) =>
                    const Icon(Icons.tv, size: 42),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    ch.nama,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    ch.kota,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ================= TV PREVIEW =================
  Widget _tvList(List<Channel> list) {
    final cs = Theme.of(context).colorScheme;

    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: list.length,
        itemBuilder: (context, index) {
          final ch = list[index];

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChannelPlayerScreen(channel: ch),
                ),
              );
            },
            child: Container(
              width: 160,
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cs.surfaceVariant,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CachedNetworkImage(
                    imageUrl: ch.logo,
                    height: 40,
                    fit: BoxFit.contain,
                    errorWidget: (_, __, ___) =>
                    const Icon(Icons.tv),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    ch.nama,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(fontSize: 12),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ================= RADIO PREVIEW (FIXED) =================
  Widget _radioList(List<Channel> list) {
    final cs = Theme.of(context).colorScheme;

    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: list.length,
        itemBuilder: (context, index) {
          final ch = list[index];

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RadioPlayerPage(channel: ch),
                ),
              );
            },
            child: Container(
              width: 160,
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cs.surfaceVariant,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CachedNetworkImage(
                    imageUrl: ch.logo,
                    height: 36,
                    fit: BoxFit.contain,
                    errorWidget: (_, __, ___) =>
                    const Icon(Icons.radio),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    ch.nama,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(fontSize: 12),
                  ),
                  Text(
                    ch.freq,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
