import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../state/auth_provider.dart';
import '../../theme/app_styles.dart';
import '../../widgets/buttons/button.dart';
import '../../widgets/input/checkbox_input_box.dart';
import '../../widgets/input/input_box.dart';

enum _AuthStep {
  welcome,
  createProfile,
  login,
  difficulties,
  mobilityDetails,
  visualDetails,
  suggestion,
  navigationProfile,
  componentSize,
  visualTheme,
  interactionFeedback,
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();

  _AuthStep _step = _AuthStep.welcome;
  bool _showPassword = false;
  bool _showLoginPassword = false;
  String _languageCode = 'en';

  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _loginEmailError;
  String? _loginPasswordError;
  String? _localError;

  final Set<String> _difficultyTypes = {};
  final Set<String> _mobilityDifficulties = {};
  final Set<String> _visualDifficulties = {};
  final Set<String> _navigationPreferences = {};
  String? _componentSize;
  String? _visualTheme;
  final Set<String> _feedbackPreferences = {};

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    super.dispose();
  }

  void _goTo(_AuthStep step) {
    context.read<AuthProvider>().clearError();
    setState(() {
      _step = step;
      _localError = null;
    });
  }

  void _goToPreferenceStep(int index) {
    final target = switch (index) {
      0 => _AuthStep.navigationProfile,
      1 => _AuthStep.componentSize,
      2 => _AuthStep.visualTheme,
      3 => _AuthStep.interactionFeedback,
      _ => _step,
    };

    if (target != _step) {
      _goTo(target);
    }
  }

  void _goBack() {
    switch (_step) {
      case _AuthStep.welcome:
        break;
      case _AuthStep.createProfile:
      case _AuthStep.login:
        _goTo(_AuthStep.welcome);
        break;
      case _AuthStep.difficulties:
        _goTo(_AuthStep.createProfile);
        break;
      case _AuthStep.mobilityDetails:
        _goTo(_AuthStep.difficulties);
        break;
      case _AuthStep.visualDetails:
        _goTo(_difficultyTypes.contains('mobility') ? _AuthStep.mobilityDetails : _AuthStep.difficulties);
        break;
      case _AuthStep.suggestion:
        if (_difficultyTypes.contains('visual')) {
          _goTo(_AuthStep.visualDetails);
        } else if (_difficultyTypes.contains('mobility')) {
          _goTo(_AuthStep.mobilityDetails);
        } else {
          _goTo(_AuthStep.difficulties);
        }
        break;
      case _AuthStep.navigationProfile:
        _goTo(_AuthStep.suggestion);
        break;
      case _AuthStep.componentSize:
        _goTo(_AuthStep.navigationProfile);
        break;
      case _AuthStep.visualTheme:
        _goTo(_AuthStep.componentSize);
        break;
      case _AuthStep.interactionFeedback:
        _goTo(_AuthStep.visualTheme);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return switch (_step) {
      _AuthStep.welcome => _buildWelcomePage(),
      _AuthStep.createProfile => _buildCreateProfilePage(),
      _AuthStep.login => _buildLoginPage(),
      _AuthStep.difficulties => _buildDifficultiesPage(),
      _AuthStep.mobilityDetails => _buildMobilityPage(),
      _AuthStep.visualDetails => _buildVisualPage(),
      _AuthStep.suggestion => _buildSuggestionPage(),
      _AuthStep.navigationProfile => _buildNavigationProfilePage(),
      _AuthStep.componentSize => _buildComponentSizePage(),
      _AuthStep.visualTheme => _buildVisualThemePage(),
      _AuthStep.interactionFeedback => _buildInteractionFeedbackPage(),
    };
  }

  Widget _buildWelcomePage() {
    return _OnboardingScaffold(
      showTopBar: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(flex: 2),
          const _InclusionLogo(alignment: Alignment.centerLeft),
          const SizedBox(height: 8),
          Text(
            'Your student life\nMore accessible to you.',
            style: AppTextStyles.TinyBodyBold.copyWith(height: 1.25),
          ),
          const SizedBox(height: 36),
          const _WelcomeImageCollage(),
          const SizedBox(height: 42),
          AppButton(
            text: 'Get Started',
            fullWidth: true,
            onPressed: () => _goTo(_AuthStep.createProfile),
          ),
          const SizedBox(height: 22),
          const Divider(height: 1, color: AppColors.Secondary),
          const SizedBox(height: 18),
          Center(
            child: Text(
              'Already have an account?',
              style: AppTextStyles.TinyBody.copyWith(color: AppColors.PrimaryLighter),
            ),
          ),
          const SizedBox(height: 12),
          AppButton(
            text: 'Login to an existing account',
            fullWidth: true,
            variant: AppButtonVariant.outline,
            onPressed: () => _goTo(_AuthStep.login),
          ),
          const Spacer(),
          _LanguageSelector(
            value: _languageCode,
            onTap: _openLanguageSheet,
          ),
        ],
      ),
    );
  }

  Widget _buildCreateProfilePage() {
    final auth = context.watch<AuthProvider>();

    return _OnboardingScaffold(
      onBack: _goBack,
      scrollable: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 56),
          Text('Let’s Create Your Profile', style: AppTextStyles.Heading1),
          const SizedBox(height: 8),
          Text(
            'Let’s get your email and password first for registration.',
            style: AppTextStyles.TinyBody,
          ),
          const SizedBox(height: 22),
          InputField(
            label: 'Institutional Email',
            hintText: 'Enter your Institutional Email',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            errorText: _emailError,
          ),
          const SizedBox(height: 18),
          InputField(
            label: 'Password',
            hintText: 'Enter your Password',
            controller: _passwordController,
            obscureText: !_showPassword,
            errorText: _passwordError,
            suffixIcon: IconButton(
              tooltip: _showPassword ? 'Hide password' : 'Show password',
              onPressed: () => setState(() => _showPassword = !_showPassword),
              icon: Icon(_showPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
            ),
          ),
          const SizedBox(height: 18),
          InputField(
            label: 'Confirm Password',
            hintText: 'Confirm your Password',
            controller: _confirmPasswordController,
            obscureText: !_showPassword,
            errorText: _confirmPasswordError,
          ),
          if (_localError != null || auth.error != null) ...[
            const SizedBox(height: 14),
            _ErrorMessage(message: _localError ?? auth.error!),
          ],
          const SizedBox(height: 28),
          AppButton(
            text: 'Get Started',
            fullWidth: true,
            onPressed: auth.isLoading ? null : _submitCreateProfile,
          ),
          const SizedBox(height: 22),
          const Divider(height: 1, color: AppColors.Secondary),
          const SizedBox(height: 18),
          Center(
            child: Text(
              'Already have an account?',
              style: AppTextStyles.TinyBody.copyWith(color: AppColors.PrimaryLighter),
            ),
          ),
          const SizedBox(height: 12),
          AppButton(
            text: 'Login to an existing account',
            fullWidth: true,
            variant: AppButtonVariant.outline,
            onPressed: auth.isLoading ? null : () => _goTo(_AuthStep.login),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginPage() {
    final auth = context.watch<AuthProvider>();

    return _OnboardingScaffold(
      onBack: _goBack,
      scrollable: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 56),
          Text('Login', style: AppTextStyles.Heading1),
          const SizedBox(height: 8),
          Text('Enter your credentials to access your account.', style: AppTextStyles.TinyBody),
          const SizedBox(height: 22),
          InputField(
            label: 'Institutional Email',
            hintText: 'Enter your Institutional Email',
            controller: _loginEmailController,
            keyboardType: TextInputType.emailAddress,
            errorText: _loginEmailError,
          ),
          const SizedBox(height: 18),
          InputField(
            label: 'Password',
            hintText: 'Enter your Password',
            controller: _loginPasswordController,
            obscureText: !_showLoginPassword,
            errorText: _loginPasswordError,
            suffixIcon: IconButton(
              tooltip: _showLoginPassword ? 'Hide password' : 'Show password',
              onPressed: () => setState(() => _showLoginPassword = !_showLoginPassword),
              icon: Icon(_showLoginPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
            ),
          ),
          if (_localError != null || auth.error != null) ...[
            const SizedBox(height: 14),
            _ErrorMessage(message: _localError ?? auth.error!),
          ],
          const SizedBox(height: 28),
          AppButton(
            text: 'Login',
            fullWidth: true,
            isLoading: auth.isLoading,
            onPressed: auth.isLoading ? null : _submitLogin,
          ),
          const SizedBox(height: 22),
          const Divider(height: 1, color: AppColors.Secondary),
          const SizedBox(height: 18),
          Center(
            child: Text(
              'Don’t have an account?',
              style: AppTextStyles.TinyBody.copyWith(color: AppColors.PrimaryLighter),
            ),
          ),
          const SizedBox(height: 12),
          AppButton(
            text: 'Sign Up',
            fullWidth: true,
            variant: AppButtonVariant.outline,
            onPressed: auth.isLoading ? null : () => _goTo(_AuthStep.createProfile),
          ),
          const SizedBox(height: 42),
          _LanguageSelector(
            value: _languageCode,
            onTap: _openLanguageSheet,
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultiesPage() {
    return _ChoicePage(
      onBack: _goBack,
      title: 'We would like to get to\nknow you better',
      subtitle: 'What are your day to day difficulties?',
      choices: [
        _ChoiceOption('mobility', 'I have difficulties with mobility', 'assets/icons/wheelchair.svg'),
        _ChoiceOption('visual', 'I have difficulties with vision', 'assets/icons/visibility.svg'),
        _ChoiceOption('hearing', 'I have difficulties with hearing', 'assets/icons/ear_sound.svg'),
        _ChoiceOption('other', 'Other difficulties', 'assets/icons/more_horiz.svg'),
      ],
      selectedValues: _difficultyTypes,
      onToggle: (value) => _toggle(_difficultyTypes, value),
      onContinue: _continueFromDifficulties,
    );
  }

  Widget _buildMobilityPage() {
    return _ChoicePage(
      onBack: _goBack,
      title: 'About your mobility\ndifficulties',
      subtitle: 'Which of these apply to your mobility?',
      choices: [
        _ChoiceOption('wheelchair', 'I use a wheelchair', 'assets/icons/wheelchair.svg'),
        _ChoiceOption('walking_aid', 'I use crutches or a walking aid', 'assets/icons/onboarding/mobility_walking_aid.svg'),
        _ChoiceOption('stairs', 'I have difficulties with stairs', 'assets/icons/onboarding/mobility_stairs.svg'),
        _ChoiceOption('tired', 'I get tired easily', 'assets/icons/onboarding/hr_resting.svg'),
      ],
      selectedValues: _mobilityDifficulties,
      onToggle: (value) => _toggle(_mobilityDifficulties, value),
      onContinue: () {
        if (_difficultyTypes.contains('visual')) {
          _goTo(_AuthStep.visualDetails);
        } else {
          _goTo(_AuthStep.suggestion);
        }
      },
    );
  }

  Widget _buildVisualPage() {
    return _ChoicePage(
      onBack: _goBack,
      title: 'About your visual\ndifficulties',
      subtitle: 'What visual impairments apply to you?',
      choices: [
        _ChoiceOption('details', 'I have difficulty seeing details', 'assets/icons/visibility.svg'),
        _ChoiceOption('screen_reader', 'I use a screen reader', 'assets/icons/text.svg'),
        _ChoiceOption('color_blind', 'I am color blind', 'assets/icons/more_horiz.svg'),
      ],
      selectedValues: _visualDifficulties,
      onToggle: (value) => _toggle(_visualDifficulties, value),
      onContinue: () => _goTo(_AuthStep.suggestion),
    );
  }

  Widget _buildSuggestionPage() {
    final auth = context.watch<AuthProvider>();

    return _OnboardingScaffold(
      onBack: _goBack,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 56),
          Text('We have a suggestion', style: AppTextStyles.Heading1),
          const SizedBox(height: 8),
          Text(
            'Based on your selections, we think you might benefit from.',
            style: AppTextStyles.TinyBody,
          ),
          Text(
            'You can change this in Settings anytime.',
            style: AppTextStyles.TinyBody.copyWith(color: AppColors.PrimaryLighter),
          ),
          const SizedBox(height: 20),
          _SuggestionGroup(title: 'Navigation Preferences', value: _suggestedNavigationLabel()),
          const SizedBox(height: 14),
          const _SuggestionGroup(title: 'Size of Interaction', value: 'System Settings'),
          const SizedBox(height: 14),
          const _SuggestionGroup(title: 'App’s Theme', value: 'System Settings', iconAsset: 'assets/icons/settings.svg'),
          const SizedBox(height: 14),
          const _SuggestionGroup(title: 'Interaction Feedback', value: 'System Settings', iconAsset: 'assets/icons/settings.svg'),
          if (_localError != null || auth.error != null) ...[
            const SizedBox(height: 12),
            _ErrorMessage(message: _localError ?? auth.error!),
          ],
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: 'Choose Differently',
                  fullWidth: true,
                  variant: AppButtonVariant.outline,
                  onPressed: auth.isLoading ? null : () => _goTo(_AuthStep.navigationProfile),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppButton(
                  text: 'Finish Setup',
                  fullWidth: true,
                  isLoading: auth.isLoading,
                  onPressed: auth.isLoading ? null : _finishSetup,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationProfilePage() {
    return _PreferencePage(
      onBack: _goBack,
      selectedIndex: 0,
      onBreadcrumbTap: _goToPreferenceStep,
      title: 'Your navigation profile',
      subtitle: 'Choose what navigation preferences apply to you.',
      choices: [
        _ChoiceOption('less_noise', 'Less Noise', null),
        _ChoiceOption('step_free', 'Step Free', null),
        _ChoiceOption('least_effort', 'Least Effort', null),
        _ChoiceOption('shortest_route', 'Shortest Route', null),
      ],
      selectedValues: _navigationPreferences,
      onToggle: (value) => _toggle(_navigationPreferences, value),
      onContinue: () => _goTo(_AuthStep.componentSize),
    );
  }

  Widget _buildComponentSizePage() {
    return _SinglePreferencePage(
      onBack: _goBack,
      selectedIndex: 1,
      onBreadcrumbTap: _goToPreferenceStep,
      title: 'Text and component size',
      subtitle: 'Choose your preferred interaction size.',
      choices: [
        _ChoiceOption('system', 'System Settings', null),
        _ChoiceOption('medium', 'Medium', null),
        _ChoiceOption('large', 'Large', null),
      ],
      selectedValue: _componentSize,
      onSelected: (value) => setState(() => _componentSize = value),
      onContinue: () => _goTo(_AuthStep.visualTheme),
    );
  }

  Widget _buildVisualThemePage() {
    return _SinglePreferencePage(
      onBack: _goBack,
      selectedIndex: 2,
      onBreadcrumbTap: _goToPreferenceStep,
      title: 'Your preferred visuals',
      subtitle: 'Choose what theme works best for you.',
      choices: [
        _ChoiceOption('system', 'System Settings', 'assets/icons/settings.svg'),
        _ChoiceOption('light', 'Light Mode', 'assets/icons/light_mode.svg'),
        _ChoiceOption('dark', 'Dark Mode', 'assets/icons/moon_stars.svg'),
        _ChoiceOption('contrast', 'High Contrast', 'assets/icons/contrast.svg'),
      ],
      selectedValue: _visualTheme,
      onSelected: (value) => setState(() => _visualTheme = value),
      onContinue: () => _goTo(_AuthStep.interactionFeedback),
    );
  }

  Widget _buildInteractionFeedbackPage() {
    final auth = context.watch<AuthProvider>();

    return _PreferencePage(
      onBack: _goBack,
      selectedIndex: 3,
      onBreadcrumbTap: _goToPreferenceStep,
      title: 'Interacting with the app',
      subtitle: 'Choose what type of feedback works best for you.',
      choices: [
        _ChoiceOption('system', 'System Settings', 'assets/icons/settings.svg'),
        _ChoiceOption('haptic_sound', 'Haptic/ Sound', 'assets/icons/mobile_vibrate.svg'),
        _ChoiceOption('read_page', 'Optional Read Page Contents', 'assets/icons/book_ribbon.svg'),
      ],
      selectedValues: _feedbackPreferences,
      onToggle: (value) => _toggle(_feedbackPreferences, value),
      buttonText: 'Finish Setup',
      loading: auth.isLoading,
      errorMessage: _localError ?? auth.error,
      onContinue: auth.isLoading ? null : _finishSetup,
    );
  }

  void _toggle(Set<String> values, String value) {
    setState(() {
      if (values.contains(value)) {
        values.remove(value);
      } else {
        values.add(value);
      }
    });
  }

  void _continueFromDifficulties() {
    if (_difficultyTypes.contains('mobility')) {
      _goTo(_AuthStep.mobilityDetails);
    } else if (_difficultyTypes.contains('visual')) {
      _goTo(_AuthStep.visualDetails);
    } else {
      _goTo(_AuthStep.suggestion);
    }
  }

  String _suggestedNavigationLabel() {
    if (_difficultyTypes.contains('mobility') || _mobilityDifficulties.contains('stairs')) {
      return 'Avoid stairs';
    }

    if (_difficultyTypes.contains('visual')) {
      return 'Less Noise';
    }

    return 'System Settings';
  }

  bool _validateCreateProfile() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    setState(() {
      _emailError = email.isEmpty
          ? 'Email is required'
          : !email.contains('@')
              ? 'Enter a valid email'
              : null;
      _passwordError = password.length < 6 ? 'Use at least 6 characters' : null;
      _confirmPasswordError = confirmPassword != password ? 'Passwords do not match' : null;
      _localError = null;
    });

    return _emailError == null && _passwordError == null && _confirmPasswordError == null;
  }

  void _submitCreateProfile() {
    if (!_validateCreateProfile()) return;
    _goTo(_AuthStep.difficulties);
  }

  Future<void> _submitLogin() async {
    final email = _loginEmailController.text.trim();
    final password = _loginPasswordController.text;

    setState(() {
      _loginEmailError = email.isEmpty
          ? 'Email is required'
          : !email.contains('@')
              ? 'Enter a valid email'
              : null;
      _loginPasswordError = password.isEmpty ? 'Password is required' : null;
      _localError = null;
    });

    if (_loginEmailError != null || _loginPasswordError != null) return;

    await context.read<AuthProvider>().login(
          email: email,
          password: password,
        );
  }

  Future<void> _finishSetup() async {
    if (!_validateCreateProfile()) {
      _goTo(_AuthStep.createProfile);
      return;
    }

    final email = _emailController.text.trim();
    final generatedName = _nameFromEmail(email);

    await context.read<AuthProvider>().register(
          email: email,
          password: _passwordController.text,
          fullName: generatedName,
          accountType: 'normal',
        );

    if (!mounted) return;

    final auth = context.read<AuthProvider>();
    if (!auth.isAuthenticated && auth.error != null) {
      setState(() => _localError = auth.error);
    }
  }

  String _nameFromEmail(String email) {
    final localPart = email.split('@').first.trim();
    if (localPart.isEmpty) return 'Student';

    return localPart
        .split(RegExp(r'[._-]+'))
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }

  Future<void> _openLanguageSheet() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.Primary.withValues(alpha: 0.24),
      builder: (context) {
        return _LanguageBottomSheet(selectedCode: _languageCode);
      },
    );

    if (selected == null || !mounted) return;
    setState(() => _languageCode = selected);
  }
}

class _OnboardingScaffold extends StatelessWidget {
  final Widget child;
  final VoidCallback? onBack;
  final bool showTopBar;
  final bool scrollable;

  const _OnboardingScaffold({
    required this.child,
    this.onBack,
    this.showTopBar = true,
    this.scrollable = false,
  });

  @override
  Widget build(BuildContext context) {
    final pageContent = Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
         
          if (showTopBar) ...[
            const SizedBox(height: 10),
            _OnboardingTopBar(onBack: onBack),
          ],
          Expanded(
            child: scrollable
                ? SingleChildScrollView(
                    child: child,
                  )
                : child,
          ),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.Background,
      body: SafeArea(
        bottom: false,
        child: pageContent,
      ),
    );
  }
}


class _OnboardingTopBar extends StatelessWidget {
  final VoidCallback? onBack;

  const _OnboardingTopBar({this.onBack});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: _BackButton(onPressed: onBack),
          ),
          const _InclusionLogo(width: 98, height: 18),
        ],
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const _BackButton({this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Back',
      child: GestureDetector(
        onTap: onPressed ?? () => Navigator.of(context).maybePop(),
        behavior: HitTestBehavior.opaque,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.arrow_back, size: 14, color: AppColors.Primary),
            const SizedBox(width: 6),
            Text('Back', style: AppTextStyles.TinyBody),
          ],
        ),
      ),
    );
  }
}

class _InclusionLogo extends StatelessWidget {
  final double width;
  final double height;
  final Alignment alignment;

  const _InclusionLogo({
    this.width = 130,
    this.height = 28,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: SvgPicture.asset(
        'assets/logos/inclusion_logo_magenta.svg',
        width: width,
        height: height,
        fit: BoxFit.contain,
        semanticsLabel: 'Inclusion Plus logo',
      ),
    );
  }
}

class _WelcomeImageCollage extends StatelessWidget {
  const _WelcomeImageCollage();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 170,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: const [
          Positioned(
            right: -28,
            top: 48,
            child: _WelcomePhoto(
              asset: 'assets/images/welcome_accessibility.jpg',
              width: 86,
              height: 100,
            ),
          ),
          Positioned(
            left: 0,
            top: 28,
            child: _WelcomePhoto(
              asset: 'assets/images/welcome_classroom.jpg',
              width: 164,
              height: 116,
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: _WelcomePhoto(
              asset: 'assets/images/welcome_graduation.jpg',
              width: 172,
              height: 140,
            ),
          ),
        ],
      ),
    );
  }
}

class _WelcomePhoto extends StatelessWidget {
  final String asset;
  final double width;
  final double height;

  const _WelcomePhoto({
    required this.asset,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.asset(
        asset,
        width: width,
        height: height,
        fit: BoxFit.cover,
      ),
    );
  }
}

class _ChoicePage extends StatelessWidget {
  final VoidCallback onBack;
  final String title;
  final String subtitle;
  final List<_ChoiceOption> choices;
  final Set<String> selectedValues;
  final ValueChanged<String> onToggle;
  final VoidCallback onContinue;

  const _ChoicePage({
    required this.onBack,
    required this.title,
    required this.subtitle,
    required this.choices,
    required this.selectedValues,
    required this.onToggle,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return _OnboardingScaffold(
      onBack: onBack,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 80),
          Text(title, style: AppTextStyles.Heading1),
          const SizedBox(height: 8),
          Text(subtitle, style: AppTextStyles.TinyBody),
          const SizedBox(height: 32),
          for (int index = 0; index < choices.length; index++) ...[
            CheckboxInputBox(
              key: ValueKey(choices[index].value),
              label: choices[index].label,
              iconAsset: choices[index].iconAsset,
              iconColor: AppColors.Primary,
              value: selectedValues.contains(choices[index].value),
              onChanged: (_) => onToggle(choices[index].value),
            ),
            if (index != choices.length - 1) const SizedBox(height: 16),
          ],
          const Spacer(),
          AppButton(
            text: 'Continue',
            fullWidth: true,
            onPressed: onContinue,
          ),
          const SizedBox(height: 95),
        ],
      ),
    );
  }
}

class _SuggestionGroup extends StatelessWidget {
  final String title;
  final String value;
  final String? iconAsset;

  const _SuggestionGroup({
    required this.title,
    required this.value,
    this.iconAsset,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.TinyBodyBold),
        const SizedBox(height: 8),
        CheckboxInputBox(
          label: value,
          iconAsset: iconAsset,
          iconColor: AppColors.Primary,
          value: true,
          onChanged: (_) {},
        ),
      ],
    );
  }
}

class _PreferencePage extends StatelessWidget {
  final VoidCallback onBack;
  final int selectedIndex;
  final ValueChanged<int> onBreadcrumbTap;
  final String title;
  final String subtitle;
  final List<_ChoiceOption> choices;
  final Set<String> selectedValues;
  final ValueChanged<String> onToggle;
  final VoidCallback? onContinue;
  final String buttonText;
  final bool loading;
  final String? errorMessage;

  const _PreferencePage({
    required this.onBack,
    required this.selectedIndex,
    required this.onBreadcrumbTap,
    required this.title,
    required this.subtitle,
    required this.choices,
    required this.selectedValues,
    required this.onToggle,
    required this.onContinue,
    this.buttonText = 'Continue',
    this.loading = false,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return _OnboardingScaffold(
      onBack: onBack,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 48),
          _OnboardingBreadcrumb(
            selectedIndex: selectedIndex,
            onTap: onBreadcrumbTap,
          ),
          const SizedBox(height: 32),
          Text(title, style: AppTextStyles.Header),
          const SizedBox(height: 16),
          Text(subtitle, style: AppTextStyles.Body),
          Text(
            'You can change this in Settings anytime.',
            style: AppTextStyles.TinyBody.copyWith(color: AppColors.PrimaryLighter),
          ),
          const SizedBox(height: 32),
          for (int index = 0; index < choices.length; index++) ...[
            CheckboxInputBox(
              key: ValueKey(choices[index].value),
              label: choices[index].label,
              iconAsset: choices[index].iconAsset,
              iconColor: AppColors.Primary,
              value: selectedValues.contains(choices[index].value),
              onChanged: (_) => onToggle(choices[index].value),
            ),
            if (index != choices.length - 1) const SizedBox(height: 16),
          ],
          if (errorMessage != null) ...[
            const SizedBox(height: 12),
            _ErrorMessage(message: errorMessage!),
          ],
          const Spacer(),
          AppButton(
            text: buttonText,
            fullWidth: true,
            isLoading: loading,
            onPressed: onContinue,
          ),
          const SizedBox(height: 95),
        ],
      ),
    );
  }
}

class _SinglePreferencePage extends StatelessWidget {
  final VoidCallback onBack;
  final int selectedIndex;
  final ValueChanged<int> onBreadcrumbTap;
  final String title;
  final String subtitle;
  final List<_ChoiceOption> choices;
  final String? selectedValue;
  final ValueChanged<String> onSelected;
  final VoidCallback onContinue;

  const _SinglePreferencePage({
    required this.onBack,
    required this.selectedIndex,
    required this.onBreadcrumbTap,
    required this.title,
    required this.subtitle,
    required this.choices,
    required this.selectedValue,
    required this.onSelected,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return _PreferencePage(
      onBack: onBack,
      selectedIndex: selectedIndex,
      onBreadcrumbTap: onBreadcrumbTap,
      title: title,
      subtitle: subtitle,
      choices: choices,
      selectedValues: selectedValue == null ? const <String>{} : {selectedValue!},
      onToggle: onSelected,
      onContinue: onContinue,
    );
  }
}

class _OnboardingBreadcrumb extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _OnboardingBreadcrumb({
    required this.selectedIndex,
    required this.onTap,
  });

  static const List<_BreadcrumbItemData> _items = [
    _BreadcrumbItemData('Preferences', AppColors.Accent),
    _BreadcrumbItemData('Size', AppColors.CategoryMagenta),
    _BreadcrumbItemData('Theme', AppColors.CategoryPurple),
    _BreadcrumbItemData('Feedback', AppColors.Accent),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 41,
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (int index = 0; index < _items.length; index++)
            _BreadcrumbStep(
              item: _items[index],
              selected: selectedIndex == index,
              onTap: () => onTap(index),
            ),
        ],
      ),
    );
  }
}

class _BreadcrumbStep extends StatelessWidget {
  final _BreadcrumbItemData item;
  final bool selected;
  final VoidCallback onTap;

  const _BreadcrumbStep({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = AppTextStyles.TinyBody.copyWith(
      color: selected ? AppColors.White : AppColors.PrimaryLighter,
      fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
      height: 20 / 14,
    );

    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          height: 41,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 28,
                child: Center(
                  child: Container(
                    height: 28,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected ? item.selectedColor : Colors.transparent,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      item.label,
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.visible,
                      style: textStyle,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Container(
                width: selected ? 52 : 0,
                height: 3,
                decoration: BoxDecoration(
                  color: selected
                      ? item.selectedColor.withValues(alpha: 0.45)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(99),
                  boxShadow: selected
                      ? const [
                          BoxShadow(
                            color: Color(0x26000000),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BreadcrumbItemData {
  final String label;
  final Color selectedColor;

  const _BreadcrumbItemData(this.label, this.selectedColor);
}

class _ChoiceOption {
  final String value;
  final String label;
  final String? iconAsset;

  const _ChoiceOption(this.value, this.label, this.iconAsset);
}

class _ErrorMessage extends StatelessWidget {
  final String message;

  const _ErrorMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.Error.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.Error),
        ),
        child: Text(
          message,
          style: AppTextStyles.TinyBody.copyWith(color: AppColors.Error),
        ),
      ),
    );
  }
}

class _LanguageSelector extends StatelessWidget {
  final String value;
  final VoidCallback onTap;

  const _LanguageSelector({
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final language = _languageLabel(value);

    return Center(
      child: Semantics(
        button: true,
        label: 'Choose language, $language selected',
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_languageFlag(value), style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 8),
                Text(language, style: AppTextStyles.TinyBody),
                const SizedBox(width: 4),
                const Icon(Icons.keyboard_arrow_down, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _languageLabel(String code) {
    return switch (code) {
      'pt' => 'Português',
      'tr' => 'Türkçe',
      _ => 'English',
    };
  }

  static String _languageFlag(String code) {
    return switch (code) {
      'pt' => '🇵🇹',
      'tr' => '🇹🇷',
      _ => '🇬🇧',
    };
  }
}

class _LanguageBottomSheet extends StatelessWidget {
  final String selectedCode;

  const _LanguageBottomSheet({required this.selectedCode});

  @override
  Widget build(BuildContext context) {
    final languages = const [
      ('en', 'English', '🇬🇧'),
      ('pt', 'Português', '🇵🇹'),
      ('tr', 'Türkçe', '🇹🇷'),
    ];

    return Container(
      height: MediaQuery.of(context).size.height * 0.62,
      decoration: const BoxDecoration(
        color: AppColors.Background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 58,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.PrimaryLighter.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 26),
            Text('Choose language', style: AppTextStyles.Heading1),
            const SizedBox(height: 8),
            Text(
              'This changes the language used during setup.',
              style: AppTextStyles.TinyBody.copyWith(color: AppColors.PrimaryLighter),
            ),
            const SizedBox(height: 20),
            for (final item in languages) ...[
              _LanguageTile(
                code: item.$1,
                label: item.$2,
                flag: item.$3,
                selected: item.$1 == selectedCode,
              ),
              const SizedBox(height: 12),
            ],
            const Spacer(),
            Text(
              'You can change this later in Settings.',
              style: AppTextStyles.TinyBody.copyWith(color: AppColors.PrimaryLighter, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final String code;
  final String label;
  final String flag;
  final bool selected;

  const _LanguageTile({
    required this.code,
    required this.label,
    required this.flag,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: GestureDetector(
        onTap: () => Navigator.of(context).pop(code),
        child: Container(
          height: 58,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.White,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.Accent : AppColors.PrimaryLighter,
              width: selected ? 1.6 : 1,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 5,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Text(flag, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 14),
              Expanded(child: Text(label, style: AppTextStyles.Body)),
              if (selected) const Icon(Icons.check_circle, color: AppColors.Accent),
            ],
          ),
        ),
      ),
    );
  }
}
