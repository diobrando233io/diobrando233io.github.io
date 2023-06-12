//=============================================================================
// main.js
//=============================================================================

$plugins=$plugins.concat([{name: 'AudioStreaming',status: true,description:'音声読み込みを高速化し、oggファイルのみを使用します。',parameters: { mode: '10', deleteM4a: 'false' },},{name: 'stbvorbis_stream', status: false, description: '', parameters: {} },{name: 'stbvorbis_stream_asm',status: false,description: '',parameters: {},},]);PluginManager.setup($plugins);

window.onload = function() {
    SceneManager.run(Scene_Boot);
};
