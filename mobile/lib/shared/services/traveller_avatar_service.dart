import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for uploading and managing traveller avatars
class TravellerAvatarService {
  final _client = Supabase.instance.client;
  final _picker = ImagePicker();
  static const _bucketName = 'traveller-avatars';

  String? get _userId => _client.auth.currentUser?.id;

  /// Pick image from gallery
  Future<XFile?> pickImage() async {
    return await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );
  }

  /// Pick image from camera
  Future<XFile?> takePhoto() async {
    return await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );
  }

  /// Upload avatar and return public URL
  Future<String?> uploadAvatar({
    required String travellerId,
    required Uint8List imageBytes,
    String extension = 'jpg',
  }) async {
    if (_userId == null) return null;

    try {
      // File path: userId/travellerId.jpg
      final filePath = '$_userId/$travellerId.$extension';

      // Upload to storage
      await _client.storage.from(_bucketName).uploadBinary(
        filePath,
        imageBytes,
        fileOptions: FileOptions(
          upsert: true,
          contentType: 'image/$extension',
        ),
      );

      // Get public URL
      final publicUrl = _client.storage.from(_bucketName).getPublicUrl(filePath);
      
      return publicUrl;
    } on StorageException catch (e) {
      if (e.statusCode == '404' || e.message.contains('Bucket not found')) {
        print('Error: Storage bucket "$_bucketName" does not exist. Please create it in Supabase Storage.');
        throw Exception('Avatar storage is not configured. Please contact support.');
      }
      print('Error uploading avatar: $e');
      rethrow;
    } catch (e) {
      print('Error uploading avatar: $e');
      return null;
    }
  }

  /// Delete avatar from storage
  Future<bool> deleteAvatar(String travellerId) async {
    if (_userId == null) return false;

    try {
      final extensions = ['jpg', 'jpeg', 'png', 'webp'];
      for (final ext in extensions) {
        try {
          await _client.storage.from(_bucketName).remove(['$_userId/$travellerId.$ext']);
        } catch (_) {}
      }
      return true;
    } catch (e) {
      print('Error deleting avatar: $e');
      return false;
    }
  }

  /// Update traveller's avatar_url in database
  Future<bool> updateTravellerAvatar(String travellerId, String? avatarUrl) async {
    if (_userId == null) return false;

    try {
      await _client
          .from('travellers')
          .update({'avatar_url': avatarUrl})
          .eq('id', travellerId)
          .eq('owner_id', _userId!);
      return true;
    } catch (e) {
      print('Error updating avatar: $e');
      return false;
    }
  }
}

/// Singleton instance
final travellerAvatarService = TravellerAvatarService();
