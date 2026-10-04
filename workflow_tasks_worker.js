/* A worker-local WASM module, independent of the UI's bridge. */
self.window = self; // The bridge's helper bindings target window properties.
self.symEngineReady = false;
self.symEngineInstance = null;
const queued = [];
self.onmessage = event => queued.push(event.data);

(async () => {
  try {
    importScripts('symengine.js');
    self.symEngineInstance = await SymEngineModule();
    self.symEngineReady = true;
  } catch (error) {
    // The same Dart engine provides its usual pure-Dart CAS fallbacks.
    console.warn('Worker CAS using Dart fallback:', error);
  }
  try {
    importScripts('workflow_tasks_worker.dart.js');
    const handler = self.onmessage;
    for (const data of queued.splice(0)) handler({data});
  } catch (error) {
    self.postMessage({type: 'fatal', error: 'Background math could not initialize'});
  }
})();
