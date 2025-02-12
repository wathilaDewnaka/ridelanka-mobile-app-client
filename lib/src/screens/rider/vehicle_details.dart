import 'package:flutter/material.dart';

class VehicleDetails extends StatelessWidget {
  VehicleDetails({super.key});

  static const String id = "vehicles";

  final List<Map<String, String>> rides = [
    {
      'name': 'Mr. Mihin Randil Sineth',
      'price': 'LKR 10,500.00 / Month',
      'route':
          'Starts from Kiribathgoda > Bambalapitiya > Wallawatte > Dehiwala...',
      'image': 'assets/images/splash_screen/van.png',
    },
    {
      'name': 'Mr. John De Testing',
      'price': 'LKR 10,500.00 / Month',
      'route':
          'Starts from Kiribathgoda > Bambalapitiya > Wallawatte > Dehiwala...',
      'image': 'assets/images/splash_screen/van.png',
    },
    {
      'name': 'Mr. Anonymous Anonymous',
      'price': 'LKR 10,500.00 / Month',
      'route':
          'Starts from Kiribathgoda > Bambalapitiya > Wallawatte > Dehiwala...',
      'image': 'assets/images/splash_screen/van.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Stack(
          alignment: Alignment.center,
          children: [
            AppBar(
              backgroundColor: const Color(0xFF0051ED),
              leading: IconButton(
                icon:
                    const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              elevation: 0,
            ),
            const Padding(
              padding: EdgeInsets.only(top: 17.0),
              child: Text(
                "Rides",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: rides.length,
              itemBuilder: (context, index) {
                final ride = rides[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 8,
                  shadowColor: Colors.blue.shade200,
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            ride['image']!,
                            width: 110,
                            height: 85,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ride['name']!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                ride['price']!,
                                style: const TextStyle(
                                  color: Color(0xFF0051ED),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                ride['route']!,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: List.generate(
                                  5,
                                  (starIndex) => Icon(
                                    starIndex < 4
                                        ? Icons.star
                                        : Icons.star_half,
                                    color: Colors.amber,
                                    size: 22,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
