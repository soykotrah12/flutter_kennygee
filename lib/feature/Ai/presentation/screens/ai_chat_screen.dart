import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/common/constants/app_images.dart';
import '../../../../core/common/widgets/app_scaffold.dart';
import '../../../../core/theme/app_colors.dart';
import '../controllers/ai_chat_controller.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_input_bar.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  late final AiChatController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AiChatController.ensureInitialized();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.sendLocationPromptOnce();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(AppImages.rolebackground),
          fit: BoxFit.cover,
        ),
      ),
      child: AppScaffold(
        useSafeArea: true,
        isScrollable: false,
        backgroundColor: Colors.transparent,
        bodyPadding: const EdgeInsets.fromLTRB(4, 36, 4, 8),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
              child: Row(
                children: [
                  // Image.asset(
                  //   AppImages.appLogo,
                  //   width: 22,
                  //   height: 36,
                  //   fit: BoxFit.contain,
                  // ),
                  Image.asset(
                    AppImages.appLogo,
                    width: 40,
                    height: 40,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 7),
                  const Text(
                    'AI Chat',
                    style: TextStyle(
                      color: AppColors.textBlack,
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ],
              ),
            ),
            const Text(
              '09:41 AM',
              style: TextStyle(
                color: Color(0xFFB8BDC1),
                fontSize: 10,
                fontWeight: FontWeight.w500,
                fontFamily: 'Montserrat',
              ),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: Obx(() {
                if (_controller.messages.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'Ask anything and get recommendations instantly.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                  itemCount: _controller.messages.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final message = _controller.messages[index];
                    return ChatBubble(
                      message: message,
                      userAvatarUrl: _controller.userAvatarUrl.value,
                    );
                  },
                );
              }),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: Obx(
                () => ChatInputBar(
                  controller: _controller.messageController,
                  onSend: () => _controller.sendMessage(),
                  isSending: _controller.isSending.value,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
