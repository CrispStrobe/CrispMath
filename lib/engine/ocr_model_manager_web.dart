// lib/engine/ocr_model_manager_web.dart
//
// Web-specific OCR model manager. Downloads GGUF models via fetch()
// and caches them in IndexedDB so they persist across browser sessions.
//
// Uses dart:js_interop directly (no package:web dependency).

import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'ocr_model_catalog.dart';

// ---------------------------------------------------------------------------
// JS interop for IndexedDB + fetch
// ---------------------------------------------------------------------------

@JS('eval')
external JSAny _jsEval(JSString code);

@JS('_ccocrIdbGet')
external JSPromise _jsIdbGet(JSString key);

@JS('_ccocrIdbPut')
external JSPromise _jsIdbPut(JSString key, JSAny data);

@JS('_ccocrIdbDelete')
external JSPromise _jsIdbDelete(JSString key);

@JS('_ccocrFetchModel')
external JSPromise _jsFetchModel(JSString url);

bool _idbHelpersInjected = false;

void _injectIdbHelpers() {
  if (_idbHelpersInjected) return;
  _jsEval('''
    (function() {
      var DB_NAME = 'CrispCalcOcrModels';
      var STORE = 'models';
      var DB_VERSION = 1;

      function openDb() {
        return new Promise(function(resolve, reject) {
          var request = indexedDB.open(DB_NAME, DB_VERSION);
          request.onupgradeneeded = function(event) {
            var db = event.target.result;
            if (!db.objectStoreNames.contains(STORE)) {
              db.createObjectStore(STORE);
            }
          };
          request.onsuccess = function() { resolve(request.result); };
          request.onerror = function() { reject('IndexedDB open failed'); };
        });
      }

      window._ccocrIdbGet = function(key) {
        return openDb().then(function(db) {
          return new Promise(function(resolve, reject) {
            var tx = db.transaction(STORE, 'readonly');
            var request = tx.objectStore(STORE).get(key);
            request.onsuccess = function() { resolve(request.result || null); };
            request.onerror = function() { resolve(null); };
          });
        });
      };

      window._ccocrIdbPut = function(key, data) {
        return openDb().then(function(db) {
          return new Promise(function(resolve, reject) {
            var tx = db.transaction(STORE, 'readwrite');
            tx.objectStore(STORE).put(data, key);
            tx.oncomplete = function() { resolve(); };
            tx.onerror = function() { reject('IndexedDB write failed'); };
          });
        });
      };

      window._ccocrIdbDelete = function(key) {
        return openDb().then(function(db) {
          return new Promise(function(resolve, reject) {
            var tx = db.transaction(STORE, 'readwrite');
            tx.objectStore(STORE).delete(key);
            tx.oncomplete = function() { resolve(); };
            tx.onerror = function() { reject('IndexedDB delete failed'); };
          });
        });
      };

      window._ccocrFetchModel = function(url) {
        return fetch(url).then(function(response) {
          if (!response.ok) throw new Error('fetch failed: ' + response.status);
          return response.arrayBuffer();
        });
      };
    })();
  '''
      .toJS);
  _idbHelpersInjected = true;
}

// ---------------------------------------------------------------------------
// Web model manager
// ---------------------------------------------------------------------------

/// Models suitable for web (small enough for browser download).
List<OcrModelVariant> get webModelCatalog {
  return OcrModelCatalog.all
      .where((m) => m.sizeBytes <= 30 * 1024 * 1024)
      .toList();
}

class OcrModelManagerWeb {
  /// Check if a model is cached in IndexedDB.
  static Future<bool> isDownloaded(OcrModelVariant model) async {
    _injectIdbHelpers();
    final result = await _jsIdbGet(model.filename.toJS).toDart;
    return result != null && !result.isUndefined && !result.isNull;
  }

  /// Get cached model bytes, or null if not downloaded.
  static Future<Uint8List?> getModelBytes(OcrModelVariant model) async {
    _injectIdbHelpers();
    final result = await _jsIdbGet(model.filename.toJS).toDart;
    if (result == null || result.isUndefined || result.isNull) return null;
    final buffer = result as JSArrayBuffer;
    return buffer.toDart.asUint8List();
  }

  /// Download a model from HuggingFace and cache in IndexedDB.
  /// Returns the model bytes on success, null on failure.
  static Future<Uint8List?> download(
    OcrModelVariant model, {
    void Function(int received, int total)? onProgress,
  }) async {
    _injectIdbHelpers();
    try {
      // Simple fetch (no streaming progress for now — add later if needed).
      final result = await _jsFetchModel(model.url.toJS).toDart;
      if (result == null || result.isUndefined || result.isNull) return null;

      final buffer = result as JSArrayBuffer;
      final bytes = buffer.toDart.asUint8List();

      onProgress?.call(bytes.length, bytes.length);

      // Cache in IndexedDB.
      await _jsIdbPut(model.filename.toJS, buffer).toDart;

      return bytes;
    } catch (e) {
      return null;
    }
  }

  /// Delete a cached model.
  static Future<void> delete(OcrModelVariant model) async {
    _injectIdbHelpers();
    await _jsIdbDelete(model.filename.toJS).toDart;
  }
}
