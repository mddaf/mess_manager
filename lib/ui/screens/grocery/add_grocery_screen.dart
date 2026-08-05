import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../l10n/app_localizations.dart';
import '../../../blocs/auth/auth_bloc.dart';
import '../../../blocs/auth/auth_state.dart';
import '../../../blocs/mess/mess_bloc.dart';
import '../../../blocs/mess/mess_state.dart';
import '../../../blocs/grocery/grocery_bloc.dart';
import '../../../blocs/grocery/grocery_event.dart';
import '../../../blocs/grocery/grocery_state.dart';
import '../../../data/services/receipt_parser.dart';
import '../../../models/grocery_entry.dart';
import '../../../models/grocery_item.dart';

class AddGroceryScreen extends StatefulWidget {
  final String messId;
  final GroceryEntry? existingEntry;

  const AddGroceryScreen({
    super.key,
    required this.messId,
    this.existingEntry,
  });

  @override
  State<AddGroceryScreen> createState() => _AddGroceryScreenState();
}

class _AddGroceryScreenState extends State<AddGroceryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  String? _imagePath;
  double? _ocrExtractedAmount;
  OcrResult? _lastOcrResult;
  final ImagePicker _picker = ImagePicker();

  // Multi-item breakdown items
  final List<Map<String, TextEditingController>> _itemControllers = [];

  // Preset Category Chips
  final List<Map<String, String>> _categories = [
    {'label': '🍚 Rice & Grains', 'text': 'Rice & Grains'},
    {'label': '🛢️ Oil & Spices', 'text': 'Oil & Spices'},
    {'label': '🥦 Vegetables', 'text': 'Vegetables'},
    {'label': '🍗 Meat & Fish', 'text': 'Meat & Fish'},
    {'label': '🥛 Milk & Eggs', 'text': 'Milk & Eggs'},
    {'label': '🧹 Cleaning', 'text': 'Cleaning & Utility'},
    {'label': '🍿 Snacks & Tea', 'text': 'Snacks & Tea'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existingEntry != null) {
      final e = widget.existingEntry!;
      _descriptionController.text = e.description;
      _amountController.text = e.amount.toStringAsFixed(2);
      _ocrExtractedAmount = e.ocrExtractedAmount;
      if (e.date.isNotEmpty) {
        try {
          _selectedDate = DateTime.parse(e.date);
        } catch (_) {}
      }
      for (final item in e.items) {
        _itemControllers.add({
          'name': TextEditingController(text: item.name),
          'price': TextEditingController(text: item.price.toStringAsFixed(0)),
        });
      }
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    for (final item in _itemControllers) {
      item['name']?.dispose();
      item['price']?.dispose();
    }
    super.dispose();
  }

  void _addBreakdownItem({String name = '', String price = ''}) {
    setState(() {
      _itemControllers.add({
        'name': TextEditingController(text: name),
        'price': TextEditingController(text: price),
      });
    });
    _calculateBreakdownTotal();
  }

  void _removeBreakdownItem(int index) {
    setState(() {
      _itemControllers[index]['name']?.dispose();
      _itemControllers[index]['price']?.dispose();
      _itemControllers.removeAt(index);
    });
    _calculateBreakdownTotal();
  }

  void _calculateBreakdownTotal() {
    if (_itemControllers.isEmpty) return;
    double sum = 0.0;
    final itemNames = <String>[];

    for (final item in _itemControllers) {
      final name = item['name']?.text.trim() ?? '';
      final priceStr = item['price']?.text.trim() ?? '';
      final price = double.tryParse(priceStr) ?? 0.0;
      if (price > 0) sum += price;
      if (name.isNotEmpty) itemNames.add(name);
    }

    if (sum > 0) {
      _amountController.text = sum.toStringAsFixed(2);
    }
    if (itemNames.isNotEmpty && _descriptionController.text.isEmpty) {
      _descriptionController.text = itemNames.join(', ');
    }
  }

  Future<void> _pickAndScanReceipt(ImageSource source) async {
    try {
      final file = await _picker.pickImage(source: source, imageQuality: 85);
      if (file != null) {
        setState(() {
          _imagePath = file.path;
        });

        if (!mounted) return;
        context.read<GroceryBloc>().add(ScanReceiptRequested(file.path));

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                ),
                SizedBox(width: 12),
                Text('Scanning receipt (Handwritten & Printed text)...'),
              ],
            ),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image capture failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showScanSourceModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Scan Receipt / Paper Bazar Slip',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Detects handwritten paper slips and printed receipts in Bangla & English.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _pickAndScanReceipt(ImageSource.camera);
                    },
                    icon: const Icon(Icons.camera_alt_rounded),
                    label: const Text('Camera'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _pickAndScanReceipt(ImageSource.gallery);
                    },
                    icon: const Icon(Icons.photo_library_rounded),
                    label: const Text('Gallery'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showOcrReviewDialog(OcrResult ocr) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        builder: (ctx, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                const Icon(Icons.document_scanner_rounded, color: Colors.deepOrange, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Scan Results',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Chip(
                  avatar: Icon(
                    ocr.extractedTotal != null ? Icons.check_circle_rounded : Icons.help_outline_rounded,
                    size: 16,
                    color: ocr.extractedTotal != null ? Colors.green : Colors.orange,
                  ),
                  label: Text(
                    ocr.extractedTotal != null
                        ? 'Detected: ৳${ocr.extractedTotal!.toStringAsFixed(0)}'
                        : 'No clear total',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  backgroundColor: ocr.extractedTotal != null ? Colors.green.shade50 : Colors.orange.shade50,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Candidate Amounts Found (Pills)
            if (ocr.candidateAmounts.isNotEmpty) ...[
              const Text('Tap detected amount to set as Total Amount:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ocr.candidateAmounts.map((amt) {
                  final isSelected = _amountController.text == amt.toStringAsFixed(2);
                  return ActionChip(
                    avatar: Icon(
                      isSelected ? Icons.check_rounded : Icons.monetization_on_outlined,
                      size: 16,
                      color: isSelected ? Colors.white : Colors.deepOrange,
                    ),
                    label: Text(
                      '৳${amt.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.deepOrange.shade900,
                      ),
                    ),
                    backgroundColor: isSelected ? Colors.deepOrange : Colors.deepOrange.shade50,
                    onPressed: () {
                      setState(() {
                        _amountController.text = amt.toStringAsFixed(2);
                        _ocrExtractedAmount = amt;
                      });
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Amount set to ৳${amt.toStringAsFixed(2)}')),
                      );
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],

            // Itemized Items Detected
            if (ocr.parsedItems.isNotEmpty) ...[
              const Text('Detected Items (Tap + to add to breakdown):',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 8),
              Card(
                child: Column(
                  children: ocr.parsedItems.map((item) {
                    return ListTile(
                      title: Text(item.name, style: const TextStyle(fontSize: 14)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('৳${item.price.toStringAsFixed(0)}',
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline_rounded, color: Colors.green),
                            onPressed: () {
                              _addBreakdownItem(
                                name: item.name,
                                price: item.price.toStringAsFixed(0),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Added "${item.name}" to breakdown')),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Raw OCR Text Accordion
            ExpansionTile(
              title: const Text('Raw Detected Text (Handwritten / Printed)', style: TextStyle(fontSize: 13)),
              leading: const Icon(Icons.text_snippet_outlined),
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SelectableText(
                    ocr.rawText.isNotEmpty ? ocr.rawText : 'No text recognized',
                    style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
              child: const Text('Close Review'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final amount = double.parse(_amountController.text);
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);

      final authState = context.read<AuthBloc>().state;
      String uid = 'user';
      String name = 'Member';
      if (authState is Authenticated) {
        uid = authState.user.uid;
        name = authState.user.name;
      }

      final messState = context.read<MessBloc>().state;
      bool isManager = false;
      if (messState is MessLoaded) {
        isManager = (messState.mess.currentManagerId == uid);
      }

      final status = isManager ? 'approved' : 'pending';

      final List<GroceryItem> parsedItems = [];
      for (final item in _itemControllers) {
        final iName = item['name']?.text.trim() ?? '';
        final iPriceStr = item['price']?.text.trim() ?? '';
        final iPrice = double.tryParse(iPriceStr) ?? 0.0;
        if (iName.isNotEmpty && iPrice > 0) {
          parsedItems.add(GroceryItem(name: iName, price: iPrice));
        }
      }

      if (widget.existingEntry != null) {
        // EDIT MODE: Members can edit, but requires manager approval
        final updatedEntry = widget.existingEntry!.copyWith(
          description: _descriptionController.text.trim(),
          amount: amount,
          ocrExtractedAmount: _ocrExtractedAmount,
          date: dateStr,
          items: parsedItems,
          status: status,
        );

        context.read<GroceryBloc>().add(
              UpdateGroceryRequested(
                messId: widget.messId,
                entry: updatedEntry,
                receiptImagePath: _imagePath,
              ),
            );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isManager
                  ? 'Grocery entry updated & approved!'
                  : 'Grocery edit submitted! Waiting for Manager approval.',
            ),
            backgroundColor: isManager ? Colors.green : Colors.orange,
          ),
        );
      } else {
        // ADD MODE
        final entry = GroceryEntry(
          id: 'groc_${DateTime.now().millisecondsSinceEpoch}',
          purchasedBy: uid,
          purchaserName: name,
          description: _descriptionController.text.trim(),
          amount: amount,
          ocrExtractedAmount: _ocrExtractedAmount,
          date: dateStr,
          items: parsedItems,
          status: status,
          createdAt: DateTime.now(),
        );

        context.read<GroceryBloc>().add(
              AddGroceryRequested(
                messId: widget.messId,
                entry: entry,
                receiptImagePath: _imagePath,
              ),
            );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isManager
                  ? 'Grocery entry saved!'
                  : 'Grocery entry added! Waiting for Manager approval.',
            ),
            backgroundColor: isManager ? Colors.green : Colors.orange,
          ),
        );
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isEditMode = widget.existingEntry != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Grocery Entry' : l10n.addGrocery),
        actions: [
          IconButton(
            icon: const Icon(Icons.document_scanner_rounded),
            tooltip: 'Scan / Upload Receipt',
            onPressed: _showScanSourceModal,
          ),
        ],
      ),
      body: BlocListener<GroceryBloc, GroceryState>(
        listener: (context, state) {
          if (state is GroceryLoaded && state.ocrResult != null) {
            final ocr = state.ocrResult!;
            _lastOcrResult = ocr;

            // Auto-fill amount if empty or user tapped optional receipt upload
            if (ocr.extractedTotal != null) {
              setState(() {
                _ocrExtractedAmount = ocr.extractedTotal;
                if (_amountController.text.isEmpty) {
                  _amountController.text = ocr.extractedTotal!.toStringAsFixed(2);
                }
              });
            }

            // Auto-fill description if empty and items detected
            if (_descriptionController.text.trim().isEmpty && ocr.extractedItems.isNotEmpty) {
              setState(() {
                _descriptionController.text = ocr.extractedItems.join(', ');
              });
            }

            // Auto-fill item breakdown if items detected and breakdown is empty
            if (ocr.parsedItems.isNotEmpty && _itemControllers.isEmpty) {
              for (final item in ocr.parsedItems) {
                _addBreakdownItem(
                  name: item.name,
                  price: item.price.toStringAsFixed(0),
                );
              }
            }

            _showOcrReviewDialog(ocr);
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Scanner Banner Card ────────────────────────────────
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: _showScanSourceModal,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.document_scanner_rounded,
                                color: theme.colorScheme.primary, size: 28),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Attach Receipt Photo (Optional)',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Auto-scans handwritten & printed slips on upload (Bangla/English)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios_rounded,
                              size: 16, color: theme.colorScheme.primary),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ── Amount & Date Section ──────────────────────────────
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total Amount & Date',
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: TextFormField(
                                controller: _amountController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                                decoration: InputDecoration(
                                  labelText: l10n.amount,
                                  prefixIcon: const Padding(
                                    padding: EdgeInsets.all(12.0),
                                    child: Text('৳',
                                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                                  ),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) return l10n.amount;
                                  if (double.tryParse(v) == null) return 'Enter valid number';
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: InkWell(
                                onTap: _selectDate,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey.shade400),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    children: [
                                      const Icon(Icons.calendar_today_rounded, size: 18),
                                      const SizedBox(height: 4),
                                      Text(
                                        DateFormat('dd MMM yyyy').format(_selectedDate),
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (_ocrExtractedAmount != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.check_circle_rounded, color: Colors.green, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                'OCR Detected: ৳${_ocrExtractedAmount!.toStringAsFixed(2)}',
                                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              if (_lastOcrResult != null)
                                TextButton(
                                  onPressed: () => _showOcrReviewDialog(_lastOcrResult!),
                                  child: const Text('Review OCR', style: TextStyle(fontSize: 12)),
                                ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Description & Category Chips ───────────────────────
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Item Description',
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _descriptionController,
                          maxLines: 2,
                          decoration: InputDecoration(
                            labelText: l10n.description,
                            hintText: 'e.g. Rice 5kg, Soybean Oil 2L, Eggs 1 Dozen',
                            prefixIcon: const Icon(Icons.shopping_bag_outlined),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty) ? l10n.description : null,
                        ),
                        const SizedBox(height: 12),

                        const Text('Quick Preset Categories:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 6),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _categories.map((cat) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: ChoiceChip(
                                  label: Text(cat['label']!),
                                  selected: false,
                                  onSelected: (_) {
                                    final current = _descriptionController.text.trim();
                                    final catText = cat['text']!;
                                    if (current.isEmpty) {
                                      _descriptionController.text = catText;
                                    } else if (!current.contains(catText)) {
                                      _descriptionController.text = '$current, $catText';
                                    }
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Multi-Item Breakdown Section ───────────────────────
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('Itemized Breakdown (Optional)',
                                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                            const Spacer(),
                            TextButton.icon(
                              onPressed: () => _addBreakdownItem(),
                              icon: const Icon(Icons.add_rounded, size: 18),
                              label: const Text('Add Item'),
                            ),
                          ],
                        ),
                        if (_itemControllers.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              'Tap "+ Add Item" or scan a receipt to break down individual item prices.',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _itemControllers.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: TextField(
                                        controller: _itemControllers[index]['name'],
                                        decoration: InputDecoration(
                                          hintText: 'Item name (e.g. Rice)',
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                        ),
                                        onChanged: (_) => _calculateBreakdownTotal(),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      flex: 2,
                                      child: TextField(
                                        controller: _itemControllers[index]['price'],
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                          hintText: 'Price',
                                          prefixText: '৳ ',
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                        ),
                                        onChanged: (_) => _calculateBreakdownTotal(),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
                                      onPressed: () => _removeBreakdownItem(index),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Receipt Photo Attachment Preview ──────────────────
                if (_imagePath != null) ...[
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: kIsWeb
                                ? Image.network(_imagePath!, width: 60, height: 60, fit: BoxFit.cover)
                                : Image.file(File(_imagePath!), width: 60, height: 60, fit: BoxFit.cover),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Receipt Photo Attached', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                Text('Will be saved with entry', style: TextStyle(fontSize: 11, color: Colors.grey)),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, color: Colors.red),
                            onPressed: () => setState(() => _imagePath = null),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // ── Save Entry Button ─────────────────────────────────
                ElevatedButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.save_rounded),
                  label: Text(
                    l10n.save,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 4,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

