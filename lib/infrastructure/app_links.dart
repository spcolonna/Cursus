/// Páginas legales (carpeta site/, publicada en GitHub Pages u otro host).
/// La base se puede cambiar al compilar:
/// `--dart-define=LEGAL_BASE_URL=https://tu-dominio/cursus`
const kLegalBaseUrl = String.fromEnvironment(
  'LEGAL_BASE_URL',
  defaultValue: 'https://spcolonna.github.io/cursus',
);

Uri privacyPolicyUrl(String lang) =>
    Uri.parse('$kLegalBaseUrl/${lang == 'es' ? 'privacy' : 'privacy-en'}.html');

Uri termsUrl(String lang) =>
    Uri.parse('$kLegalBaseUrl/${lang == 'es' ? 'terms' : 'terms-en'}.html');
