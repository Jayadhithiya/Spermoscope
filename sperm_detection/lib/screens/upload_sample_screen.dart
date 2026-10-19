import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'Urls.dart';

class UploadSampleScreen extends StatefulWidget {
  final String uid;
  final String sampleType;

  const UploadSampleScreen({super.key, required this.uid, required this.sampleType});

  @override
  _UploadSampleScreenState createState() => _UploadSampleScreenState();
}

class _UploadSampleScreenState extends State<UploadSampleScreen> {
  Uint8List? _imageBytes;
  String? _fileName;
  bool _isUploading = false;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _imageBytes = bytes;
          _fileName = image.name;
        });
      }
    } catch (e) {
      _showSnack('Error selecting image: $e', isError: true);
    }
  }

  Future<void> _uploadSampleImage() async {
    if (_imageBytes == null) {
      _showSnack('Please select a specimen image or video frame first', isError: true);
      return;
    }

    setState(() => _isUploading = true);

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${Urls.Url}/upload_sample/${widget.uid}/${widget.sampleType}'),
      );

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          _imageBytes!,
          filename: _fileName ?? 'sample_${widget.sampleType}.jpg',
        ),
      );

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      setState(() => _isUploading = false);

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSnack('Specimen uploaded and queued for motility tracking!');
        Future.delayed(const Duration(milliseconds: 600), () {
          if (mounted) Navigator.pop(context, true);
        });
      } else {
        _showSnack('Upload failed: ${response.statusCode}', isError: true);
      }
    } catch (e) {
      setState(() => _isUploading = false);
      _showSnack('Upload failed: $e', isError: true);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? const Color(0xFFDC2626) : const Color(0xFF059669),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F274A),
        elevation: 0,
        title: Text(
          'Upload Specimen · Sample #${widget.sampleType}',
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: const [
                  BoxShadow(color: Color(0x06000000), blurRadius: 10, offset: Offset(0, 2)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.cloud_upload_rounded, color: Color(0xFF1E3A8A), size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Microscopic Specimen Ingestion',
                              style: TextStyle(color: Color(0xFF0F172A), fontSize: 17, fontWeight: FontWeight.w700),
                            ),
                            Text(
                              'Patient UID: ${widget.uid}  ·  Sample Stage #${widget.sampleType}',
                              style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Upload Drop Zone
                  InkWell(
                    onTap: _pickImage,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      height: 180,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _imageBytes != null ? const Color(0xFF16A34A) : const Color(0xFF93C5FD),
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: _imageBytes != null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 48),
                                  const SizedBox(height: 10),
                                  Text(
                                    _fileName ?? 'Specimen Selected',
                                    style: const TextStyle(color: Color(0xFF0F172A), fontSize: 14, fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Click to select a different file',
                                    style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                                  ),
                                ],
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.add_photo_alternate_outlined, color: Color(0xFF1E3A8A), size: 48),
                                  SizedBox(height: 10),
                                  Text(
                                    'Select Microscopic Frame / Video',
                                    style: TextStyle(color: Color(0xFF0F172A), fontSize: 14, fontWeight: FontWeight.w600),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Supports PNG, JPG, MP4 · Camera / Gallery',
                                    style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons
                  SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _isUploading ? null : _uploadSampleImage,
                      icon: _isUploading
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.rocket_launch_rounded, size: 18),
                      label: Text(_isUploading ? 'Transferring Specimen...' : 'Upload & Run AI Inference'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3A8A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
