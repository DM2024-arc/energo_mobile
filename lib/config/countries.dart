class Country {
  final String code;
  final String flag;
  final String name;
  const Country(this.code, this.flag, this.name);
}

const List<Country> kCountries = [
  Country('+242', '🇨🇬', 'Congo'),
  Country('+243', '🇨🇩', 'RD Congo'),
  Country('+237', '🇨🇲', 'Cameroun'),
  Country('+241', '🇬🇦', 'Gabon'),
  Country('+236', '🇨🇫', 'Centrafrique'),
  Country('+235', '🇹🇩', 'Tchad'),
  Country('+33',  '🇫🇷', 'France'),
];