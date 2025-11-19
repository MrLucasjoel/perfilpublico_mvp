import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  // IMPORTANTE: Substitua estes IDs pelos seus Ad Unit IDs reais do Google AdMob
  // Para conseguir seus IDs:
  // 1. Acesse https://admob.google.com
  // 2. Vá em "Apps" → "Perfil Publico" → "Ad units"
  // 3. Crie ad units ou copie os IDs existentes (formato: ca-app-pub-XXXXX/YYYYY)
  
  // Test IDs do Google (use para debug - funcionam sem restrições):
  static const String bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111'; // Banner test ID
  static const String interstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712'; // Interstitial test ID
  static const String rewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917'; // Rewarded test ID

  // TODO: Quando tiver Ad Unit IDs reais, substitua acima pelos seus IDs:
  // Banner: ca-app-pub-4020081539035484/XXXXXXXXXX
  // Interstitial: ca-app-pub-4020081539035484/YYYYYYYYYY
  // Rewarded: ca-app-pub-4020081539035484/ZZZZZZZZZZ

  static final AdService _instance = AdService._internal();

  factory AdService() {
    return _instance;
  }

  AdService._internal();

  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;

  Future<void> initializeAds() async {
    // Inicializa Google Mobile Ads SDK
    await MobileAds.instance.initialize();
    print('Google Mobile Ads SDK initialized');
  }

  // Carrega um Banner Ad
  BannerAd loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          print('✓ Banner ad loaded successfully');
        },
        onAdFailedToLoad: (ad, error) {
          print('✗ Banner ad failed to load: $error');
          ad.dispose();
        },
        onAdOpened: (ad) {
          print('Banner ad opened');
        },
        onAdClosed: (ad) {
          print('Banner ad closed');
        },
      ),
    );
    _bannerAd?.load();
    return _bannerAd!;
  }

  // Carrega um Interstitial Ad (pop-up)
  Future<void> loadInterstitialAd() async {
    await InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          print('✓ Interstitial ad loaded successfully');
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('✗ Interstitial ad failed to load: $error');
        },
      ),
    );
  }

  // Mostra o Interstitial Ad
  void showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _interstitialAd = null;
          loadInterstitialAd(); // Carrega novo ad após fechar
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          print('Interstitial failed to show: $error');
          ad.dispose();
          _interstitialAd = null;
        },
      );
      _interstitialAd!.show();
    } else {
      print('Interstitial ad not loaded yet');
    }
  }

  void disposeBannerAd() {
    _bannerAd?.dispose();
  }

  void disposeInterstitialAd() {
    _interstitialAd?.dispose();
  }
}
