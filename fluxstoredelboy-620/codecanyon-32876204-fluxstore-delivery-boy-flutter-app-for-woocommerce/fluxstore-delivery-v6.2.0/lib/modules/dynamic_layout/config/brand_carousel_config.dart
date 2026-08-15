/// Example Brand Carousel config
///
/// layout: 'brandCarousel',
/// name: 'Shop by Brand',
/// height: 140,
/// itemsPerView: 3,
/// autoPlay: true,
/// autoPlayDelay: 3500,
/// loop: true,
/// showName: true,
/// isLogoCornerRounded: true,
/// imageBoxFit: 'contain',
/// enableBackground: false,

class BrandCarouselConfig {
  String? layout;
  String? name;
  double height = 140;
  int itemsPerView = 3;
  bool autoPlay = true;
  int autoPlayDelay = 3500;
  bool loop = true;
  bool showName = true;
  bool isLogoCornerRounded = true;
  bool enableBackground = false;
  String? imageBoxFit;

  BrandCarouselConfig();

  BrandCarouselConfig.fromJson(dynamic json) {
    layout = json['layout'];
    name = json['name'];
    height = double.tryParse('${json['height']}') ?? 140;
    itemsPerView = int.tryParse('${json['itemsPerView']}') ?? 3;
    if (itemsPerView < 1) {
      itemsPerView = 1;
    }
    autoPlay = bool.tryParse('${json['autoPlay']}') ?? true;
    autoPlayDelay = int.tryParse('${json['autoPlayDelay']}') ?? 3500;
    loop = bool.tryParse('${json['loop']}') ?? true;
    showName = bool.tryParse('${json['showName']}') ?? true;
    isLogoCornerRounded =
        bool.tryParse('${json['isLogoCornerRounded']}') ?? true;
    enableBackground = bool.tryParse('${json['enableBackground']}') ?? false;
    imageBoxFit = json['imageBoxFit'];
  }

  Map<String, dynamic> toJson() {
    return {
      'layout': layout,
      'name': name,
      'height': height,
      'itemsPerView': itemsPerView,
      'autoPlay': autoPlay,
      'autoPlayDelay': autoPlayDelay,
      'loop': loop,
      'showName': showName,
      'isLogoCornerRounded': isLogoCornerRounded,
      'enableBackground': enableBackground,
      'imageBoxFit': imageBoxFit,
    };
  }
}
