import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/map_coordinates.dart';
import 'package:peta_waktu/main.dart';
import '../../../dashboard/models/historical_event.dart'; 

const Color _tealGradientStart = Color(0xFF00796B);
const Color _tealGradientEnd = Color(0xFF26A69A);

class AddEventScreen extends StatefulWidget {
  final HistoricalEvent? eventToEdit;

  const AddEventScreen({super.key, this.eventToEdit});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();

  String? _selectedLocation;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.eventToEdit != null) {
      _titleController.text = widget.eventToEdit!.title;
      _descController.text = widget.eventToEdit!.description;
      _yearController.text = widget.eventToEdit!.year.toString();
      _imageController.text = widget.eventToEdit!.imageUrl;
      _selectedLocation = widget.eventToEdit!.locationId;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _yearController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  String _formatLocationName(String id) {
    return id
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  Future<void> _submitEvent() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap pilih lokasi kejadian')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final int year = int.parse(_yearController.text);
      final data = {
        'title': _titleController.text.trim(),
        'description': _descController.text.trim(),
        'year': year,
        'imageUrl': _imageController.text.trim(),
        'location_id': _selectedLocation,
        'updated_at': FieldValue.serverTimestamp(),
      };

      if (widget.eventToEdit != null) {
        await FirebaseFirestore.instance
            .collection('historical_events')
            .doc(widget.eventToEdit!.id)
            .update(data);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Peristiwa berhasil diperbarui!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        data['created_at'] = FieldValue.serverTimestamp();
        await FirebaseFirestore.instance
            .collection('historical_events')
            .add(data);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Peristiwa berhasil ditambahkan!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldColor,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField(
                      controller: _titleController,
                      label: 'Judul Peristiwa',
                      icon: Icons.title,
                      validator: (v) =>
                          v!.isEmpty ? 'Judul tidak boleh kosong' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildDropdownLocation(),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _yearController,
                            label: 'Tahun (Masehi)',
                            icon: Icons.calendar_today,
                            inputType: TextInputType.number,
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Wajib diisi';
                              if (int.tryParse(v) == null) return 'Harus angka';
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _imageController,
                      label: 'URL Gambar',
                      icon: Icons.image_outlined,
                      validator: (v) =>
                          v!.isEmpty ? 'URL Gambar wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _descController,
                      label: 'Deskripsi Singkat',
                      icon: Icons.description_outlined,
                      maxLines: 4,
                      validator: (v) =>
                          v!.isEmpty ? 'Deskripsi tidak boleh kosong' : null,
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitEvent,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _tealGradientStart,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2),
                              )
                            : Text(
                                widget.eventToEdit != null
                                    ? 'UPDATE DATA'
                                    : 'SIMPAN DATA',
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_tealGradientStart, _tealGradientEnd],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              const SizedBox(width: 8),
              Text(
                widget.eventToEdit != null
                    ? "Edit Peristiwa"
                    : "Tambah Peristiwa",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownLocation() {
    return DropdownButtonFormField<String>(
      value: _selectedLocation,
      decoration: InputDecoration(
        labelText: 'Pilih Lokasi Kejadian',
        prefixIcon:
            const Icon(Icons.location_on_outlined, color: _tealGradientStart),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _tealGradientStart, width: 2),
        ),
      ),
      items: MapCoordinates.getAvailableRegions().map((String id) {
        return DropdownMenuItem<String>(
          value: id,
          child: Text(
            _formatLocationName(id),
            style: const TextStyle(color: textColor),
          ),
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          _selectedLocation = newValue;
        });
      },
      validator: (value) => value == null ? 'Lokasi wajib dipilih' : null,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType inputType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: _tealGradientStart),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _tealGradientStart, width: 2),
        ),
      ),
    );
  }
}