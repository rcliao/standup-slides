import * as SimpleMDE from 'simplemde';

let editor = null;

export function render (onChangeCallback) {
    const editorDOM = document.querySelector('#note_editor');
    if (editorDOM) {
        editor = new SimpleMDE({ element: editorDOM });
        editor.codemirror.on('change', () => {
            onChangeCallback(editor.value());
        });
    } else {
        console.log('Editor DOM is not found. Cannot add editor widget');
    }
}
export function cleanup () {
    if (editor) {
        editor.toTextArea();
        editor = null;
    }
}

