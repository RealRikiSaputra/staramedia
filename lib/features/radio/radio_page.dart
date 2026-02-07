import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../data/services/api_service.dart';
import '../../data/services/channel.dart';
import 'radio_player_page.dart';

class RadioPage extends StatefulWidget {
  const RadioPage({super.key});

  @override
  State<RadioPage> createState() => _RadioPageState();
}

class _RadioPageState extends State<RadioPage> {
  List<Channel> _allRadio = [];
  List<Channel> _filteredRadio = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadRadio();
  }

  Future<void> _loadRadio() async {
    try {
      final data = await ApiService.fetchAllData();
      final radioMap = Map<String, dynamic>.from(data['radio']);

      final radioList = radioMap.values
          .map((e) => Channel.fromRadioJson(e))
          .toList();

      setState(() {
        _allRadio = radioList;
        _filteredRadio = radioList;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  void _searchRadio(String keyword) {
    final q = keyword.toLowerCase();
    setState(() {
      _filteredRadio = _allRadio.where((r) {
        return r.nama.toLowerCase().contains(q) ||
            r.kota.toLowerCase().contains(q);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Live Radio'),
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
              onChanged: _searchRadio,
              style: TextStyle(color: cs.onSurface),
              decoration: InputDecoration(
                hintText: 'Cari Radio (Bandung, Jakarta, dll)',
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

          // ================= LIST RADIO =================
          Expanded(
            child: _filteredRadio.isEmpty
                ? Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Text(
                'Radio tidak ditemukan',
                style: TextStyle(
                    color: cs.onSurfaceVariant),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredRadio.length,
              itemBuilder: (context, index) {
                final radio = _filteredRadio[index];

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
                          builder: (_) => RadioPlayerPage(channel: radio),
                        ),
                      );
                    },
                    child: Padding(
                      padding:
                      const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          // LOGO
                          CachedNetworkImage(
                            imageUrl: radio.logo,
                            width: 48,
                            height: 48,
                            fit: BoxFit.contain,
                            errorWidget:
                                (_, __, ___) =>
                            const Icon(
                                Icons.radio),
                          ),
                          const SizedBox(width: 14),

                          // INFO
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                              children: [
                                Text(
                                  radio.nama,
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
                                  '${radio.freq} • ${radio.kota}',
                                  style: theme
                                      .textTheme
                                      .bodySmall,
                                ),
                              ],
                            ),
                          ),

                          // ICON
                          Icon(
                            Icons.play_arrow_rounded,
                            color: cs.primary,
                            size: 28,
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
