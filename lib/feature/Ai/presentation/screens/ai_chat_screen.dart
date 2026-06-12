import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/common/constants/app_images.dart';
import '../../../../core/common/widgets/app_scaffold.dart';
import '../../../../core/common/widgets/login_required_dialog.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/controller/auth_flow_controller.dart';
import '../controllers/ai_chat_controller.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_input_bar.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  late final AuthFlowController _flowController;
  AiChatController? _controller;
  bool _didSendLocationPrompt = false;

  @override
  void initState() {
    super.initState();
    _flowController = ensureAuthFlowController();
  }

  AiChatController _ensureAiController() {
    final AiChatController controller =
        _controller ?? AiChatController.ensureInitialized();
    _controller = controller;
    if (!_didSendLocationPrompt) {
      _didSendLocationPrompt = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.sendLocationPromptOnce();
      });
    }
    return controller;
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: isDark
          ? BoxDecoration(color: AppColors.darkBackground)
          : BoxDecoration(
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
        body: Obx(() {
          if (_flowController.isGuestMode.value) {
            return const GuestLoginRequiredView(
              message: 'Please log in to use AI Chat features.',
            );
          }

          final AiChatController controller = _ensureAiController();
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                child: Row(
                  children: [
                    Image.asset(
                      AppImages.appLogo,
                      width: 40,
                      height: 40,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      'AI Chat',
                      style: TextStyle(
                        color: AppColors.primaryText(context),
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ],
                ),
              ),
              Text(
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
                  if (controller.messages.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          'Ask anything and get recommendations instantly.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.secondaryText(context),
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
                    itemCount: controller.messages.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final message = controller.messages[index];
                      return ChatBubble(
                        message: message,
                        userAvatarUrl: controller.userAvatarUrl.value,
                      );
                    },
                  );
                }),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                child: Obx(
                  () => ChatInputBar(
                    controller: controller.messageController,
                    onSend: () => controller.sendMessage(),
                    isSending: controller.isSending.value,
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
