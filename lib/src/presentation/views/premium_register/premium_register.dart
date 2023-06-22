import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:pet_match/src/domain/models/subscription_model.dart';
import 'package:pet_match/src/injection_container.dart';
import 'package:pet_match/src/presentation/widgets/button.dart';
import 'package:pet_match/src/presentation/widgets/rounded_back_button.dart';
import 'package:pet_match/src/utils/constant.dart';
import 'package:pet_match/src/utils/extensions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PremiumRegisterScreen extends StatefulWidget {
  const PremiumRegisterScreen({super.key});

  @override
  State<PremiumRegisterScreen> createState() => _PremiumRegisterScreenState();
}

class _PremiumRegisterScreenState extends State<PremiumRegisterScreen> {
  static const _blackText = TextStyle(
    color: Colors.black,
    height: 1.5,
  );
  static const _highlightText = TextStyle(
    color: Resource.primaryColor,
    fontWeight: FontWeight.bold,
  );

  late Subscription currentSubscription;

  @override
  void initState() {
    super.initState();
    final localStorage = sl<SharedPreferences>();
    currentSubscription =
        Subscription.fromJson(localStorage.getFromAuthStorage('subscription'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                RoundedBackButton(
                  onTap: () => Navigator.pop(context),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 20),
                  padding: const EdgeInsets.symmetric(
                    vertical: 40,
                    horizontal: 20,
                  ),
                  decoration: BoxDecoration(
                    color: Resource.lightBackground,
                    borderRadius: Resource.defaultBorderRadius,
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x12000000),
                        blurRadius: 50,
                        offset: Offset(0, 20),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'PREMIUM',
                        style: TextStyle(
                          color: Resource.primaryColor,
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 40),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const FaIcon(
                            FontAwesomeIcons.crown,
                            color: Color(0xFFE29033),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: RichText(
                              text: const TextSpan(
                                style: _blackText,
                                children: [
                                  TextSpan(text: 'Mở khóa chức năng '),
                                  TextSpan(
                                    text: 'xem bình luận ',
                                    style: TextStyle(
                                      color: Color(0xFFE29033),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(text: 'của người lạ')
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const FaIcon(
                            FontAwesomeIcons.crown,
                            color: Color(0xFFE29033),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: RichText(
                              text: const TextSpan(
                                style: _blackText,
                                children: [
                                  TextSpan(text: 'Mở khóa giới hạn '),
                                  TextSpan(
                                    text: 'tìm thông tin ',
                                    style: TextStyle(
                                      color: Color(0xFFE29033),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(text: 'thú cưng')
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const FaIcon(
                            FontAwesomeIcons.crown,
                            color: Color(0xFFE29033),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: RichText(
                              text: const TextSpan(
                                style: _blackText,
                                children: [
                                  TextSpan(
                                    text: 'Mở khóa chức năng ',
                                  ),
                                  TextSpan(
                                    text: 'xem ',
                                    style: TextStyle(
                                        color: Color(0xFFE29033),
                                        fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(
                                    text: 'những người đã thích mình',
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const FaIcon(
                            FontAwesomeIcons.crown,
                            color: Color(0xFFE29033),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: RichText(
                              text: const TextSpan(
                                style: _blackText,
                                children: [
                                  TextSpan(text: 'Mở khóa '),
                                  TextSpan(
                                    text: 'lịch sử ',
                                    style: TextStyle(
                                      color: Color(0xFFE29033),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(text: 'người đã lướt')
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const FaIcon(
                            FontAwesomeIcons.crown,
                            color: Color(0xFFE29033),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: RichText(
                              text: const TextSpan(
                                style: _blackText,
                                children: [
                                  TextSpan(text: 'Tăng mức độ '),
                                  TextSpan(
                                    text: 'hiển thị',
                                    style: TextStyle(
                                      color: Color(0xFFE29033),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(text: ' trang cá nhân'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const FaIcon(
                            FontAwesomeIcons.crown,
                            color: Color(0xFFE29033),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: RichText(
                              text: const TextSpan(
                                style: _blackText,
                                children: [
                                  TextSpan(text: 'Hiển thị đặc quyền '),
                                  TextSpan(
                                    text: 'VIP',
                                    style: TextStyle(
                                      color: Color(0xFFE29033),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      RichText(
                        text: const TextSpan(
                          style: TextStyle(color: Colors.black),
                          children: [
                            TextSpan(
                              text: '49,000 VNĐ',
                              style: TextStyle(
                                fontSize: 22,
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey,
                              ),
                            ),
                            TextSpan(text: "  "),
                            TextSpan(
                              text: 'Safe off',
                              style: TextStyle(
                                fontSize: 18,
                                color: Resource.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Text(
                        '29,000 VNĐ/tháng',
                        style: TextStyle(
                          fontSize: 28,
                          color: Resource.primaryColor,
                          fontWeight: FontWeight.bold,
                          decorationStyle: TextDecorationStyle.dashed,
                        ),
                      ),
                      Button(
                        variant: currentSubscription.isActive()
                            ? ButtonVariant.text
                            : ButtonVariant.primary,
                        padding: const EdgeInsets.only(top: 20),
                        label: !currentSubscription.isActive()
                            ? 'Đăng kí ngay'
                            : "Bạn đang sử dụng gói này\nHạn: ${DateFormat('dd/MM/yyyy').format(
                                currentSubscription.startFrom!.add(
                                  currentSubscription.duration!,
                                ),
                              )}",
                        color: currentSubscription.isActive()
                            ? Resource.primaryTintColor
                            : null,
                        textAlign: TextAlign.center,
                        style: currentSubscription.isActive()
                            ? const TextStyle(color: Resource.primaryTextColor)
                            : const TextStyle(color: Colors.white),
                        onTap: currentSubscription.isActive()
                            ? null
                            : () => {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      var momoPaymentImg =
                                          'https://firebasestorage.googleapis.com/v0/b/petmatch-6e802.appspot.com/o/payment_info.jpg?alt=media';
                                      return SimpleDialog(
                                        contentPadding:
                                            const EdgeInsets.all(20),
                                        children: [
                                          RichText(
                                            text: const TextSpan(
                                              children: [
                                                TextSpan(
                                                    text:
                                                        'Chuyển khoản vui lòng ghi '),
                                                TextSpan(
                                                    text:
                                                        'PetMatch <địa chỉ email>',
                                                    style: _highlightText),
                                                TextSpan(
                                                  text:
                                                      ' trong phần tin nhắn để hệ thống xử lý. Sau khi thanh toán vui lòng chờ 5 phút để hệ thống ghi nhận',
                                                ),
                                              ],
                                              style: _blackText,
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                          ClipRRect(
                                            borderRadius:
                                                Resource.defaultBorderRadius,
                                            clipBehavior: Clip.antiAlias,
                                            child: CachedNetworkImage(
                                              imageUrl: momoPaymentImg,
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  )
                                },
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
