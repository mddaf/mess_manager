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
import '../../../models/member.dart';

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
  final _amountFromMessController = TextEditingController();
  final _amountFromMemberController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  // Mode Selection: 'quick' (Total Amount & Description) VS 'itemized' (Itemized Breakdown)
  String _entryMode = 'quick';

  String _paymentSource = 'mess_fund'; // mess_fund, member_pocket, split
  String? _selectedPurchaserId;
  String? _selectedPurchaserName;

  String? _imagePath;
  double? _ocrExtractedAmount;
  final ImagePicker _picker = ImagePicker();

  final List<Map<String, TextEditingController>> _itemControllers = [];

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
      _paymentSource = e.paymentSource;
      _amountFromMessController.text = e.amountFromMess > 0 ? e.amountFromMess.toStringAsFixed(0) : '';
      _amountFromMemberController.text = e.amountFromMember > 0 ? e.amountFromMember.toStringAsFixed(0) : '';
      _selectedPurchaserId = e.purchasedBy;
      _selectedPurchaserName = e.purchaserName;
      if (e.date.isNotEmpty) {
        try {
          _selectedDate = DateTime.parse(e.date);
        } catch (_) {}
      }

      if (e.items.isNotEmpty) {
        _entryMode = 'itemized';
        for (final item in e.items) {
          _itemControllers.add({
            'name': TextEditingController(text: item.name),
            'price': TextEditingController(text: item.price.toStringAsFixed(0)),
          });
        }
      } else {
        _entryMode = 'quick';
      }
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _amountFromMessController.dispose();
    _amountFromMemberController.dispose();
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
    if (_entryMode != 'itemized' || _itemControllers.isEmpty) return;
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
          SnackBar(content: Text('Failed to pick image: $e'), backgroundColor: Colors.red),
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
          children: [
            const Text(
              'Attach / Scan Receipt Photo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const CircleAvatar(child: Icon(Icons.camera_alt_rounded)),
              title: const Text('Take Photo with Camera'),
              onTap: () {
                Navigator.pop(ctx);
                _pickAndScanReceipt(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const CircleAvatar(child: Icon(Icons.photo_library_rounded)),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(ctx);
                _pickAndScanReceipt(ImageSource.gallery);
              },
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
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.psychology_rounded, color: Colors.green, size: 28),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text('OCR Receipt Recognized',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (ocr.extractedTotal != null) ...[
              Text(
                'Detected Amount: ৳${ocr.extractedTotal!.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green),
              ),
              const SizedBox(height: 16),
            ],

            if (ocr.parsedItems.isNotEmpty) ...[
              const Text('Detected Items (Tap + to add to breakdown):',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                constraints: const BoxConstraints(maxHeight: 180),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: ListView(
                  shrinkWrap: true,
                  children: ocr.parsedItems.map((item) {
                    return ListTile(
                      dense: true,
                      title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('৳${item.price.toStringAsFixed(0)}',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline_rounded, color: Colors.blue),
                            onPressed: () {
                              setState(() {
                                _entryMode = 'itemized';
                              });
                              _addBreakdownItem(
                                name: item.name,
                                price: item.price.toStringAsFixed(0),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Added "${item.name}" to itemized bill breakdown')),
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
      double amount = double.tryParse(_amountController.text.trim()) ?? 0.0;

      final List<GroceryItem> parsedItems = [];

      if (_entryMode == 'itemized') {
        amount = 0.0;
        for (final item in _itemControllers) {
          final iName = item['name']?.text.trim() ?? '';
          final iPriceStr = item['price']?.text.trim() ?? '';
          final iPrice = double.tryParse(iPriceStr) ?? 0.0;
          if (iName.isNotEmpty && iPrice > 0) {
            parsedItems.add(GroceryItem(name: iName, price: iPrice));
            amount += iPrice;
          }
        }
        if (parsedItems.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('⚠️ Please add at least 1 itemized item in Itemized Mode'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        _amountController.text = amount.toStringAsFixed(2);
      }

      if (amount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ Total Amount must be a positive number (> 0)'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      double amtMess = 0.0;
      double amtMember = 0.0;

      if (_paymentSource == 'mess_fund') {
        amtMess = amount;
        amtMember = 0.0;
      } else if (_paymentSource == 'member_pocket') {
        amtMess = 0.0;
        amtMember = amount;
      } else {
        amtMess = double.tryParse(_amountFromMessController.text.trim()) ?? 0.0;
        amtMember = double.tryParse(_amountFromMemberController.text.trim()) ?? 0.0;

        if ((amtMess + amtMember - amount).abs() > 0.01) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '⚠️ Split amounts (Mess: ৳$amtMess + Member: ৳$amtMember = ৳${amtMess + amtMember}) '
                'must equal Total Amount (৳$amount)',
              ),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }

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

      final targetUid = (isManager && _selectedPurchaserId != null) ? _selectedPurchaserId! : uid;
      final targetName = (isManager && _selectedPurchaserName != null) ? _selectedPurchaserName! : name;

      final status = isManager ? 'approved' : 'pending';

      if (widget.existingEntry != null) {
        final updatedEntry = widget.existingEntry!.copyWith(
          purchasedBy: targetUid,
          purchaserName: targetName,
          description: _descriptionController.text.trim(),
          amount: amount,
          paymentSource: _paymentSource,
          amountFromMess: amtMess,
          amountFromMember: amtMember,
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
        final entry = GroceryEntry(
          id: 'groc_${DateTime.now().millisecondsSinceEpoch}',
          purchasedBy: targetUid,
          purchaserName: targetName,
          description: _descriptionController.text.trim(),
          amount: amount,
          paymentSource: _paymentSource,
          amountFromMess: amtMess,
          amountFromMember: amtMember,
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
                  ? 'Grocery entry saved & approved!'
                  : 'Grocery entry saved! Pending Manager approval (balances will update upon approval).',
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

    final authState = context.watch<AuthBloc>().state;
    final currentUserId = authState is Authenticated ? authState.user.uid : '';

    final messState = context.watch<MessBloc>().state;
    List<Member> members = [];
    bool isManager = false;
    if (messState is MessLoaded) {
      members = messState.members.where((m) => m.status == 'approved').toList();
      isManager = (messState.mess.currentManagerId == currentUserId);
    }

    if (_selectedPurchaserId == null && members.isNotEmpty) {
      final cur = members.firstWhere((m) => m.userId == currentUserId, orElse: () => members.first);
      _selectedPurchaserId = cur.userId;
      _selectedPurchaserName = cur.name;
    }

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

            if (ocr.extractedTotal != null) {
              setState(() {
                _ocrExtractedAmount = ocr.extractedTotal;
                if (_amountController.text.isEmpty) {
                  _amountController.text = ocr.extractedTotal!.toStringAsFixed(2);
                }
              });
            }

            if (_descriptionController.text.trim().isEmpty && ocr.extractedItems.isNotEmpty) {
              setState(() {
                _descriptionController.text = ocr.extractedItems.join(', ');
              });
            }

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
                // ── MUTUAL EXCLUSION MODE SELECTOR ─────────────────────
                Card(
                  elevation: 3,
                  color: theme.colorScheme.surfaceContainerHighest,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Select Grocery Entry Mode (Choose One):',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        const SizedBox(height: 8),
                        SegmentedButton<String>(
                          segments: const [
                            ButtonSegment<String>(
                              value: 'quick',
                              label: Text('📝 Quick Total & Description'),
                              icon: Icon(Icons.notes_rounded, size: 18),
                            ),
                            ButtonSegment<String>(
                              value: 'itemized',
                              label: Text('🛒 Itemized Bill Breakdown'),
                              icon: Icon(Icons.receipt_long_rounded, size: 18),
                            ),
                          ],
                          selected: {_entryMode},
                          onSelectionChanged: (Set<String> newSelection) {
                            setState(() {
                              _entryMode = newSelection.first;
                              if (_entryMode == 'itemized' && _itemControllers.isEmpty) {
                                _addBreakdownItem();
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Manager Target Member Selector ────────────────────
                if (isManager && members.isNotEmpty) ...[
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: DropdownButtonFormField<String>(
                        value: _selectedPurchaserId,
                        decoration: const InputDecoration(
                          labelText: 'Purchased By (Select Target Member)',
                          prefixIcon: Icon(Icons.person_rounded),
                          border: OutlineInputBorder(),
                        ),
                        items: members.map((m) {
                          return DropdownMenuItem(
                            value: m.userId,
                            child: Text('${m.name} (${m.email})'),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedPurchaserId = val;
                              _selectedPurchaserName = members.firstWhere((m) => m.userId == val).name;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

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

                // ── MODE 1: QUICK TOTAL & DESCRIPTION MODE ───────────
                if (_entryMode == 'quick') ...[
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Total Amount & Date',
                                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                    color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                                child: const Text('Quick Mode',
                                    style: TextStyle(fontSize: 10, color: Colors.blue, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
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
                                    labelText: 'Total Amount (৳)',
                                    prefixIcon: const Padding(
                                      padding: EdgeInsets.all(12.0),
                                      child: Text('৳',
                                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                                    ),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  validator: (v) {
                                    if (_entryMode != 'quick') return null;
                                    if (v == null || v.trim().isEmpty) return 'Enter total amount';
                                    final numVal = double.tryParse(v.trim());
                                    if (numVal == null || numVal <= 0) {
                                      return 'Must be a positive number (> 0)';
                                    }
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
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Quick Description & Category Presets
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Grocery Description / Items',
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _descriptionController,
                            decoration: InputDecoration(
                              hintText: 'e.g. Rice 5kg, Oil 2L, Vegetables',
                              prefixIcon: const Icon(Icons.description_rounded),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            validator: (v) {
                              if (_entryMode != 'quick') return null;
                              return (v == null || v.trim().isEmpty) ? 'Enter grocery description' : null;
                            },
                          ),
                          const SizedBox(height: 12),
                          const Text('Preset Categories:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: _categories.map((cat) {
                              return ActionChip(
                                label: Text(cat['label']!),
                                onPressed: () {
                                  if (_descriptionController.text.isEmpty) {
                                    _descriptionController.text = cat['text']!;
                                  } else {
                                    _descriptionController.text += ', ${cat['text']}';
                                  }
                                },
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // ── MODE 2: ITEMIZED BREAKDOWN BILL MODE ───────────────
                if (_entryMode == 'itemized') ...[
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Itemized Bill Breakdown',
                                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                              TextButton.icon(
                                onPressed: () => _addBreakdownItem(),
                                icon: const Icon(Icons.add_rounded, size: 18),
                                label: const Text('Add Item'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          if (_itemControllers.isEmpty)
                            const Text(
                              'No itemized breakdown added. Tap "+ Add Item" or scan a receipt.',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            )
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _itemControllers.length,
                              itemBuilder: (ctx, idx) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: TextFormField(
                                          controller: _itemControllers[idx]['name'],
                                          decoration: const InputDecoration(
                                            labelText: 'Item Name',
                                            isDense: true,
                                            border: OutlineInputBorder(),
                                          ),
                                          validator: (v) {
                                            if (_entryMode != 'itemized') return null;
                                            if (v == null || v.trim().isEmpty) return 'Required';
                                            return null;
                                          },
                                          onChanged: (_) => _calculateBreakdownTotal(),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        flex: 2,
                                        child: TextFormField(
                                          controller: _itemControllers[idx]['price'],
                                          keyboardType: TextInputType.number,
                                          decoration: const InputDecoration(
                                            labelText: 'Price (৳)',
                                            isDense: true,
                                            border: OutlineInputBorder(),
                                          ),
                                          validator: (v) {
                                            if (_entryMode != 'itemized') return null;
                                            if (v == null || v.isEmpty) return 'Required';
                                            final p = double.tryParse(v);
                                            if (p == null || p <= 0) return 'Must be > 0';
                                            return null;
                                          },
                                          onChanged: (_) => _calculateBreakdownTotal(),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                                        onPressed: () => _removeBreakdownItem(idx),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),

                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Calculated Total Bill:',
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                              Text(
                                '৳${_amountController.text.isEmpty ? "0.00" : _amountController.text}',
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // ── Required Payment Funding Source Selector ─────────
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Payment Funding Source (Required)',
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        const Text(
                          'Select how this grocery was paid. Money will be deducted from Mess Fund or deposited to Purchaser.',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 12),

                        RadioListTile<String>(
                          title: const Text('🏛️ Paid from Mess Fund / Mess Money'),
                          subtitle: const Text('Deducted from Mess Fund balance'),
                          value: 'mess_fund',
                          groupValue: _paymentSource,
                          onChanged: (val) {
                            if (val != null) setState(() => _paymentSource = val);
                          },
                        ),
                        RadioListTile<String>(
                          title: const Text('💳 Paid from Purchaser\'s Own Pocket'),
                          subtitle: const Text('Credited as Deposit to Purchaser\'s balance'),
                          value: 'member_pocket',
                          groupValue: _paymentSource,
                          onChanged: (val) {
                            if (val != null) setState(() => _paymentSource = val);
                          },
                        ),
                        RadioListTile<String>(
                          title: const Text('⚖️ Split Payment (Partial Mess Fund + Partial Pocket)'),
                          subtitle: const Text('Specify exact split amounts below'),
                          value: 'split',
                          groupValue: _paymentSource,
                          onChanged: (val) {
                            if (val != null) setState(() => _paymentSource = val);
                          },
                        ),

                        if (_paymentSource == 'split') ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _amountFromMessController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'From Mess Fund (৳)',
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (v) {
                                    if (_paymentSource != 'split') return null;
                                    if (v == null || v.trim().isEmpty) return 'Required';
                                    final numVal = double.tryParse(v.trim());
                                    if (numVal == null || numVal < 0) return 'Must be >= 0';
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: _amountFromMemberController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'From Member Pocket (৳)',
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (v) {
                                    if (_paymentSource != 'split') return null;
                                    if (v == null || v.trim().isEmpty) return 'Required';
                                    final numVal = double.tryParse(v.trim());
                                    if (numVal == null || numVal < 0) return 'Must be >= 0';
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Submit Button
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    isEditMode
                        ? 'Save Grocery Edits'
                        : (isManager ? 'Save & Approve Grocery' : 'Submit Grocery (Pending Approval)'),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
