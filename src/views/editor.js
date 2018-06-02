import * as SimpleMDE from 'simplemde';

let editor = null;

export function rendor () {
    const editorDOM = document.querySelector('#note_editor');
    if (editorDOM) {
        editor = new SimpleMDE({ element: editorDOM });
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

