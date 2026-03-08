class Item {
  final String id;
  final String title;
  final double price;
  final String imageUrl;
  final String category;
  final String sellerId;
  final String sellerName;
  final String? sellerMajorYear;
  final bool isVerifiedStudent;
  final List<String>? availableColors;
  final bool isFavorite;
  final String? description;

  Item({
    required this.id,
    required this.title,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.sellerId,
    required this.sellerName,
    this.sellerMajorYear,
    this.isVerifiedStudent = true,
    this.availableColors,
    this.isFavorite = false,
    this.description,
  });
}

// Sample data
final List<Item> sampleItems = [
  Item(
    id: '1',
    title: 'Bato Lated Trabe',
    price: 5.00,
    imageUrl: 'https://images.unsplash.com/photo-1513475382585-d06e58bcb0e0?w=400',
    category: 'Campus/Building',
    sellerId: 'seller1',
    sellerName: 'Mark Johnson',
    sellerMajorYear: 'Computer Science / Year 3',
    isVerifiedStudent: true,
    availableColors: ['Ure'],
  ),
  Item(
    id: '2',
    title: 'Latm rfor vintage Books',
    price: 19.00,
    imageUrl: 'https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=400',
    category: 'Campus/Building',
    sellerId: 'seller2',
    sellerName: 'Sarah Miller',
    sellerMajorYear: 'Business / Year 2',
    isVerifiedStudent: true,
    availableColors: ['AL ADS'],
  ),
  Item(
    id: '3',
    title: 'Battir of Bale',
    price: 9.00,
    imageUrl: 'https://images.unsplash.com/photo-1513475382585-d06e58bcb0e0?w=400',
    category: 'Books',
    sellerId: 'seller3',
    sellerName: 'John Davis',
    isVerifiedStudent: true,
  ),
  Item(
    id: '4',
    title: 'Wartage booden furniture',
    price: 19.00,
    imageUrl: 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=400',
    category: 'Campus/Building',
    sellerId: 'seller4',
    sellerName: 'Emily Brown',
    sellerMajorYear: 'Architecture / Year 4',
    isVerifiedStudent: true,
    availableColors: ['Ure'],
  ),
];
