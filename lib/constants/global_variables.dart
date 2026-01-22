import 'package:flutter/material.dart';

//String uri = 'http://localhost:3000';

class GlobalVariables {
  // COLORS
  static const appBarGradient = LinearGradient(
    colors: [
      Color.fromARGB(255, 20, 91, 197),
      Color.fromARGB(255, 0, 32, 31),
    ],
    stops: [0.5, 1.0],
  );

  // Azul principal Apple-style
  static const primaryColor = Color.fromARGB(255, 10, 132, 255); // #0A84FF
  static const secondaryColor = Color.fromARGB(255, 0, 0, 0); // #000000
  static const meBackgroundColor = Color.fromARGB(255, 242, 242, 247); // #F2F2F7
  static const Color greyBackgroundCOlor = Color.fromARGB(255, 255, 255, 255); // #1C1C1E
  static var selectedNavBarColor = Color.fromARGB(255, 10, 132, 255); // #0A84FF
  static const unselectedNavBarColor = Color.fromRGBO(247, 247, 247, 1); // rgba(...)


  





  // STATIC IMAGES
  static const List<String> carouselImages = [
    'https://images-eu.ssl-images-amazon.com/images/G/31/img21/Wireless/WLA/TS/D37847648_Accessories_savingdays_Jan22_Cat_PC_1500.jpg',
    'https://images-eu.ssl-images-amazon.com/images/G/31/img2021/Vday/bwl/English.jpg',
    'https://images-eu.ssl-images-amazon.com/images/G/31/img22/Wireless/AdvantagePrime/BAU/14thJan/D37196025_IN_WL_AdvantageJustforPrime_Jan_Mob_ingress-banner_1242x450.jpg',
    'https://images-na.ssl-images-amazon.com/images/G/31/Symbol/2020/00NEW/1242_450Banners/PL31_copy._CB432483346_.jpg',
    'https://images-na.ssl-images-amazon.com/images/G/31/img21/shoes/September/SSW/pc-header._CB641971330_.jpg',
  ];

  static const List<Map<String, String>> categoryImages = [
    {
      'title': 'Mobiles',
      'image': 'assets/images/mobiles.jpeg',
    },
    {
      'title': 'Essentials',
      'image': 'assets/images/essentials.jpeg',
    },
    {
      'title': 'Appliances',
      'image': 'assets/images/appliances.jpeg',
    },
    {
      'title': 'Books',
      'image': 'assets/images/books.jpeg',
    },
    {
      'title': 'Fashion',
      'image': 'assets/images/fashion.jpeg',
    },
  ];

  static const darkMapStyle = '''
[
  {
    "featureType": "all",
    "elementType": "geometry",
    "stylers": [
      {"color": "#131a24"}
    ]
  },
  {
    "featureType": "all",
    "elementType": "labels.text.fill",
    "stylers": [
      {"gamma": 0.01},
      {"lightness": 20},
      {"weight": "1.39"},
      {"color": "#ffffff"}
    ]
  },
  {
    "featureType": "all",
    "elementType": "labels.text.stroke",
    "stylers": [
      {"weight": "0.96"},
      {"saturation": "9"},
      {"visibility": "on"},
      {"color": "#000000"}
    ]
  },
  {
    "featureType": "all",
    "elementType": "labels.icon",
    "stylers": [
      {"visibility": "on"}
    ]
  },
  {
    "featureType": "landscape",
    "elementType": "geometry",
    "stylers": [
      {"lightness": 30},
      {"saturation": "9"},
      {"color": "#29446b"}
    ]
  },
  {
    "featureType": "poi",
    "elementType": "geometry",
    "stylers": [
      {"saturation": 20}
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [
      {"lightness": 20},
      {"saturation": -20}
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [
      {"lightness": 10},
      {"saturation": -30}
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry.fill",
    "stylers": [
      {"color": "#193a55"}
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry.stroke",
    "stylers": [
      {"saturation": 25},
      {"lightness": 25},
      {"weight": "0.01"}
    ]
  },
  {
    "featureType": "water",
    "elementType": "all",
    "stylers": [
      {"lightness": -20}
    ]
  }
]
''';

}
