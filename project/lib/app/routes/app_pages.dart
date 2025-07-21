import 'package:get/get.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/auth/views/register_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/user/bindings/user_binding.dart';
import '../modules/user/views/user_home_view.dart';
import '../modules/owner/bindings/owner_binding.dart';
import '../modules/owner/views/owner_home_view.dart';
import '../modules/booking/bindings/booking_binding.dart';
import '../modules/booking/views/booking_view.dart';
import '../modules/booking/views/booking_confirmation_view.dart';
import '../modules/booking/views/bookings_history_view.dart';
import '../modules/owner/views/owner_registration_view.dart';
import '../modules/owner/views/add_charging_slot_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/owner/views/owner_dashboard_view.dart';
import 'app_routes.dart';

class AppPages {
  static const INITIAL = AppRoutes.SPLASH;

  static final routes = [
    GetPage(
      name: AppRoutes.SPLASH,
      page: () => SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.LOGIN,
      page: () => LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.REGISTER,
      page: () => RegisterView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.HOME,
      page: () => HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.USER_HOME,
      page: () => UserHomeView(),
      binding: UserBinding(),
    ),
    GetPage(
      name: AppRoutes.OWNER_HOME,
      page: () => OwnerHomeView(),
      binding: OwnerBinding(),
    ),
    GetPage(
      name: AppRoutes.BOOKING,
      page: () => BookingView(),
      binding: BookingBinding(),
    ),
    GetPage(
      name: AppRoutes.BOOKING_CONFIRMATION,
      page: () => BookingConfirmationView(),
      binding: BookingBinding(),
    ),
    GetPage(
      name: AppRoutes.BOOKINGS_HISTORY,
      page: () => BookingsHistoryView(),
      binding: BookingBinding(),
    ),
    GetPage(
      name: AppRoutes.OWNER_REGISTRATION,
      page: () => OwnerRegistrationView(),
      binding: OwnerBinding(),
    ),
    GetPage(
      name: AppRoutes.ADD_CHARGING_SLOT,
      page: () => AddChargingSlotView(),
      binding: OwnerBinding(),
    ),
    GetPage(
      name: AppRoutes.PROFILE,
      page: () => ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.OWNER_DASHBOARD,
      page: () => OwnerDashboardView(),
      binding: OwnerBinding(),
    ),
  ];
}