enum ChannelType { tv, radio }

class Channel {
  final ChannelType type;

  // common
  final String nama;
  final String kota;
  final String link;
  final String logo;
  final String website;

  // tv only
  final String keterangan;
  final String req;
  final String konsul;
  final Map<String, dynamic>? marketplace;

  // radio only
  final String freq;
  final String request;

  Channel({
    required this.type,
    required this.nama,
    required this.kota,
    required this.link,
    required this.logo,
    required this.website,
    this.keterangan = '',
    this.req = '',
    this.konsul = '',
    this.marketplace,
    this.freq = '',
    this.request = '',
  });

  /// =========================
  /// FACTORY: TV
  /// =========================
  factory Channel.fromTvJson(Map<String, dynamic> json) {
    return Channel(
      type: ChannelType.tv,
      nama: json['nama'] ?? '',
      kota: json['kota'] ?? '',
      link: json['link'] ?? '',
      logo: json['logo'] ?? '',
      website: json['website'] ?? '',
      keterangan: json['keterangan'] ?? '',
      req: json['req'] ?? '',
      konsul: json['konsul'] ?? '',
      marketplace: json['marketplace'] != null
          ? Map<String, dynamic>.from(json['marketplace'])
          : null,
    );
  }

  /// =========================
  /// FACTORY: RADIO
  /// =========================
  factory Channel.fromRadioJson(Map<String, dynamic> json) {
    return Channel(
      type: ChannelType.radio,
      nama: json['radio'] ?? '',
      kota: json['kota'] ?? '',
      link: json['link'] ?? '',
      logo: json['logo'] ?? '',
      website: json['website'] ?? '',
      freq: json['freq'] ?? '',
      request: json['request'] ?? '',
    );
  }
}
