import '../../../../core/common/constants/app_images.dart';
import '../model/event_model.dart';
import '../model/food_model.dart';
import '../model/home_recommendation_item_model.dart';
import '../model/restaurant_model.dart';

class HomeMockData {
  HomeMockData._();

  static const FoodModel gourmetWagyuBurger = FoodModel(
    id: 'food_1',
    name: 'Gourmet Wagyu\nBurger',
    image: AppImages.homeRestaurant3,
    price: 18.00,
    rating: 5.0,
    reviewsCount: 232,
    description:
        'Experience pure indulgence with our signature Wagyu Burger. Features a premium 250g A5 Wagyu beef patty, aged cheddar cheese, caramelized onions, and our secret truffle aioli, all served on a toasted artisanal brioche bun.',
    restaurantName: 'The Golden Truffel',
    distance: '1.3KM AWAY',
    address: '123 Sunset Boulevard, Beverly Hills, CA 9012',
    openingHours: '9:00 AM to 11:00PM',
    isLiked: true,
  );

  static const FoodModel trufflePasta = FoodModel(
    id: 'food_2',
    name: 'Truffle Cream Pasta',
    image: AppImages.homeRestaurant2,
    price: 16.00,
    rating: 4.9,
    reviewsCount: 158,
    description:
        'Silky handmade pasta tossed in truffle-infused cream sauce, parmesan, and crispy garlic crumbs for a rich and elegant bite.',
    restaurantName: 'The Golden Truffel',
    distance: '1.2KM AWAY',
    address: '123 Sunset Boulevard, Beverly Hills, CA 9012',
    openingHours: '9:00 AM to 11:00PM',
    isLiked: false,
  );

  static const FoodModel spicyDumplingPlatter = FoodModel(
    id: 'food_3',
    name: 'Spicy Dumpling Platter',
    image: AppImages.homeRestaurant1,
    price: 14.00,
    rating: 4.8,
    reviewsCount: 96,
    description:
        'Pan-seared dumplings with house chili oil, sesame glaze, and fresh scallions. A balanced mix of heat and savory flavor.',
    restaurantName: 'The Golden Truffel',
    distance: '1.4KM AWAY',
    address: '123 Sunset Boulevard, Beverly Hills, CA 9012',
    openingHours: '9:00 AM to 11:00PM',
    isLiked: true,
  );

  static const List<FoodModel> foodList = <FoodModel>[
    gourmetWagyuBurger,
    trufflePasta,
    spicyDumplingPlatter,
    gourmetWagyuBurger,
    trufflePasta,
    spicyDumplingPlatter,
  ];

  static const RestaurantModel laBellaItalia = RestaurantModel(
    id: 'rest_1',
    name: 'La Bella Italia',
    subtitle: 'Italian Restaurant',
    image: AppImages.homeRestaurant1,
    rating: 5.0,
    reviewsCount: 232,
    distance: '1.2 miles away',
    address: 'Downtown District, City Center',
    openingHours: '11:00 AM - 10:00 PM',
    isLiked: true,
    popularDishes: <String>['Pasta', 'Burger', 'Cheesecake'],
    menuItems: <RestaurantMenuItemModel>[
      RestaurantMenuItemModel(
        name: 'Side view club',
        price: 25,
        image: AppImages.homeRestaurant1,
      ),
      RestaurantMenuItemModel(
        name: 'Side view club',
        price: 25,
        image: AppImages.homeRestaurant2,
      ),
      RestaurantMenuItemModel(
        name: 'Side view club',
        price: 25,
        image: AppImages.homeRestaurant3,
      ),
      RestaurantMenuItemModel(
        name: 'Side view club',
        price: 25,
        image: AppImages.homeRestaurant1,
      ),
      RestaurantMenuItemModel(
        name: 'Side view club',
        price: 25,
        image: AppImages.homeRestaurant2,
      ),
      RestaurantMenuItemModel(
        name: 'Side view club',
        price: 25,
        image: AppImages.homeRestaurant3,
      ),
    ],
  );

  static const RestaurantModel greenTable = RestaurantModel(
    id: 'rest_2',
    name: 'Green Table Kitchen',
    subtitle: 'Fusion Restaurant',
    image: AppImages.homeRestaurant2,
    rating: 4.9,
    reviewsCount: 180,
    distance: '1.0 miles away',
    address: 'Central Avenue, Riverside',
    openingHours: '10:30 AM - 09:30 PM',
    isLiked: true,
    popularDishes: <String>['Noodles', 'Salad', 'Soup'],
    menuItems: <RestaurantMenuItemModel>[
      RestaurantMenuItemModel(
        name: 'Chef special bowl',
        price: 22,
        image: AppImages.homeRestaurant2,
      ),
      RestaurantMenuItemModel(
        name: 'Spicy chicken wraps',
        price: 19,
        image: AppImages.homeRestaurant1,
      ),
    ],
  );

  static const RestaurantModel sunsetGrill = RestaurantModel(
    id: 'rest_3',
    name: 'Sunset Grill House',
    subtitle: 'Family Restaurant',
    image: AppImages.homeRestaurant3,
    rating: 4.8,
    reviewsCount: 146,
    distance: '1.4 miles away',
    address: 'Maple Street, Midtown',
    openingHours: '12:00 PM - 11:00 PM',
    isLiked: false,
    popularDishes: <String>['Steak', 'Sandwich', 'Soup'],
    menuItems: <RestaurantMenuItemModel>[
      RestaurantMenuItemModel(
        name: 'Grilled burger combo',
        price: 20,
        image: AppImages.homeRestaurant3,
      ),
      RestaurantMenuItemModel(
        name: 'House pasta',
        price: 24,
        image: AppImages.homeRestaurant2,
      ),
    ],
  );

  static const List<RestaurantModel> nearbyRestaurants = <RestaurantModel>[
    laBellaItalia,
    greenTable,
    sunsetGrill,
  ];

  static const List<RestaurantModel> restaurantList = <RestaurantModel>[
    laBellaItalia,
    greenTable,
    sunsetGrill,
    RestaurantModel(
      id: 'rest_4',
      name: 'City Bites',
      subtitle: 'Modern Restaurant',
      image: AppImages.homeRestaurant1,
      rating: 4.7,
      reviewsCount: 124,
      distance: '1.6 miles away',
      address: 'Hill Road, Downtown',
      openingHours: '09:00 AM - 09:00 PM',
      isLiked: false,
      popularDishes: <String>['Sandwich', 'Rice Bowl'],
      menuItems: <RestaurantMenuItemModel>[
        RestaurantMenuItemModel(
          name: 'Veg delight plate',
          price: 18,
          image: AppImages.homeRestaurant1,
        ),
      ],
    ),
    RestaurantModel(
      id: 'rest_5',
      name: 'Riverfront Cafe',
      subtitle: 'Cafe & Restaurant',
      image: AppImages.homeRestaurant2,
      rating: 4.9,
      reviewsCount: 203,
      distance: '0.9 miles away',
      address: 'River Walk, East Side',
      openingHours: '08:00 AM - 10:00 PM',
      isLiked: true,
      popularDishes: <String>['Coffee', 'Burger', 'Pasta'],
      menuItems: <RestaurantMenuItemModel>[
        RestaurantMenuItemModel(
          name: 'Classic breakfast set',
          price: 16,
          image: AppImages.homeRestaurant2,
        ),
      ],
    ),
    RestaurantModel(
      id: 'rest_6',
      name: 'Olive Corner',
      subtitle: 'Mediterranean Restaurant',
      image: AppImages.homeRestaurant3,
      rating: 4.6,
      reviewsCount: 97,
      distance: '2.1 miles away',
      address: 'Park Lane, Old Town',
      openingHours: '11:00 AM - 10:30 PM',
      isLiked: false,
      popularDishes: <String>['Falafel', 'Hummus'],
      menuItems: <RestaurantMenuItemModel>[
        RestaurantMenuItemModel(
          name: 'Mediterranean platter',
          price: 23,
          image: AppImages.homeRestaurant3,
        ),
      ],
    ),
  ];

  static const List<HomeRecommendationItemModel> recommendedItems =
      <HomeRecommendationItemModel>[
        HomeRecommendationItemModel(
          id: 'rec_1',
          type: 'restaurant',
          title: 'La Bella Italia',
          image: AppImages.homeRestaurant1,
          rating: 5.0,
          distance: '1.2 miles away',
          openingHours: '11:00 AM - 10:00 PM',
          restaurant: laBellaItalia,
        ),
        HomeRecommendationItemModel(
          id: 'rec_2',
          type: 'food',
          title: 'Gourmet Wagyu Burger',
          image: AppImages.homeRestaurant3,
          rating: 5.0,
          distance: '1.3KM AWAY',
          openingHours: '9:00 AM to 11:00PM',
          food: gourmetWagyuBurger,
        ),
        HomeRecommendationItemModel(
          id: 'rec_3',
          type: 'restaurant',
          title: 'Green Table Kitchen',
          image: AppImages.homeRestaurant2,
          rating: 4.9,
          distance: '1.0 miles away',
          openingHours: '10:30 AM - 09:30 PM',
          restaurant: greenTable,
        ),
        HomeRecommendationItemModel(
          id: 'rec_4',
          type: 'food',
          title: 'Spicy dumpling platter',
          image: AppImages.homeRestaurant1,
          rating: 4.8,
          distance: '1.4KM AWAY',
          openingHours: '9:00 AM to 11:00PM',
          food: spicyDumplingPlatter,
        ),
        HomeRecommendationItemModel(
          id: 'rec_5',
          type: 'restaurant',
          title: 'Sunset Grill House',
          image: AppImages.homeRestaurant3,
          rating: 4.8,
          distance: '1.4 miles away',
          openingHours: '12:00 PM - 11:00 PM',
          restaurant: sunsetGrill,
        ),
      ];

  static const List<EventModel> eventList = <EventModel>[
    EventModel(
      id: 'event_1',
      title: 'Chef\'s Special Tasting Night',
      image: AppImages.homeRestaurant1,
      date: 'FRI, MAR 26',
      time: '6:00PM - 8:00PM',
      fee: '\$10.00',
      location: 'The Gilded Fork, Downtown',
      detailsTitle: 'Culinary Craft',
      detailsDescription:
          'Join us for an immersive journey through curated regional flavors paired with hand-crafted artisan selections. This session is designed for both the curious novice and the seasoned enthusiast, focusing on thoughtful flavor combinations and the stories behind every plate.',
    ),
    EventModel(
      id: 'event_2',
      title: 'Chef\'s Special Tasting Night',
      image: AppImages.homeRestaurant2,
      date: 'FRI, MAR 26',
      time: '6:00PM - 8:00PM',
      fee: 'Free',
      location: 'The Gilded Fork, Downtown',
      detailsTitle: 'Culinary Craft',
      detailsDescription:
          'Discover seasonal tasting plates, thoughtfully paired beverages, and chef insights that celebrate local ingredients and modern culinary artistry in a warm social setting.',
    ),
    EventModel(
      id: 'event_3',
      title: 'Chef\'s Special Tasting Night',
      image: AppImages.homeRestaurant3,
      date: 'FRI, MAR 26',
      time: '6:00PM - 8:00PM',
      fee: '\$10.00',
      location: 'The Gilded Fork, Downtown',
      detailsTitle: 'Culinary Craft',
      detailsDescription:
          'A one-evening tasting showcase featuring signature dishes, plated storytelling, and carefully balanced pairings built to highlight texture, aroma, and depth of flavor.',
    ),
  ];
}
