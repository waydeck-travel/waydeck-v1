import 'dart:math';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Trip Share model
class TripShare {
  final String id;
  final String tripId;
  final String shareCode;
  final String sharedBy;
  final String? sharedWithEmail;
  final String? sharedWithUserId;
  final String permission;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? claimedAt;

  const TripShare({
    required this.id,
    required this.tripId,
    required this.shareCode,
    required this.sharedBy,
    this.sharedWithEmail,
    this.sharedWithUserId,
    required this.permission,
    required this.isActive,
    required this.createdAt,
    this.claimedAt,
  });

  factory TripShare.fromJson(Map<String, dynamic> json) {
    return TripShare(
      id: json['id'] as String,
      tripId: json['trip_id'] as String,
      shareCode: json['share_code'] as String,
      sharedBy: json['shared_by'] as String,
      sharedWithEmail: json['shared_with_email'] as String?,
      sharedWithUserId: json['shared_with_user_id'] as String?,
      permission: json['permission'] as String,
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      claimedAt: json['claimed_at'] != null
          ? DateTime.parse(json['claimed_at'] as String)
          : null,
    );
  }

  /// Generate share link
  String get shareLink => 'https://waydeck.app/share/$shareCode';
}

/// Trip Share Service
class TripShareService {
  final _client = Supabase.instance.client;

  String? get _userId => _client.auth.currentUser?.id;

  /// Generate a random share code
  String _generateShareCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random.secure();
    return List.generate(8, (_) => chars[random.nextInt(chars.length)]).join();
  }

  /// Create a share for a trip
  Future<TripShare?> createShare({
    required String tripId,
    String? email,
    String permission = 'view',
  }) async {
    if (_userId == null) return null;

    try {
      final shareCode = _generateShareCode();
      
      final response = await _client.from('trip_shares').insert({
        'trip_id': tripId,
        'share_code': shareCode,
        'shared_by': _userId,
        'shared_with_email': email,
        'permission': permission,
      }).select().single();

      return TripShare.fromJson(response);
    } catch (e) {
      print('Error creating share: $e');
      return null;
    }
  }

  /// Get all shares for a trip
  Future<List<TripShare>> getSharesForTrip(String tripId) async {
    if (_userId == null) return [];

    try {
      final response = await _client
          .from('trip_shares')
          .select()
          .eq('trip_id', tripId)
          .eq('is_active', true)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => TripShare.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Revoke a share
  Future<bool> revokeShare(String shareId) async {
    if (_userId == null) return false;

    try {
      await _client
          .from('trip_shares')
          .update({'is_active': false})
          .eq('id', shareId);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Claim a share (when an invited user accepts)
  Future<bool> claimShare(String shareCode) async {
    if (_userId == null) return false;

    try {
      await _client.from('trip_shares').update({
        'shared_with_user_id': _userId,
        'claimed_at': DateTime.now().toIso8601String(),
      }).eq('share_code', shareCode).eq('is_active', true);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Share trip via system share sheet
  Future<void> shareTrip({
    required String tripName,
    required String shareCode,
    Rect? sharePositionOrigin,
  }) async {
    final shareLink = 'https://waydeck.app/share/$shareCode';
    final message = '🗺️ Check out my trip "$tripName" on Waydeck!\n\n$shareLink\n\nDownload Waydeck to view the full itinerary.';
    
    await Share.share(
      message, 
      subject: 'Trip: $tripName',
      sharePositionOrigin: sharePositionOrigin,
    );
  }

  /// Copy share link to clipboard
  Future<void> copyShareLink(String shareCode) async {
    final shareLink = 'https://waydeck.app/share/$shareCode';
    await Clipboard.setData(ClipboardData(text: shareLink));
  }
}

/// Singleton instance
final tripShareService = TripShareService();
