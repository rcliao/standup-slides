import * as SimpleMDE from 'simplemde';

export function setupEditor (app) {
    let editor;
    app.ports.renderEditor.subscribe(function(view) {
        console.log(view);
        if (view === 'Notes') {
            setTimeout(function() {
                const editorDOM = document.querySelector('#note_editor');
                console.log(editorDOM);
                if (editorDOM) {
                    editor = new SimpleMDE({ element: editorDOM });
                }
                console.log(editor);
            }, 500);
        } else {
            editor.toTextArea();
            editor = null;
        }
    });
}

