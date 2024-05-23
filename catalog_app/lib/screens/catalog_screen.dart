import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../services/api_services.dart';
import '../services/local_storage.dart';
import 'cart_screen.dart';

class CatalogScreen extends StatefulWidget {
  @override
  _CatalogScreenState createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {

  // Variables
  final ApiService _apiService = ApiService();
  final LocalStorageService _localStorageService = LocalStorageService();
  List<Product> _products = [];
  bool _isLoading = true;
  bool _isFetchingMore = false;
  int _currentPage = 1;
  final int _limit = 20;
  final ScrollController _scrollController = ScrollController();

  List<CartItem> _cartItems = [];

  @override
  void initState() {
    super.initState();
    print('Initializing CatalogScreen...');
    _loadProducts();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && !_isFetchingMore) {
        _fetchMoreProducts();
      }
    });
  }
  // Not sure if naming convention is correct, but I think it's fine
  // Future is soo cool, it's like a promise in JS, but here i have 3 states, completed, error, and uncompleted
  // makes it easier to manage the state of the app
  Future<void> _loadProducts() async {
    print('Loading products...');
    try {
      // Check if local database is empty
      int productCount = await _localStorageService.getProductCount();
      if (productCount == 0) {
        // Fetch from API and store in local database
        List<Product> products = await _apiService.fetchProducts(_currentPage);
        for (var product in products) {
          await _localStorageService.insertProduct(product);
        }
      }
      // Fetch from local database
      List<Product> products = await _localStorageService.getProducts(limit: _limit, offset: 0);
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching products: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  //More FUTURES!

  Future<void> _fetchMoreProducts() async {
    setState(() {
      _isFetchingMore = true;
    });

    try {
      _currentPage++;
      int offset = (_currentPage - 1) * _limit;
      List<Product> moreProducts = await _localStorageService.getProducts(limit: _limit, offset: offset);
      setState(() {
        _products.addAll(moreProducts);
        _isFetchingMore = false;
      });
    } catch (e) {
      print('Error fetching more products: $e');
      setState(() {
        _isFetchingMore = false;
      });
    }
  }
  // Adding to cart...
  void _addToCart(Product product, int quantity) {
    setState(() {
      int index = _cartItems.indexWhere((item) => item.product.id == product.id);
      if (index != -1) {
        _cartItems[index].quantity += quantity;
      } else {
        _cartItems.add(CartItem(product: product, quantity: quantity));
      }
    });
  }
  //Clear...
  void _clearCart() {
    setState(() {
      _cartItems.clear();
    });
  }
  //Navigation is easier in Flutter
  void _goToCart() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartScreen(
          cartItems: _cartItems,
          onClearCart: _clearCart,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
//  this way of making UI Gives more control than any html, react components, or any other UI framework, it's like a blank canvas
// The Documentation for everything has been extremly positive so far. 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF6707FF),
              Color(0xCCB01DDD),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'E-Commerce Catalog!',
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.shopping_cart, color: Colors.white),
                      onPressed: _goToCart,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(8.0),
                        itemCount: _products.length + (_isFetchingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _products.length) {
                            return Center(child: CircularProgressIndicator());
                          }
                          final product = _products[index];
                          return ProductCard(
                            product: product,
                            onAddToCart: _addToCart,
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
//Stateful Widgets basically give me the ability to make the state IMMUTABLE, based on the documentation this is the choice when a widget needs to change dynamically
// In both React and React Native, the state is mutable, but here in Flutter, the state is immutable, and i have to use setState to change the state of the widget
// Redux in React is used to acheive this, and its quite hard..
class ProductCard extends StatefulWidget {
  final Product product;
  final Function(Product, int) onAddToCart;

  const ProductCard({
    Key? key,
    required this.product,
    required this.onAddToCart,
  }) : super(key: key);

  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  int _quantity = 0;

  void _incrementQuantity() {
    setState(() {
      _quantity++;
    });
  }

  void _decrementQuantity() {
    if (_quantity > 0) {
      setState(() {
        _quantity--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Color(0xFF9C6FE4),
              Color(0xFF7042C0),
            ],
          ),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'SKU: ${widget.product.id}  ${widget.product.inStock ? 'In Stock' : 'Out of Stock'}',
                      style: TextStyle(
                        fontSize: 14.0,
                        color: widget.product.inStock ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: widget.product.imageUrl.isNotEmpty
                        ? Image.network(widget.product.imageUrl)
                        : Container(color: Colors.grey[200]),
                  ),
                ],
              ),
              SizedBox(height: 8.0),
              Text(
                widget.product.name,
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 4.0),
              Text(
                'RM${widget.product.price.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.green[100],
                ),
              ),
              SizedBox(height: 8.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('UNIT', style: TextStyle(color: Colors.white)),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove, color: Colors.white),
                        onPressed: _decrementQuantity,
                      ),
                      Text(
                        _quantity.toString(),
                        style: TextStyle(color: Colors.white),
                      ),
                      IconButton(
                        icon: Icon(Icons.add, color: Colors.white),
                        onPressed: _incrementQuantity,
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 8.0),
              ElevatedButton(
                onPressed: _quantity > 0
                    ? () {
                        widget.onAddToCart(widget.product, _quantity);
                        setState(() {
                          _quantity = 0;
                        });
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xCCB01DDD),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Center(child: Text('Add to Cart' , style: TextStyle(color: Colors.white)),),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
