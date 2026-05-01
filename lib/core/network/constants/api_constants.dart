class ApiConstants {
  static const String baseDomain = 'http://10.10.5.81:5006';
  // static const String baseDomain = 'https://backendkennygee.onrender.com';
  static const String baseUrl = '$baseDomain/api/v1';

  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Map<String, String> authHeaders(String token) => {
    ...defaultHeaders,
    'Authorization': 'Bearer $token',
  };

  static Map<String, String> get multipartHeaders => {
    'Accept': 'application/json',
    // Content-Type will be set automatically for multipart
  };

  /// [Endpoint Groups]
  static AuthEndpoints get auth => AuthEndpoints();

  static UserEndpoints get user => UserEndpoints();
  static NotificationEndpoints get notification => NotificationEndpoints();

  static GetProfile get getProfile => GetProfile();

  static PlanEndpoints get plan => PlanEndpoints();

  static SubscriptionEndpoints get subscription => SubscriptionEndpoints();

  static PaymentEndpoints get payment => PaymentEndpoints();

  static ShopEndpoints get shop => ShopEndpoints();
  static MenuEndpoints get menu => MenuEndpoints();
  static ReviewEndpoints get review => ReviewEndpoints();
  static EventEndpoints get event => EventEndpoints();
  static AnalyticsEndpoints get analytics => AnalyticsEndpoints();
  static WishlistEndpoints get wishlist => WishlistEndpoints();
  static BookmarkEndpoints get bookmark => BookmarkEndpoints();
}

/// [Authentication Endpoints]
class AuthEndpoints {
  static const String _base = '${ApiConstants.baseUrl}/auth';

  final String login = '$_base/login';

  final String register = '$_base/register';
  final String forgotPass = '$_base/forget';
  final String resrtPass = '$_base/reset-password';
  final String verifyMailOtp = '$_base/verify';

  final String refreshToken = '$_base/refresh-token';

  final String setNewPass = '$_base/reset-password';

  final String changePass = '$_base/change-password';
  final String logout = '$_base/logout';
}

class GetProfile {
  static const String _baseUrl = ApiConstants.baseUrl;

  // Single endpoint for all roles - backend handles role-based logic
  String fetchProfileByRole(String role) {
    return '$_baseUrl/user/profile';
  }

  String updateProfileByRole(String role) {
    return '$_baseUrl/user/update-profile';
  }

  // Legacy endpoints for backward compatibility
  final String fetchProfile = '$_baseUrl/user/profile';
  final String updateProfile =
      '$_baseUrl/user/profile'; // Use same endpoint as GET with PUT method
}

class UserEndpoints {
  static const String _base = '${ApiConstants.baseUrl}/user';
  final String updateProfile =
      '$_base/profile'; // Use same endpoint as GET with PUT method
  final String getUserProfile = '$_base/profile';
  final String changePassword = '$_base/change-password';
  final String getMyActivities = '$_base/my-activities';

  // final String create = '$_base/create';
}

class NotificationEndpoints {
  static const String _base = '${ApiConstants.baseUrl}/notification';

  final String getNotifications = _base;
  String getNotificationsWithPage(int page, int limit) =>
      '$_base?page=$page&limit=$limit';
}

class PlanEndpoints {
  static const String _base = '${ApiConstants.baseUrl}/plan';

  final String getPlans = _base;
}

class PaymentEndpoints {
  static const String _base = '${ApiConstants.baseUrl}/payments';

  final String createPayment = '$_base/create-payment';
  final String confirmPayment = '$_base/confirm-payment';
  final String createPaymentEvent = '$_base/event';
  final String confirmPaymentEvent = '$_base/event/confirm';
}

class AskPriceEndpoints {
  static const String _base = '${ApiConstants.baseUrl}/load';

  String askPrice(String id) => '$_base/$id/ask-price';
}

/// Subscription Endpoints
class SubscriptionEndpoints {
  static const String _base = '${ApiConstants.baseUrl}/subscription';

  final String getSubscriptions = _base;
}

class ShopEndpoints {
  static const String _base = '${ApiConstants.baseUrl}/shop';

  final String fetchNearbyShops = '$_base/';
  final String fetchRecommendedShops = '$_base/recommended';
  final String createShop = '$_base/create';

  String fetchShopByUser(String userId) => '$_base/user/$userId';

  String fetchShopDetails(String shopId) => '$_base/$shopId';

  String updateShop(String shopId) => '$_base/$shopId';
}

class MenuEndpoints {
  static const String _base = '${ApiConstants.baseUrl}/menu';

  final String fetchNearbyMenus = '$_base/nearby';

  final String createMenu = '$_base/';

  String fetchMenuDetails(String menuId) => '$_base/$menuId';

  String fetchShopMenus(String shopId) => '$_base/shop/$shopId';

  String updateMenu(String menuId) => '$_base/$menuId';

  String deleteMenu(String menuId) => '$_base/$menuId';

  String toggleSpecialOffer(String menuId) =>
      '$_base/menu/$menuId/specialOffer';
}

class EventEndpoints {
  static const String _base = '${ApiConstants.baseUrl}/event';

  final String fetchEvents = _base;
  final String createEvent = '$_base/create';

  String fetchEventsByUser(String userId) => '$_base/user/$userId';

  String fetchEventById(String eventId) => '$_base/$eventId';

  String fetchGoingStatus(String eventId) => '$_base/$eventId/going';

  String toggleGoing(String eventId) => '$_base/$eventId/going';
}

class ReviewEndpoints {
  static const String _base = '${ApiConstants.baseUrl}/review';

  final String createReview = _base;
  final String fetchReviews = '$_base/reviews';
  String toggleReviewLike(String reviewId) => '$_base/like/$reviewId';
}

class AnalyticsEndpoints {
  static const String _base = '${ApiConstants.baseUrl}/analytics';

  final String fetchRestaurantOwnerAnalytics = '$_base/restaurant-owner';
}

class WishlistEndpoints {
  static const String _base = '${ApiConstants.baseUrl}/wishlist';

  final String fetchMyWishlist = '$_base/my';
  final String toggleWishlist = '$_base/toggle';
}

class BookmarkEndpoints {
  static const String _base = '${ApiConstants.baseUrl}/bookmark';

  final String toggleBookmark = '$_base/toggle';
}
