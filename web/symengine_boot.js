// SymEngine WASM handshake. Lives in a FILE (not inline) because `defer`
// is ignored on inline scripts: an inline handshake executes during HTML
// parsing, before the deferred symengine.js has defined SymEngineModule —
// which silently killed the web CAS (fallback banner) after the June
// startup-perf change deferred the loaders. File scripts honor defer and
// run in document order, so SymEngineModule is guaranteed to exist here.
SymEngineModule().then(function (instance) {
  symEngineInstance = instance;
  symEngineReady = true;
  console.log('SymEngine WASM loaded (' +
    instance.ccall('flutter_symengine_version', 'string', [], []) + ')');
}).catch(function (err) {
  console.warn('SymEngine WASM failed to load:', err);
});
