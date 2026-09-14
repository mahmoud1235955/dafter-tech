import 'package:daftar_tech/core/theme/app_colors.dart';
import 'package:daftar_tech/core/utils/app_constants.dart';
import 'package:daftar_tech/core/utils/phone_formatter.dart';
import 'package:daftar_tech/core/utils/validators.dart';
import 'package:daftar_tech/features/auth/domain/entities/user_entity.dart';
import 'package:daftar_tech/features/transactions/presentation/screens/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../widgets/auth_app_bar.dart';
import '../widgets/brand_hero.dart';
import '../widgets/business_type_selector.dart';
import '../widgets/otp_input.dart';
import '../widgets/phone_field.dart';
import '../widgets/security_badge.dart';
import '../widgets/support_footer.dart';

/// شاشة التسجيل/الدخول برقم الهاتف ورمز التأكيد (OTP).
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final FocusNode _phoneFocusNode = FocusNode();

  late final List<TextEditingController> _otpControllers;
  late final List<FocusNode> _otpFocusNodes;

  BusinessType _selectedType = BusinessType.grocery;
  String _otpCode = '';
  String? _phoneError;
  String? _otpError;

  /// هل المستخدم ضغط على زر الدخول مرة واحدة على الأقل؟
  /// (علشان نظهر أخطاء التحقق أثناء الكتابة بعد أول محاولة فقط)
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _otpControllers = List.generate(
      AppConstants.otpLength,
      (_) => TextEditingController(),
    );
    _otpFocusNodes = List.generate(AppConstants.otpLength, (_) => FocusNode());
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _phoneFocusNode.dispose();
    for (final controller in _otpControllers) {
      controller.dispose();
    }
    for (final node in _otpFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  bool get _isOtpComplete => _otpCode.length == AppConstants.otpLength;

  // ======================== الأحداث ========================

  void _showMessage(String message, {Color? background}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: background,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void _onPhoneChanged(String value) {
    // إعادة البناء في كل ضغطة علشان مؤشر صحة الرقم يتحدث مباشرة،
    // لكن رسائل الخطأ تظهر فقط بعد أول محاولة تسجيل.
    setState(() {
      if (_submitted) _phoneError = Validators.validatePhone(value);
    });
  }

  void _onOtpChanged(String code) {
    setState(() {
      _otpCode = code;
      if (_submitted) _otpError = Validators.validateOtp(code);
    });
  }

  void _onOtpCompleted(String code) {
    // الرمز اكتمل → نقفل الكيبورد علشان المستخدم يشوف باقي البيانات
    FocusScope.of(context).unfocus();
  }

  void _clearOtp({required bool focusPhone}) {
    for (final controller in _otpControllers) {
      controller.clear();
    }
    setState(() {
      _otpCode = '';
      _otpError = null;
    });
    if (focusPhone) {
      _phoneFocusNode.requestFocus();
    } else {
      _otpFocusNodes.first.requestFocus();
    }
  }

  void _resendOtp() {
    context.read<AuthCubit>().sendOtp(_phoneController.text);
  }

  void _onPhoneSubmitted(String value) {
    final error = Validators.validatePhone(value);
    setState(() => _phoneError = error);

    if (error != null) return;

    // الرقم سليم → نبعت الرمز وننقل التركيز لأول خانة
    _otpFocusNodes.first.requestFocus();
    _resendOtp();
  }

  void _submit() {
    FocusScope.of(context).unfocus();

    final phoneError = Validators.validatePhone(_phoneController.text);
    final otpError = Validators.validateOtp(_otpCode);

    setState(() {
      _submitted = true;
      _phoneError = phoneError;
      _otpError = otpError;
    });

    if (phoneError != null) {
      _phoneFocusNode.requestFocus();
      return;
    }

    if (otpError != null) {
      _otpFocusNodes[_otpCode.length.clamp(0, AppConstants.otpLength - 1)]
          .requestFocus();
      return;
    }

    context.read<AuthCubit>().submitRegister(
          phone: _phoneController.text,
          otp: Validators.cleanOtp(_otpCode),
          businessType: _selectedType,
        );
  }

  void _onNotificationsTap() {
    _showMessage('التنبيهات هتظهر هنا بعد تسجيل الدخول');
  }

  void _onStateChanged(BuildContext context, AuthState state) {
    if (state is AuthSuccess) {
      _showMessage(
        'تم تسجيل الدخول ومزامنة الحساب بنجاح!',
        background: AppColors.moneyIn,
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    } else if (state is AuthError) {
      _showMessage(state.message, background: AppColors.moneyOut);
    } else if (state is AuthOtpError) {
      _showMessage(state.message, background: AppColors.moneyOut);
    } else if (state is AuthOtpSent &&
        state.cooldown == AppConstants.otpResendCooldownSeconds) {
      _showMessage(
        'تم إرسال رمز التأكيد إلى ${PhoneFormatter.display(state.phone)}',
        background: AppColors.moneyIn,
      );
    }
  }

  // ======================== الواجهة ========================

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        body: BlocConsumer<AuthCubit, AuthState>(
          listener: _onStateChanged,
          // العد التنازلي لإعادة الإرسال بيتغير كل ثانية، ومفيش داعي
          // نعيد بناء الشاشة كلها مع كل تكة — الـ BlocSelector هو اللي بيتعامل معاه.
          buildWhen: (previous, current) =>
              !(previous is AuthOtpSent && current is AuthOtpSent),
          builder: (context, state) {
            final isLoading = state is AuthLoading;

            return SafeArea(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => FocusScope.of(context).unfocus(),
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.045,
                    vertical: 12,
                  ),
                  child: Column(
                    children: [
                      AuthAppBar(onNotificationsTap: _onNotificationsTap),
                      const SizedBox(height: 14),
                      const BrandHero(),
                      const SizedBox(height: 16),
                      _buildRegisterCard(isLoading),
                      const SizedBox(height: 12),
                      const SecurityBadge(),
                      const SizedBox(height: 10),
                      const SupportFooter(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRegisterCard(bool isLoading) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PhoneField(
            controller: _phoneController,
            focusNode: _phoneFocusNode,
            enabled: !isLoading,
            errorText: _phoneError,
            onChanged: _onPhoneChanged,
            onSubmitted: _onPhoneSubmitted,
          ),
          const SizedBox(height: 14),
          _buildOtpSection(isLoading),
          const SizedBox(height: 14),
          BusinessTypeSelector(
            selected: _selectedType,
            enabled: !isLoading,
            onChanged: (type) => setState(() => _selectedType = type),
          ),
          const SizedBox(height: 18),
          _buildSubmitButton(isLoading),
        ],
      ),
    );
  }

  Widget _buildOtpSection(bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: const [
                Icon(
                  Icons.lock_clock_outlined,
                  color: AppColors.primary,
                  size: 17,
                ),
                SizedBox(width: 6),
                Text(
                  'رمز التأكيد الفوري (OTP)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            _buildResendButton(),
          ],
        ),
        const SizedBox(height: 8),
        OtpInput(
          controllers: _otpControllers,
          focusNodes: _otpFocusNodes,
          length: AppConstants.otpLength,
          enabled: !isLoading,
          errorText: _otpError,
          onChanged: _onOtpChanged,
          onCompleted: _onOtpCompleted,
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: _buildOtpStatus()),
            TextButton(
              onPressed: isLoading ? null : () => _clearOtp(focusPhone: true),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'تغيير الرقم',
                style: TextStyle(color: AppColors.textMuted, fontSize: 11),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// -1 = جارٍ الإرسال، 0 = متاح، أكبر من 0 = عدد الثواني المتبقية.
  Widget _buildResendButton() {
    return BlocSelector<AuthCubit, AuthState, int>(
      selector: (state) {
        if (state is AuthOtpSending) return -1;
        if (state is AuthOtpSent) return state.cooldown;
        return 0;
      },
      builder: (context, seconds) {
        if (seconds < 0) {
          return const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          );
        }

        final canResend = seconds == 0;

        return TextButton(
          onPressed: canResend ? _resendOtp : null,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            canResend
                ? 'إعادة إرسال الرمز الآن'
                : 'إعادة الإرسال بعد $seconds ثانية',
            style: TextStyle(
              color: canResend ? AppColors.primary : AppColors.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }

  Widget _buildOtpStatus() {
    if (_otpError != null) return const SizedBox.shrink();

    if (_isOtpComplete) {
      return const Row(
        children: [
          Icon(Icons.auto_awesome, color: AppColors.moneyIn, size: 13),
          SizedBox(width: 4),
          Flexible(
            child: Text(
              'تم إدخال الرمز كاملاً ✓',
              style: TextStyle(
                color: AppColors.moneyIn,
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        const Icon(Icons.sms_outlined, color: AppColors.textMuted, size: 13),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            'هيوصلك رمز من ${AppConstants.otpLength} أرقام على رقمك',
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(bool isLoading) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.submitButton,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: isLoading ? null : _submit,
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'دخول فوري ومزامنة الحساب',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_back_rounded, color: Colors.white, size: 18),
                ],
              ),
      ),
    );
  }
}
