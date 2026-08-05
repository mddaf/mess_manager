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
import '../../../models/grocery_entry.dart';

class AddGroceryScreen extends StatefulWidget {
  final String messId;

  const AddGroceryScreen({super.key, required this.messId});

  @override
  State<AddGroceryScreen> createState() => _AddGroceryScreenState();
}

class _AddGroceryScreenState extends State<AddGroceryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  String? _imagePath;
  double? _ocrExtractedAmount;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickAndScanReceipt() async {
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() {
        _imagePath = file.path;
      });

      if (!mounted) return;
      context.read<GroceryBloc>().add(ScanReceiptRequested(file.path));
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final amount = double.parse(_amountController.text);
      final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

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

      final entry = GroceryEntry(
        id: 'groc_${DateTime.now().millisecondsSinceEpoch}',
        purchasedBy: uid,
        purchaserName: name,
        description: _descriptionController.text.trim(),
        amount: amount,
        ocrExtractedAmount: _ocrExtractedAmount,
        date: dateStr,
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

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.addGrocery),
      ),
      body: BlocListener<GroceryBloc, GroceryState>(
        listener: (context, state) {
          if (state is GroceryLoaded && state.ocrResult != null) {
            final ocr = state.ocrResult!;
            if (ocr.extractedTotal != null) {
              setState(() {
                _ocrExtractedAmount = ocr.extractedTotal;
                _amountController.text = ocr.extractedTotal!.toStringAsFixed(2);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('OCR Extracted Amount: ৳ ${ocr.extractedTotal}'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: l10n.description,
                    prefixIcon: const Icon(Icons.shopping_bag_outlined),
                  ),
                  validator: (v) => (v == null || v.isEmpty) ? l10n.description : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: l10n.amount,
                    prefixIcon: const Icon(Icons.attach_money_rounded),
                  ),
                  validator: (v) => (v == null || v.isEmpty) ? l10n.amount : null,
                ),
                const SizedBox(height: 20),
                OutlinedButton.icon(
                  icon: const Icon(Icons.document_scanner_rounded),
                  label: Text(l10n.scanReceipt),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _pickAndScanReceipt,
                ),
                if (_ocrExtractedAmount != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      '✅ OCR Auto-detected Amount: ৳ $_ocrExtractedAmount',
                      style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                  ),
                const Spacer(),
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    l10n.save,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
