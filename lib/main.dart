import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'detail_image_viewer.dart';

void main() {
  runApp(MyApp());
}

class Restaurant {
  final String name;
  final String description;
  final String imageUrl;
  final String address;
  final String phoneNumber;
  final String hours;
  final double rating;
  final List<String> imageUrls;
  final double latitude;
  final double longitude;

  Restaurant({
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.address,
    required this.phoneNumber,
    required this.hours,
    required this.rating,
    required this.imageUrls,
    required this.latitude,
    required this.longitude,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      name: json['name'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      address: json['address'],
      phoneNumber: json['phoneNumber'],
      hours: json['hours'],
      rating: json['rating'].toDouble(),
      imageUrls: List<String>.from(json['imageUrls']),
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Restaurant List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: RestaurantListScreen(),
    );
  }
}

class RestaurantListScreen extends StatefulWidget {
  @override
  _RestaurantListScreenState createState() => _RestaurantListScreenState();
}

class _RestaurantListScreenState extends State<RestaurantListScreen> {
  late List<Restaurant> restaurants;

  @override
  void initState() {
    super.initState();
    _loadRestaurants();
  }

  Future<void> _loadRestaurants() async {
    final jsonString = await _loadRestaurantAsset();
    final jsonResponse = json.decode(jsonString);
    setState(() {
      restaurants = List<Restaurant>.from(jsonResponse.map((data) => Restaurant.fromJson(data)));
    });
  }

  Future<String> _loadRestaurantAsset() async {
    return await rootBundle.loadString('assets/restaurants.json');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Restaurant List"),
      ),
      body: restaurants == null
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: restaurants.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RestaurantDetailScreen(restaurant: restaurants[index]),
                      ),
                    );
                  },
                  child: RestaurantCard(restaurant: restaurants[index]),
                );
              },
            ),
    );
  }
}

class RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;

  RestaurantCard({required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Hero(
                tag: restaurant.imageUrl,
                child: Image.network(
                  restaurant.imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurant.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    restaurant.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RestaurantDetailScreen extends StatelessWidget {
  final Restaurant restaurant;

  RestaurantDetailScreen({required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(restaurant.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Hero(
                  tag: restaurant.imageUrl,
                  child: Image.network(
                    restaurant.imageUrl,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    height: 300,
                  ),
                ),
                Positioned(
                  top: 20,
                  left: 20,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurant.name,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber),
                      SizedBox(width: 5),
                      Text(
                        restaurant.rating.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    restaurant.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 20),
                  _buildDetailText('Address:', restaurant.address),
                  _buildDetailText('Phone:', restaurant.phoneNumber),
                  _buildDetailText('Hours:', restaurant.hours),
                  SizedBox(height: 20),
                  _buildGallery(restaurant.imageUrls),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RestaurantMapScreen(
                            latitude: restaurant.latitude,
                            longitude: restaurant.longitude,
                            restaurantName: restaurant.name,
                          ),
                        ),
                      );
                    },
                    child: Text('View Map'),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReservationScreen(restaurant: restaurant),
                        ),
                      );
                    },
                    child: Text('Reserve Table'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailText(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildGallery(List<String> imageUrls) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gallery',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: imageUrls.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(right: 10),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailImageViewer(imageUrl: imageUrls[index]),
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      imageUrls[index],
                      width: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }
}

class RestaurantMapScreen extends StatelessWidget {
  final double latitude;
  final double longitude;
  final String restaurantName;

  RestaurantMapScreen({
    required this.latitude,
    required this.longitude,
    required this.restaurantName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map - $restaurantName'),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(latitude, longitude),
          zoom: 15,
        ),
        markers: {
          Marker(
            markerId: MarkerId('restaurant_location'),
            position: LatLng(latitude, longitude),
            infoWindow: InfoWindow(
              title: restaurantName,
            ),
          ),
        },
      ),
    );
  }
}

class ReservationScreen extends StatelessWidget {
  final Restaurant restaurant;

  ReservationScreen({required this.restaurant});

  @override
  Widget build(BuildContext context) {
    // Implementasi layar reservasi di sini
    return Scaffold(
      appBar: AppBar(
        title: Text('Reservation - ${restaurant.name}'),
      ),
      body: Center(
        child: Text('Reservation Form Goes Here'),
      ),
    );
  }
}
