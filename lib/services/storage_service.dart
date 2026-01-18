import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload profile image
  Future<String?> uploadProfileImage({
    required String userId,
    required File imageFile,
  }) async {
    try {
      final ref = _storage.ref().child('profile_images/$userId.jpg');

      final uploadTask = ref.putFile(
        imageFile,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      // Monitor upload progress
      uploadTask.snapshotEvents.listen((event) {
        final progress = event.bytesTransferred / event.totalBytes;
        if (kDebugMode) {
          print('Upload progress: ${(progress * 100).toStringAsFixed(1)}%');
        }
      });

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading profile image: $e');
      }
      return null;
    }
  }

  // Upload incident image
  Future<String?> uploadIncidentImage({
    required String incidentId,
    required File imageFile,
    required int imageIndex,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final ref = _storage
          .ref()
          .child('incident_images/$incidentId/${timestamp}_$imageIndex.jpg');

      final uploadTask = ref.putFile(
        imageFile,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading incident image: $e');
      }
      return null;
    }
  }

  // Upload multiple incident images
  Future<List<String>> uploadIncidentImages({
    required String incidentId,
    required List<File> imageFiles,
  }) async {
    final urls = <String>[];

    for (int i = 0; i < imageFiles.length; i++) {
      final url = await uploadIncidentImage(
        incidentId: incidentId,
        imageFile: imageFiles[i],
        imageIndex: i,
      );
      if (url != null) {
        urls.add(url);
      }
    }

    return urls;
  }

  // Upload venue image
  Future<String?> uploadVenueImage({
    required String venueId,
    required File imageFile,
    required String imageName,
  }) async {
    try {
      final ref = _storage.ref().child('venue_images/$venueId/$imageName.jpg');

      final uploadTask = ref.putFile(
        imageFile,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading venue image: $e');
      }
      return null;
    }
  }

  // Upload zone map image
  Future<String?> uploadZoneMapImage({
    required String venueId,
    required String zoneId,
    required File imageFile,
  }) async {
    try {
      final ref = _storage.ref().child('zone_maps/$venueId/$zoneId.png');

      final uploadTask = ref.putFile(
        imageFile,
        SettableMetadata(contentType: 'image/png'),
      );

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading zone map: $e');
      }
      return null;
    }
  }

  // Delete file
  Future<bool> deleteFile(String fileUrl) async {
    try {
      final ref = _storage.refFromURL(fileUrl);
      await ref.delete();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting file: $e');
      }
      return false;
    }
  }

  // Delete all incident images
  Future<void> deleteIncidentImages(String incidentId) async {
    try {
      final ref = _storage.ref().child('incident_images/$incidentId');
      final result = await ref.listAll();

      for (final item in result.items) {
        await item.delete();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting incident images: $e');
      }
    }
  }

  // Get download URL for a path
  Future<String?> getDownloadUrl(String path) async {
    try {
      final ref = _storage.ref().child(path);
      return await ref.getDownloadURL();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting download URL: $e');
      }
      return null;
    }
  }

  // Check if file exists
  Future<bool> fileExists(String path) async {
    try {
      final ref = _storage.ref().child(path);
      await ref.getMetadata();
      return true;
    } catch (e) {
      return false;
    }
  }
}
