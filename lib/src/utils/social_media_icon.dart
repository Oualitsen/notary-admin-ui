import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SocialMediaIcon {
  static List<SocialMediaIcon> socialMediaIcons = [
    SocialMediaIcon("FaceBook", FontAwesomeIcons.facebook),
    SocialMediaIcon("Instagram", FontAwesomeIcons.instagram),
    SocialMediaIcon("Whatsapp", FontAwesomeIcons.whatsapp),
    SocialMediaIcon("Linkedin", FontAwesomeIcons.linkedin),
    SocialMediaIcon("Youtube", FontAwesomeIcons.youtube),
    SocialMediaIcon("Twitter", FontAwesomeIcons.twitter),
    SocialMediaIcon("Viber", FontAwesomeIcons.viber),
    SocialMediaIcon("Telegram", FontAwesomeIcons.telegram),
    SocialMediaIcon("Signal", FontAwesomeIcons.signal),
    SocialMediaIcon("Tiktok", FontAwesomeIcons.tiktok),
    SocialMediaIcon("Snapchat", FontAwesomeIcons.snapchat),
    SocialMediaIcon("Pinterest", FontAwesomeIcons.pinterest),
    SocialMediaIcon("Reddit", FontAwesomeIcons.reddit),
    SocialMediaIcon("Skype", FontAwesomeIcons.skype),
    SocialMediaIcon("Other", Icons.fiber_manual_record_outlined),
  ];

  final String name;
  final IconData iconData;

  SocialMediaIcon(this.name, this.iconData);

  static SocialMediaIcon findByName(String name) {
    var _name = name.toLowerCase();
    return socialMediaIcons.firstWhere(
        (element) => element.name.toLowerCase() == _name,
        orElse: () => socialMediaIcons.last);
  }
}
