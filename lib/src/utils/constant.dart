import 'package:flutter/material.dart';

class Resource {
  //Image Path
  static const String brandLogo = "assets/images/logo.png";
  static const String facebookIcon = "assets/images/brand/Facebook.png";
  static const String googleIcon = "assets/images/brand/Google.png";
  static const String instagramIcon = "assets/images/brand/Instagram.png";

  //styles
  static BorderRadius defaultBorderRadius = BorderRadius.circular(16);

  //Colors
  static const Color primaryColor = Color(0xFFE94057);
  static const Color primaryTintColor = Color(0x1AE94057);
  static const Color lightBackground = Colors.white;
  static const Color disabledColor = Color(0xFFE8E6EA);
  static const Color primaryTextColor = Color(0XFF323755);

  static const List<Map<String, String>> welcomeLeading = [
    {
      "Heading": "Thuật toán",
      "Content":
          "Người dùng trải qua quá trình kiểm tra để đảm bảo bạn không bao giờ khớp với máy.",
    },
    {
      "Heading": "Ghép đôi",
      "Content": "Chúng tôi kết hợp bạn với những người có thú cưng tương tự.",
    },
    {
      "Heading": "Premium",
      "Content":
          "Đăng ký ngay hôm nay và tận hưởng tháng đầu tiên ưu đãi cao cấp.",
    },
  ];
}
