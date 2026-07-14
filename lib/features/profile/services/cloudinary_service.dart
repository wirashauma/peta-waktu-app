import 'dart:io';

import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CloudinaryService {
  final CloudinaryPublic _cloudinary = CloudinaryPublic(
    dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? 'dzsr1xfvm', // cloud name
    dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? 'peta_waktu_preset', // unsigned upload preset
    cache: false,
  );

  /// Uploads a profile picture to Cloudinary under folder 'user_profiles'
  /// Returns the secure URL on success, or null on failure.
  Future<String?> uploadProfilePicture(File imageFile) async {
    try {
      final res = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          folder: 'user_profiles',
        ),
      );

      return res.secureUrl;
    } on CloudinaryException catch (e) {
      // Cloudinary-specific error
      // You may want to log e.request or e.message in a real app
      return null;
    } catch (e) {
      // Generic error
      return null;
    }
  }
}
