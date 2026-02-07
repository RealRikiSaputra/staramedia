import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../data/services/api_service.dart';
import '../../data/services/channel.dart';
import 'tv_player_page.dart';

class TvPage extends StatefulWidget {
  const TvPage({super.key});

  @override
  State<TvPage> createState() => _TvPageState();
}

class _TvPageState extends State<TvPage> {
  List<Channel> _allTv = [];
  List<Channel> _filteredTv = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTv();
  }

  Future<void> _loadTv() async {
    try {
      final data = await ApiService.fetchAllData();
      final tvMap = Map<String, dynamic>.from(data['tv']);

      final tvList =
      tvMap.values.map((e) => Channel.fromTvJson(e)).toList();

      setState(() {
        _allTv = tvList;
        _filteredTv = tvList;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  void _searchTv(String keyword) {
    final q = keyword.toLowerCase();
    setState(() {
      _filteredTv = _allTv.where((tv) {
        return tv.nama.toLowerCase().contains(q) ||
            tv.kota.toLowerCase().contains(q);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Live TV'),
      //   centerTitle: true,
      // ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // ================= SEARCH =================
          Padding(
            padding:
            const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              onChanged: _searchTv,
              style: TextStyle(color: cs.onSurface),
              decoration: InputDecoration(
                hintText: 'Cari TV (Bandung, Jakarta, dll)',
                prefixIcon:
                Icon(Icons.search, color: cs.primary),
                filled: true,
                fillColor: cs.surfaceVariant,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // ================= LIST =================
          Expanded(
            child: _filteredTv.isEmpty
                ? Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Text(
                'TV tidak ditemukan',
                style:
                TextStyle(color: cs.onSurfaceVariant),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredTv.length,
              itemBuilder: (context, index) {
                final tv = _filteredTv[index];

                return Card(
                  margin:
                  const EdgeInsets.only(bottom: 10),
                  elevation: 0,
                  color: cs.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(14),
                    side: BorderSide(
                      color: cs.outlineVariant,
                    ),
                  ),
                  child: InkWell(
                    borderRadius:
                    BorderRadius.circular(14),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ChannelPlayerScreen(
                                channel: tv,
                              ),
                        ),
                      );
                    },
                    child: Padding(
                      padding:
                      const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          CachedNetworkImage(
                            imageUrl: tv.logo,
                            width: 48,
                            height: 48,
                            fit: BoxFit.contain,
                            errorWidget:
                                (_, __, ___) =>
                            const Icon(Icons.tv),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tv.nama,
                                  maxLines: 2,
                                  overflow:
                                  TextOverflow.ellipsis,
                                  style: theme
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                    fontWeight:
                                    FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  tv.kota,
                                  style: theme
                                      .textTheme
                                      .bodySmall,
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.play_arrow_rounded,
                            color: cs.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
