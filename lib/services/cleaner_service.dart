import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/cache_location.dart';

class CleanerService extends ChangeNotifier {
  bool _isCleaning = false;
  Map<String, dynamic> _cleanResults = {};

  bool get isCleaning => _isCleaning;
  Map<String, dynamic> get cleanResults => _cleanResults;

  Future<Map<String, dynamic>> cleanLocations(
    List<CacheLocation> locations,
  ) async {
    if (_isCleaning) return {};
    _isCleaning = true;
    _cleanResults = {};
    notifyListeners();

    List<Map<String, dynamic>> results = [];

    for (final loc in locations) {
      if (!loc.selected) continue;

      bool success = false;
      String message = "";

      try {
        final dir = Directory(loc.path);
        if (await dir.exists()) {
          // Try to delete contents first, then directory if possible
          // But for caches, usually we just want to empty the directory
          // or delete the directory itself if it's safe.
          // The python script does: if dir, rm contents; if file, unlink.

          if (loc.path == "/tmp") {
            // Special handling for /tmp, don't delete the dir itself
            await for (final entity in dir.list()) {
              try {
                await entity.delete(recursive: true);
              } catch (e) {
                // Ignore
              }
            }
            success = true;
            message = "Cleaned";
          } else {
            try {
              await dir.delete(recursive: true);
              success = true;
              message = "Deleted";
            } catch (e) {
              // If we can't delete the folder (e.g. permission), try deleting contents
              try {
                await for (final entity in dir.list()) {
                  try {
                    await entity.delete(recursive: true);
                  } catch (e) {
                    // Ignore individual file errors
                  }
                }
                success = true;
                message = "Cleaned contents";
              } catch (e2) {
                success = false;
                message = "Permission denied or in use";
              }
            }
          }
        } else {
          // Check if it's a file (unlikely for our list but possible)
          final file = File(loc.path);
          if (await file.exists()) {
            await file.delete();
            success = true;
            message = "Deleted";
          } else {
            success = true; // Already gone
            message = "Already cleaned";
          }
        }
      } catch (e) {
        success = false;
        message = e.toString();
      }

      results.add({
        "id": loc.id,
        "name": loc.name,
        "success": success,
        "message": message,
      });
    }

    _isCleaning = false;
    notifyListeners();
    return {"results": results};
  }
}
