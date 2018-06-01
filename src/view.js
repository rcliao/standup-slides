import * as SimpleMDE from 'simplemde';

export function setupEditor (app) {
    let editor;
    app.ports.renderEditor.subscribe(function(view) {
        if (view === 'Notes') {
            requestAnimationFrame(function() {
                const editorDOM = document.querySelector('#note_editor');
                if (editorDOM) {
                    editor = new SimpleMDE({ element: editorDOM });
                } else {
                    console.log('Editor DOM is not found. Cannot add editor widget');
                }
            });
        } else {
            editor.toTextArea();
            editor = null;
        }
    });
}

