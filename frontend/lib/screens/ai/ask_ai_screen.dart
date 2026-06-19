import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../theme/app_styles.dart';

class AskAiScreen extends StatefulWidget {
  final VoidCallback? onOpenQuietRoute;

  const AskAiScreen({super.key, this.onOpenQuietRoute});

  @override
  State<AskAiScreen> createState() => _AskAiScreenState();
}

class _AskAiScreenState extends State<AskAiScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<_ChatMessage> _messages = [];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _controller.text.trim();

    if (text.isEmpty) {
      return;
    }

    setState(() {
      _messages.add(_ChatMessage.user(text));
      _messages.add(
        _ChatMessage.assistant('quiet_route_to_library'),
      );
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.Background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
          
            const SizedBox(height: 30),
            Text(
              'Ask AI Assistant',
              style: AppTextStyles.Heading2.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.Primary,
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _ExplainButton(onTap: () {}),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  const _AssistantIntroCard(),
                  const SizedBox(height: 16),
                  for (final message in _messages) ...[
                    message.isUser
                        ? _UserBubble(text: message.text)
                        : _AssistantResponseCard(
                            text: message.text,
                            onGo: widget.onOpenQuietRoute,
                          ),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
            ),
            _InputBar(
              controller: _controller,
              onSend: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;

  const _ChatMessage._({
    required this.text,
    required this.isUser,
  });

  factory _ChatMessage.user(String text) {
    return _ChatMessage._(text: text, isUser: true);
  }

  factory _ChatMessage.assistant(String text) {
    return _ChatMessage._(text: text, isUser: false);
  }
}


class _ExplainButton extends StatelessWidget {
  final VoidCallback onTap;

  const _ExplainButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Explain out loud',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          height: 56,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.White,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.PrimaryLighter, width: 1.4),
            boxShadow: const [
              BoxShadow(
                color: Color(0x26000000),
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Explain out loud',
                style: AppTextStyles.Body.copyWith(
                  color: AppColors.Primary,
                  height: 1,
                ),
              ),
              const SizedBox(width: 8),
              SvgPicture.asset(
                'assets/icons/volume_black.svg',
                width: 22,
                height: 22,
                fit: BoxFit.contain,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AssistantIntroCard extends StatelessWidget {
  const _AssistantIntroCard();

  @override
  Widget build(BuildContext context) {
    return _AiGradientCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.asset(
                'assets/icons/quick_phrases.svg',
                width: 24,
                height: 24,
                fit: BoxFit.contain,
                colorFilter: const ColorFilter.mode(
                  AppColors.Primary,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Hello, Francisco Soares',
                  style: AppTextStyles.BodyBold.copyWith(
                    color: AppColors.Primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'I’m here to help you navigate spaces with confidence!',
            style: AppTextStyles.Body.copyWith(
              color: AppColors.Primary,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Ask me anything about accessibility—I’ll tailor insights to your needs, highlight potential barriers, and suggest the best routes.',
            style: AppTextStyles.Body.copyWith(
              color: AppColors.Primary,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}

class _AssistantResponseCard extends StatelessWidget {
  final String text;
  final VoidCallback? onGo;

  const _AssistantResponseCard({required this.text, this.onGo});

  @override
  Widget build(BuildContext context) {
    return _AiGradientCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.asset(
                'assets/icons/quick_phrases.svg',
                width: 24,
                height: 24,
                fit: BoxFit.contain,
                colorFilter: const ColorFilter.mode(
                  AppColors.Primary,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Quiet Route to the Library',
                  style: AppTextStyles.BodyBold.copyWith(
                    color: AppColors.Primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Based on your current location on campus, i’ve found a route with lesser noise to Iscte–IUL’s Library.\n\nPress “Go” to start navigating.',
            style: AppTextStyles.Body.copyWith(
              color: AppColors.Primary,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 16),
          _RouteSuggestionBox(onGo: onGo),
        ],
      ),
    );
  }
}

class _RouteSuggestionBox extends StatelessWidget {
  final VoidCallback? onGo;

  const _RouteSuggestionBox({this.onGo});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.White,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.Accent, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '5 minutes  •  Arrive by 15:45',
            style: AppTextStyles.BodyBold.copyWith(color: AppColors.Primary),
          ),
          const SizedBox(height: 8),
          Text(
            '290 m  •  1 Elevator Ride',
            style: AppTextStyles.Body.copyWith(color: AppColors.Primary),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(child: _RouteSecondaryButton()),
              const SizedBox(width: 16),
              _RouteGoButton(onTap: onGo),
            ],
          ),
        ],
      ),
    );
  }
}

class _RouteSecondaryButton extends StatelessWidget {
  const _RouteSecondaryButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.White,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.PrimaryLighter, width: 1.4),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              'Save Route',
              maxLines: 1,
              overflow: TextOverflow.visible,
              style: AppTextStyles.Body.copyWith(color: AppColors.Primary),
            ),
          ),
          const SizedBox(width: 8),
          SvgPicture.asset(
            'assets/icons/save_black.svg',
            width: 22,
            height: 22,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}

class _RouteGoButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _RouteGoButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.Accent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color(0x26000000),
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Go',
              style: AppTextStyles.Body.copyWith(color: AppColors.White),
            ),
            const SizedBox(width: 8),
            SvgPicture.asset(
              'assets/icons/navigate_white.svg',
              width: 24,
              height: 24,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }
}

class _AiGradientCard extends StatelessWidget {
  final Widget child;

  const _AiGradientCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(1.4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: AppGradients.AIModuleIndicator,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.White,
          borderRadius: BorderRadius.circular(10.6),
        ),
        child: child,
      ),
    );
  }
}

class _UserBubble extends StatelessWidget {
  final String text;

  const _UserBubble({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            decoration: BoxDecoration(
              color: AppColors.Accent,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x26000000),
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Text(
              text,
              style: AppTextStyles.Body.copyWith(
                color: AppColors.White,
                height: 1.25,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        const _ProfilePlaceholder(size: 43),
      ],
    );
  }
}

class _ProfilePlaceholder extends StatelessWidget {
  final double size;

  const _ProfilePlaceholder({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.White,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.Secondary,
          width: 3,
        ),
      ),
      child: SvgPicture.asset(
        'assets/icons/person_filled.svg',
        width: size * 0.58,
        height: size * 0.58,
        fit: BoxFit.contain,
        colorFilter: const ColorFilter.mode(
          AppColors.Primary,
          BlendMode.srcIn,
        ),
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const _InputBar({
    required this.controller,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: const BoxDecoration(
        color: AppColors.White,
        boxShadow: [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 18,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 50,
              padding: const EdgeInsets.only(left: 16, right: 12),
              decoration: BoxDecoration(
                color: AppColors.Tertiary,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      minLines: 1,
                      maxLines: 2,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: true,
                        fillColor: AppColors.Tertiary,
                        hoverColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                        hintText: 'Write a question',
                        hintStyle: AppTextStyles.Body.copyWith(
                          color: AppColors.PrimaryLighter,
                        ),
                      ),
                      cursorColor: AppColors.Primary,
                      style: AppTextStyles.Body.copyWith(
                        color: AppColors.Primary,
                      ),
                      onSubmitted: (_) => onSend(),
                    ),
                  ),
                  SvgPicture.asset(
                    'assets/icons/mic_rounded.svg',
                    width: 24,
                    height: 24,
                    colorFilter: const ColorFilter.mode(
                      AppColors.Primary,
                      BlendMode.srcIn,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Semantics(
            button: true,
            label: 'Send',
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onSend,
              child: Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.Tertiary,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x26000000),
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Text(
                      'Send',
                      style: AppTextStyles.Body.copyWith(
                        color: AppColors.Primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    SvgPicture.asset(
                      'assets/icons/Send.svg',
                      width: 24,
                      height: 24,
                      fit: BoxFit.contain,
                      colorFilter: const ColorFilter.mode(
                        AppColors.Primary,
                        BlendMode.srcIn,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}