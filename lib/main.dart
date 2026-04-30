import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const CompPriceApp());
}

class CompPriceApp extends StatelessWidget {
  const CompPriceApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Colors.deepPurple;
    return MaterialApp(
      title: 'CompPrice',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: seed),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: const CompareScreen(),
    );
  }
}

@immutable
class Product {
  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
  });

  final String id;
  final String name;
  final double price;
  final double quantity;

  double get unitPrice => price / quantity;
}

double? _parseDecimal(String input) {
  return double.tryParse(input.replaceAll(',', '.'));
}

final List<TextInputFormatter> _decimalInputFormatters = [
  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
  TextInputFormatter.withFunction((oldValue, newValue) {
    final separators =
        '.'.allMatches(newValue.text).length +
        ','.allMatches(newValue.text).length;
    return separators > 1 ? oldValue : newValue;
  }),
];

class CompareScreen extends StatefulWidget {
  const CompareScreen({super.key});

  @override
  State<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen> {
  final List<Product> _products = [];
  int _nextId = 1;

  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _priceController.addListener(_onInputChanged);
    _quantityController.addListener(_onInputChanged);
  }

  @override
  void dispose() {
    _priceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _onInputChanged() {
    setState(() {});
  }

  bool get _canAdd {
    final price = _parseDecimal(_priceController.text);
    final quantity = _parseDecimal(_quantityController.text);
    return price != null &&
        price.isFinite &&
        price >= 0 &&
        quantity != null &&
        quantity.isFinite &&
        quantity > 0;
  }

  void _addProduct(double price, double quantity) {
    setState(() {
      final id = _nextId.toString();
      _products.add(
        Product(
          id: id,
          name: 'Product $_nextId',
          price: price,
          quantity: quantity,
        ),
      );
      _nextId++;
    });
  }

  void _deleteProduct(String id) {
    setState(() {
      _products.removeWhere((p) => p.id == id);
    });
  }

  void _handleAddPressed() {
    final price = _parseDecimal(_priceController.text);
    final quantity = _parseDecimal(_quantityController.text);
    if (price == null || quantity == null) return;
    _addProduct(price, quantity);
    _priceController.clear();
    _quantityController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final double? minUnitPrice = _products.isEmpty
        ? null
        : _products.map((p) => p.unitPrice).reduce((a, b) => a < b ? a : b);

    return Scaffold(
      appBar: AppBar(title: const Text('CompPrice')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'Цена',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: _decimalInputFormatters,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _quantityController,
                      decoration: const InputDecoration(
                        labelText: 'Количество',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: _decimalInputFormatters,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _canAdd ? _handleAddPressed : null,
                child: const Text('Добавить'),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _products.isEmpty
                    ? const _EmptyState()
                    : ListView.builder(
                        itemCount: _products.length,
                        itemBuilder: (context, index) {
                          final product = _products[index];
                          final isBest =
                              minUnitPrice != null &&
                              product.unitPrice == minUnitPrice;
                          return _ProductRow(
                            key: ValueKey(product.id),
                            product: product,
                            isBest: isBest,
                            onDelete: () => _deleteProduct(product.id),
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

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Text(
        'Добавьте товар для сравнения',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _ProductRow extends StatelessWidget {
  const _ProductRow({
    super.key,
    required this.product,
    required this.isBest,
    required this.onDelete,
  });

  final Product product;
  final bool isBest;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final unitPriceText = product.unitPrice.toStringAsFixed(2);
    final priceText = product.price.toString();
    final quantityText = product.quantity.toString();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: isBest ? colorScheme.tertiaryContainer : null,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: isBest
            ? Icon(Icons.star, color: colorScheme.onTertiaryContainer)
            : null,
        title: Text(
          product.name,
          style: TextStyle(
            color: isBest ? colorScheme.onTertiaryContainer : null,
          ),
        ),
        subtitle: Text(
          'Цена: $priceText · Количество: $quantityText\nЗа единицу: $unitPriceText',
          style: TextStyle(
            color: isBest ? colorScheme.onTertiaryContainer : null,
          ),
        ),
        isThreeLine: true,
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          color: isBest ? colorScheme.onTertiaryContainer : null,
          onPressed: onDelete,
          tooltip: 'Удалить',
        ),
      ),
    );
  }
}
